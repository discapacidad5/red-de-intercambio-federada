package api

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"federated-credit-node/internal/db"
)

// PresetsHandler maneja los endpoints de preconfiguraciones de nodo.
type PresetsHandler struct {
	Pool       *pgxpool.Pool
	NodeDomain string
}

func (h *PresetsHandler) RegisterRoutes(r chi.Router, am *AuthMiddleware) {
	r.Get("/api/presets", h.listPresets)
	r.Get("/api/presets/{id}", h.getPreset)
	// Aplicar preset durante setup o por admin
	r.With(am.RequirePermission("config.manage")).Post("/api/node/apply-preset", h.applyPreset)
	// Endpoint publico para setup (sin auth, pero solo funciona si el nodo no esta inicializado)
	r.Post("/api/setup/apply-preset", h.applyPresetSetup)
}

func (h *PresetsHandler) listPresets(w http.ResponseWriter, r *http.Request) {
	presets, err := db.ListPresets(r.Context(), h.Pool)
	if err != nil {
		writeError(w, 500, "error listing presets")
		return
	}

	// Localizar name/description del preset segun el idioma del request.
	// Las fuentes (espanol) se registran como entity_type 'node_preset'.
	lang, fallbackLang := resolveRequestLanguages(r, h.Pool, "__GLOBAL__")
	if !strings.EqualFold(lang, fallbackLang) && len(presets) > 0 {
		keys := make([]string, 0, len(presets)*2)
		for _, p := range presets {
			keys = append(keys, "node_preset:"+p.ID+":name", "node_preset:"+p.ID+":description")
		}
		values := localizedContentValues(r.Context(), h.Pool, keys, lang)
		for i := range presets {
			if v := values["node_preset:"+presets[i].ID+":name"]; v != "" {
				presets[i].Name = v
			}
			if v := values["node_preset:"+presets[i].ID+":description"]; v != "" {
				presets[i].Description = v
			}
		}
	}
	writeJSON(w, 200, map[string]interface{}{"presets": presets})
}

// registerNodePresetSources registra los presets como fuentes traducibles
// (entity_type 'node_preset', dominio '__GLOBAL__') para el modulo de idiomas.
func registerNodePresetSources(ctx context.Context, pool *pgxpool.Pool) {
	presets, err := db.ListPresets(ctx, pool)
	if err != nil {
		return
	}
	for _, p := range presets {
		meta := map[string]interface{}{"label": p.Name, "category": p.Category}
		_, _ = upsertContentSource(ctx, pool, "__GLOBAL__", "node_preset", p.ID, "name", p.Name, meta)
		_, _ = upsertContentSource(ctx, pool, "__GLOBAL__", "node_preset", p.ID, "description", p.Description, meta)
	}
}

func (h *PresetsHandler) getPreset(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	preset, err := db.GetPreset(r.Context(), h.Pool, id)
	if err != nil {
		writeError(w, 404, "preset not found")
		return
	}
	writeJSON(w, 200, preset)
}

func (h *PresetsHandler) applyPreset(w http.ResponseWriter, r *http.Request) {
	nodeDomain := r.Header.Get("X-Node-Domain")
	if nodeDomain == "" {
		nodeDomain = h.NodeDomain
	}

	var req struct {
		PresetID string `json:"preset_id"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	if req.PresetID == "" {
		writeError(w, 400, "preset_id is required")
		return
	}

	if err := db.ApplyPreset(r.Context(), h.Pool, nodeDomain, req.PresetID); err != nil {
		writeError(w, 500, "error applying preset: "+err.Error())
		return
	}

	writeJSON(w, 200, map[string]interface{}{"success": true})
}

func (h *PresetsHandler) applyPresetSetup(w http.ResponseWriter, r *http.Request) {
	// Solo funciona si el nodo no esta inicializado (no hay admin)
	var hasAdmin bool
	err := h.Pool.QueryRow(r.Context(), `SELECT EXISTS(SELECT 1 FROM users WHERE is_admin = true OR is_super_admin = true)`).Scan(&hasAdmin)
	if err != nil {
		writeError(w, 500, "error checking setup status")
		return
	}
	if hasAdmin {
		writeError(w, 403, "node already initialized - use admin endpoint")
		return
	}

	var req struct {
		PresetID   string `json:"preset_id"`
		NodeDomain string `json:"node_domain"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	if req.PresetID == "" || req.PresetID == "vacio" {
		writeJSON(w, 200, map[string]interface{}{"success": true, "skipped": true})
		return
	}

	// Usar node_domain del body, o del header, o el del handler
	nodeDomain := req.NodeDomain
	if nodeDomain == "" {
		nodeDomain = r.Header.Get("X-Node-Domain")
	}
	if nodeDomain == "" {
		nodeDomain = h.NodeDomain
	}

	if err := db.ApplyPreset(r.Context(), h.Pool, nodeDomain, req.PresetID); err != nil {
		writeError(w, 500, "error applying preset: "+err.Error())
		return
	}

	writeJSON(w, 200, map[string]interface{}{"success": true})
}
