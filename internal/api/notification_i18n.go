package api

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Plantillas de notificaciones programadas por idioma.
// El idioma fuente es 'es'; el resto se puede ampliar aqui o via el editor
// de traducciones del modulo de idiomas (entity_type 'notif_template').
var notifTemplates = map[string]map[string]string{
	"proposal_closing_title": {
		"es": "Votacion por cerrar",
		"en": "Voting closing soon",
	},
	"proposal_closing_msg": {
		"es": "Quedan %s para votar: %s",
		"en": "%s left to vote: %s",
	},
	"assembly_reminder_title": {
		"es": "Asamblea proxima",
		"en": "Upcoming assembly",
	},
	"assembly_reminder_msg": {
		"es": "La asamblea \"%s\" es manana a las %s.",
		"en": "The assembly \"%s\" is tomorrow at %s.",
	},
	"time_hours": {
		"es": "%d horas",
		"en": "%d hours",
	},
	"time_minutes": {
		"es": "%d minutos",
		"en": "%d minutes",
	},
	"digest_subject": {
		"es": "Resumen diario: %d notificaciones no leidas",
		"en": "Daily digest: %d unread notifications",
	},
	"digest_body": {
		"es": "Hola,\n\nTienes %d notificaciones no leidas en la Red Federada:\n\n%s\n\nPara ver todas tus notificaciones, ingresa a la aplicacion.\n\nSaludos,\nRed Federada",
		"en": "Hi,\n\nYou have %d unread notifications in the Federated Network:\n\n%s\n\nTo see all your notifications, log in to the app.\n\nRegards,\nFederated Network",
	},
}

// notifT devuelve la plantilla traducida para un idioma; fallback a espanol.
func notifT(lang, key string) string {
	if m, ok := notifTemplates[key]; ok {
		if v, ok := m[lang]; ok && v != "" {
			return v
		}
		// Probar prefijo base (pt-BR -> pt no existe, cae a es)
		if v, ok := m["es"]; ok {
			return v
		}
	}
	return key
}

// userLanguage devuelve el idioma preferido del usuario (user_preferences.language),
// o el default del nodo, o 'es'.
func userLanguage(ctx context.Context, pool *pgxpool.Pool, userID uuid.UUID, nodeDomain string) string {
	var lang string
	err := pool.QueryRow(ctx, `SELECT COALESCE(language, '') FROM user_preferences WHERE user_id = $1`, userID).Scan(&lang)
	if err == nil && lang != "" {
		return normalizeLang(lang)
	}
	return defaultLanguage(ctx, pool, nodeDomain)
}

// normalizeLang extrae el codigo base minusculas (es-VE -> es).
func normalizeLang(code string) string {
	code = strings.ToLower(strings.TrimSpace(code))
	if i := strings.IndexAny(code, "-_"); i > 0 {
		code = code[:i]
	}
	return code
}

// fmtTimeLeft formatea "X horas" / "X minutos" en el idioma indicado.
func fmtTimeLeft(lang string, deadline time.Time) string {
	d := time.Until(deadline)
	if d.Hours() < 1 {
		return fmt.Sprintf(notifT(lang, "time_minutes"), int(d.Minutes()))
	}
	return fmt.Sprintf(notifT(lang, "time_hours"), int(d.Hours()))
}
