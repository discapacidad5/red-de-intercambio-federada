package api

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"federated-credit-node/internal/db"
	"federated-credit-node/internal/external"
)

type ExternalHandler struct {
	DEX        *external.DEX
	Store      *external.Store
	NodeDomain string
	Auth       *AuthMiddleware
	Pool       *pgxpool.Pool
}

func NewExternalHandler(dex *external.DEX, store *external.Store, nodeDomain string, am *AuthMiddleware, pool *pgxpool.Pool) *ExternalHandler {
	return &ExternalHandler{DEX: dex, Store: store, NodeDomain: nodeDomain, Auth: am, Pool: pool}
}

func (eh *ExternalHandler) RegisterRoutes(r chi.Router) {
	eh.RegisterRoutesWithAuth(r, nil)
}

func (eh *ExternalHandler) RegisterRoutesWithAuth(r chi.Router, am *AuthMiddleware) {
	r.Get("/api/external/fc", eh.getCurrentFC)
	r.Post("/api/external/fc/calculate", eh.calculateFC)
	r.Post("/api/external/fc/calculate-basket", eh.calculateFCBasket)
	if am != nil {
		r.With(am.RequirePermission("external.store_fc")).Post("/api/external/fc/store", eh.storeFC)
		r.With(am.RequirePermission("external.store_fc")).Post("/api/external/fc/store-basket", eh.storeFCBasket)
	} else {
		r.Post("/api/external/fc/store", eh.storeFC)
		r.Post("/api/external/fc/store-basket", eh.storeFCBasket)
	}

	r.Get("/api/external/operations", eh.listOperations)
	r.Post("/api/external/operations", eh.createOperation)
	r.Get("/api/external/operations/{id}", eh.getOperation)
	if am != nil {
		r.With(am.RequirePermission("external.approve_operation")).Post("/api/external/operations/{id}/approve", eh.approveOperation)
		r.With(am.RequirePermission("external.reject_operation")).Post("/api/external/operations/{id}/reject", eh.rejectOperation)
	} else {
		r.Post("/api/external/operations/{id}/approve", eh.approveOperation)
		r.Post("/api/external/operations/{id}/reject", eh.rejectOperation)
	}

	r.Get("/api/store/items", eh.listStoreItems)
	r.Post("/api/store/items", eh.addStoreItem)
	r.Get("/api/store/items/{id}", eh.getStoreItem)
	r.Get("/api/store/all", eh.listAllStores)
	r.Get("/api/store/services-catalog", eh.listServicesCatalog)
	r.Get("/api/public/store-items", eh.listPublicStoreItems)
	if am != nil {
		r.With(am.RequirePermission("store.update_stock")).Put("/api/store/items/{id}/stock", eh.updateStock)
		r.With(am.RequirePermission("store.update_price")).Put("/api/store/items/{id}/price", eh.updatePrice)
		r.With(am.RequirePermission("store.deactivate_item")).Delete("/api/store/items/{id}", eh.deactivateStoreItem)
	} else {
		r.Put("/api/store/items/{id}/stock", eh.updateStock)
		r.Put("/api/store/items/{id}/price", eh.updatePrice)
		r.Delete("/api/store/items/{id}", eh.deactivateStoreItem)
	}
	// Visibilidad en el POS: el dueno decide que items aparecen en su punto de venta
	r.With(am.RequireAuth).Put("/api/store/items/{id}/pos-visibility", eh.togglePosVisibility)
	// Categoria del item: el dueno organiza su tienda en categorias que el POS replica
	r.With(am.RequireAuth).Put("/api/store/items/{id}/category", eh.updateItemCategory)
	// Edicion completa del item: unidad, cantidad por unidad (divisibilidad),
	// precio, modo de stock (contable/ilimitado), nombre/descripcion
	r.With(am.RequireAuth).Put("/api/store/items/{id}", eh.updateStoreItem)
	// Categorías propias de la tienda del dueño — se asignan a items y el
	// POS las replica automáticamente
	r.With(am.RequireAuth).Get("/api/store/categories", eh.listStoreCategories)
	r.With(am.RequireAuth).Post("/api/store/categories", eh.createStoreCategory)
	r.With(am.RequireAuth).Delete("/api/store/categories/{id}", eh.deleteStoreCategory)
	r.With(am.RequireAuth).Put("/api/store/categories/visibility", eh.toggleCategoryVisibility)
	r.Post("/api/store/purchase", eh.purchase)
	r.Post("/api/store/composite", eh.addCompositeItem)
	r.Get("/api/store/composite/{id}/composition", eh.getComposition)
	r.Get("/api/products/components", eh.listComponents)
}

func (eh *ExternalHandler) getCurrentFC(w http.ResponseWriter, r *http.Request) {
	// Obtener la canasta interna desde la federacion (constante federada)
	// Es el mismo valor en TODOS los nodos. No es configurable por nodo.
	var basketInternalTQ int64 = 500 // valor por defecto
	var basketValue []byte
	err := eh.Pool.QueryRow(r.Context(), `SELECT value FROM federation_constants WHERE key = 'basket_cost_internal_tq'`).Scan(&basketValue)
	if err == nil {
		// Intentar parsear como numero
		var n int64
		if json.Unmarshal(basketValue, &n) == nil {
			basketInternalTQ = n
		} else {
			var s string
			if json.Unmarshal(basketValue, &s) == nil {
				fmt.Sscanf(s, "%d", &basketInternalTQ)
			}
		}
	}

	cf, err := eh.DEX.GetCurrentFC(r.Context())
	if err != nil {
		// Devolver FC por defecto en vez de 404
		writeJSON(w, 200, map[string]interface{}{
			"factor":                 5.0,
			"external_cpi":           300,
			"local_energy_cost":      60,
			"external_currency":      "USD",
			"basket_cost_external":   0,
			"basket_cost_local_tq":   basketInternalTQ,
			"basket_internal_source": "federation",
			"calculated_at":          time.Now().UTC(),
			"is_default":             true,
		})
		return
	}

	// Sobrescribir la canasta interna con el valor federado
	cf.BasketCostLocalTQ = basketInternalTQ
	writeJSON(w, 200, cf)
}

type CalculateFCRequest struct {
	ExternalCPI     float64 `json:"external_cpi"`
	LocalEnergyCost float64 `json:"local_energy_cost"`
}

func (eh *ExternalHandler) calculateFC(w http.ResponseWriter, r *http.Request) {
	var req CalculateFCRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	fc, err := eh.DEX.CalculateFC(r.Context(), req.ExternalCPI, req.LocalEnergyCost)
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}

	writeJSON(w, 200, map[string]interface{}{
		"factor":            fc,
		"external_cpi":      req.ExternalCPI,
		"local_energy_cost": req.LocalEnergyCost,
	})
}

type StoreFCRequest struct {
	Factor          float64     `json:"factor"`
	ExternalCPI     float64     `json:"external_cpi"`
	LocalEnergyCost float64     `json:"local_energy_cost"`
	ApprovedBy      []uuid.UUID `json:"approved_by"`
}

func (eh *ExternalHandler) storeFC(w http.ResponseWriter, r *http.Request) {
	var req StoreFCRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	cf, err := eh.DEX.StoreFC(r.Context(), req.Factor, req.ExternalCPI, req.LocalEnergyCost, req.ApprovedBy)
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, cf)
}

// CalculateFCBasketRequest - calcular FC desde canasta basica
// La canasta interna NO se envia: viene de la federacion (constante federada)
type CalculateFCBasketRequest struct {
	ExternalCurrency   string  `json:"external_currency"`
	BasketCostExternal float64 `json:"basket_cost_external"`
	BasketCostLocalTQ  int64   `json:"basket_cost_local_tq"` // ignorado, viene de la federacion
}

func (eh *ExternalHandler) calculateFCBasket(w http.ResponseWriter, r *http.Request) {
	var req CalculateFCBasketRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	if req.ExternalCurrency == "" {
		req.ExternalCurrency = "USD"
	}

	// La canasta interna viene de la federacion, no del request
	var basketInternalTQ int64 = 500
	var basketValue []byte
	err := eh.Pool.QueryRow(r.Context(), `SELECT value FROM federation_constants WHERE key = 'basket_cost_internal_tq'`).Scan(&basketValue)
	if err == nil {
		var n int64
		if json.Unmarshal(basketValue, &n) == nil {
			basketInternalTQ = n
		} else {
			var s string
			if json.Unmarshal(basketValue, &s) == nil {
				fmt.Sscanf(s, "%d", &basketInternalTQ)
			}
		}
	}

	fc, err := eh.DEX.CalculateFCFromBasket(r.Context(), req.BasketCostExternal, basketInternalTQ)
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}

	writeJSON(w, 200, map[string]interface{}{
		"factor":                 fc,
		"external_currency":      req.ExternalCurrency,
		"basket_cost_external":   req.BasketCostExternal,
		"basket_cost_local_tq":   basketInternalTQ,
		"basket_internal_source": "federation",
		"basket_internal_note":   "La canasta interna es un valor federado. Es el mismo en todos los nodos. Solo se puede cambiar via propuesta federada aprobada.",
	})
}

// StoreFCBasketRequest - guardar FC calculado desde canasta basica
type StoreFCBasketRequest struct {
	Factor             float64     `json:"factor"`
	ExternalCurrency   string      `json:"external_currency"`
	BasketCostExternal float64     `json:"basket_cost_external"`
	BasketCostLocalTQ  int64       `json:"basket_cost_local_tq"`
	ApprovedBy         []uuid.UUID `json:"approved_by"`
}

func (eh *ExternalHandler) storeFCBasket(w http.ResponseWriter, r *http.Request) {
	var req StoreFCBasketRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	if req.ExternalCurrency == "" {
		req.ExternalCurrency = "USD"
	}

	// La canasta interna viene de la federacion, no del request
	var basketInternalTQ int64 = 500
	var basketValue []byte
	err := eh.Pool.QueryRow(r.Context(), `SELECT value FROM federation_constants WHERE key = 'basket_cost_internal_tq'`).Scan(&basketValue)
	if err == nil {
		var n int64
		if json.Unmarshal(basketValue, &n) == nil {
			basketInternalTQ = n
		} else {
			var s string
			if json.Unmarshal(basketValue, &s) == nil {
				fmt.Sscanf(s, "%d", &basketInternalTQ)
			}
		}
	}

	cf, err := eh.DEX.StoreFCFromBasket(r.Context(), req.Factor, req.BasketCostExternal, basketInternalTQ, req.ExternalCurrency, req.ApprovedBy)
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, cf)
}

func (eh *ExternalHandler) listOperations(w http.ResponseWriter, r *http.Request) {
	status := r.URL.Query().Get("status")
	ops, err := eh.DEX.ListOperations(r.Context(), status)
	if err != nil {
		writeError(w, 500, err.Error())
		return
	}
	writeJSON(w, 200, ops)
}

type CreateOperationRequest struct {
	OperationType     string  `json:"operation_type"`
	ProductName       string  `json:"product_name"`
	Quantity          int64   `json:"quantity"`
	ExternalPriceUSD  float64 `json:"external_price_usd"`
	LocalPriceTrueque float64 `json:"local_price_trueque"`
	LogisticsPct      float64 `json:"logistics_pct"`
	ExternalTaxRate   float64 `json:"external_tax_rate"`
}

func (eh *ExternalHandler) createOperation(w http.ResponseWriter, r *http.Request) {
	var req CreateOperationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	requestedByStr := r.Header.Get("X-User-ID")
	requestedBy, err := uuid.Parse(requestedByStr)
	if err != nil {
		writeError(w, 401, "authentication required")
		return
	}

	op, err := eh.DEX.CreateOperation(r.Context(), external.CreateOperationParams{
		OperationType:     req.OperationType,
		ProductName:       req.ProductName,
		Quantity:          req.Quantity,
		ExternalPriceUSD:  req.ExternalPriceUSD,
		LocalPriceTrueque: req.LocalPriceTrueque,
		LogisticsPct:      req.LogisticsPct,
		ExternalTaxRate:   req.ExternalTaxRate,
		RequestedBy:       requestedBy,
	})
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, op)
}

func (eh *ExternalHandler) getOperation(w http.ResponseWriter, r *http.Request) {
	opID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid operation id")
		return
	}

	op, err := eh.DEX.GetOperation(r.Context(), opID)
	if err != nil {
		writeError(w, 404, err.Error())
		return
	}
	writeJSON(w, 200, op)
}

func (eh *ExternalHandler) approveOperation(w http.ResponseWriter, r *http.Request) {
	opID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid operation id")
		return
	}

	approverIDStr := r.Header.Get("X-User-ID")
	approverID, err := uuid.Parse(approverIDStr)
	if err != nil {
		writeError(w, 401, "authentication required")
		return
	}

	if err := eh.DEX.ApproveOperation(r.Context(), opID, approverID); err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "approved"})
}

type RejectOperationRequest struct {
	Reason string `json:"reason"`
}

func (eh *ExternalHandler) rejectOperation(w http.ResponseWriter, r *http.Request) {
	opID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid operation id")
		return
	}

	var req RejectOperationRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	if err := eh.DEX.RejectOperation(r.Context(), opID, req.Reason); err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "rejected"})
}

func (eh *ExternalHandler) listStoreItems(w http.ResponseWriter, r *http.Request) {
	category := r.URL.Query().Get("category")
	items, err := eh.Store.ListItems(r.Context(), category)
	if err != nil {
		writeError(w, 500, err.Error())
		return
	}

	// Filtrar por el propietario autenticado si existe (o ?owner_id=...)
	var filterOwnerID *uuid.UUID
	if oidStr := r.URL.Query().Get("owner_id"); oidStr != "" {
		if parsed, err := uuid.Parse(oidStr); err == nil {
			filterOwnerID = &parsed
		}
	} else if eh.Auth != nil {
		if uid, err := eh.Auth.GetUserID(r); err == nil && uid != uuid.Nil {
			filterOwnerID = &uid
		}
	}

	if filterOwnerID != nil {
		filtered := make([]external.StoreItem, 0, len(items))
		for _, it := range items {
			if it.OwnerID != nil && *it.OwnerID == *filterOwnerID {
				filtered = append(filtered, it)
			}
		}
		// Si el usuario autenticado es admin/super_admin y su ID no coincide con el owner_id
		// backfilleado de la tienda del nodo, mostrar todos los ítems activos del nodo.
		if len(filtered) == 0 && r.URL.Query().Get("owner_id") == "" {
			var isAdmin bool
			_ = eh.Pool.QueryRow(r.Context(), `
				SELECT EXISTS(
					SELECT 1 FROM users
					WHERE id = $1 AND (COALESCE(is_super_admin, false) = true OR role IN ('admin', 'super_admin'))
				)`, *filterOwnerID).Scan(&isAdmin)
			if !isAdmin {
				items = filtered
			}
		} else {
			items = filtered
		}
	}

	// Incluir automaticamente los servicios universales (ej: Trabajo en el Conuco / Mano Vuelta)
	// para que todo miembro activo los tenga disponibles en su tienda y en su POS.
	var ownerName string
	if filterOwnerID != nil {
		_ = eh.Pool.QueryRow(r.Context(), `SELECT COALESCE(display_name, username, '') FROM users WHERE id = $1`, *filterOwnerID).Scan(&ownerName)
	}
	if univ, uErr := eh.Store.ListUniversalServices(r.Context(), filterOwnerID, ownerName); uErr == nil && len(univ) > 0 {
		existingProdIDs := make(map[uuid.UUID]bool)
		for _, it := range items {
			if it.ProductID != nil {
				existingProdIDs[*it.ProductID] = true
			}
		}
		for _, u := range univ {
			if u.ProductID != nil && !existingProdIDs[*u.ProductID] {
				items = append(items, u)
			}
		}
	}

	eh.localizeStoreItems(r, items)
	writeJSON(w, 200, items)
}

// listServicesCatalog devuelve todos los servicios aprobados del catalogo federado
// para que cualquier miembro pueda elegir cuales servicios (intelectuales, tecnicos,
// oficios) ofrece y agregarlos a su tienda personal.
func (eh *ExternalHandler) listServicesCatalog(w http.ResponseWriter, r *http.Request) {
	nodeDomain := db.ResolveNodeDomain(r.Context(), eh.Pool, r.Header.Get("X-Node-Domain"), eh.NodeDomain)
	lang, fallbackLang := resolveRequestLanguages(r, eh.Pool, nodeDomain)

	rows, err := eh.Pool.Query(r.Context(), `
		SELECT id, COALESCE(catalog_key,''), COALESCE(item_code,''), name, COALESCE(description,''),
		       COALESCE(parent_category,'Servicios'), COALESCE(category,''), COALESCE(subcategory,''),
		       COALESCE(unit,'hora'), price_per_unit, COALESCE(is_universal_service,false)
		FROM products
		WHERE node_domain = '__FEDERATION__'
		  AND item_type = 'service'
		  AND is_active = true
		  AND is_approved = true
		  AND COALESCE(is_allowed, true) = true
		ORDER BY is_universal_service DESC, category, name`)
	if err != nil {
		writeJSON(w, 200, []interface{}{})
		return
	}
	defer rows.Close()

	services := []map[string]interface{}{}
	for rows.Next() {
		var id, catalogKey, itemCode, name, desc, parentCat, cat, subcat, unit string
		var price float64
		var isUniversal bool
		if err := rows.Scan(&id, &catalogKey, &itemCode, &name, &desc, &parentCat, &cat, &subcat, &unit, &price, &isUniversal); err != nil {
			continue
		}
		services = append(services, map[string]interface{}{
			"id":                   id,
			"catalog_key":          catalogKey,
			"item_code":            itemCode,
			"name":                 name,
			"description":          desc,
			"parent_category":      parentCat,
			"category":             cat,
			"subcategory":          subcat,
			"unit":                 unit,
			"price_per_unit":       price,
			"is_universal_service": isUniversal,
		})
	}
	localizeEntityMaps(r.Context(), eh.Pool, services, "product", lang, fallbackLang, "name", "description", "unit")
	writeJSON(w, 200, services)
}

// listAllStores devuelve todos los items de todas las tiendas para busqueda publico
func (eh *ExternalHandler) listAllStores(w http.ResponseWriter, r *http.Request) {
	items, err := eh.Store.ListItems(r.Context(), "")
	if err != nil {
		writeError(w, 500, err.Error())
		return
	}
	eh.localizeStoreItems(r, items)
	writeJSON(w, 200, items)
}

// listPublicStoreItems devuelve los items publicados en la tienda para mostrar
// en la pagina publica (lo que realmente hay disponible en la feria)
func (eh *ExternalHandler) listPublicStoreItems(w http.ResponseWriter, r *http.Request) {
	category := r.URL.Query().Get("category")
	items, err := eh.Store.ListItems(r.Context(), category)
	if err != nil {
		writeJSON(w, 200, []interface{}{})
		return
	}
	eh.localizeStoreItems(r, items)
	writeJSON(w, 200, items)
}

// localizeStoreItems overlays the active language without changing category
// keys or monetary data. A linked catalogue product is the preferred source
// for shared name/description/unit translations; independent store text keeps
// its own store-item source.
func (eh *ExternalHandler) localizeStoreItems(r *http.Request, items []external.StoreItem) {
	nodeDomain := db.ResolveNodeDomain(r.Context(), eh.Pool, r.Header.Get("X-Node-Domain"), eh.NodeDomain)
	lang, fallbackLang := resolveRequestLanguages(r, eh.Pool, nodeDomain)
	if len(items) == 0 || strings.EqualFold(lang, fallbackLang) {
		return
	}
	keys := make([]string, 0, len(items)*6)
	for _, item := range items {
		id := item.ID.String()
		keys = append(keys,
			"store_item:"+id+":product_name", "store_item:"+id+":description", "store_item:"+id+":extra_description")
		if item.ProductID != nil {
			productID := item.ProductID.String()
			keys = append(keys, "product:"+productID+":name", "product:"+productID+":description", "product:"+productID+":unit")
		}
	}
	translations := localizedContentValues(r.Context(), eh.Pool, keys, lang)
	for i := range items {
		item := &items[i]
		id := item.ID.String()
		if item.ProductID != nil {
			productID := item.ProductID.String()
			if value := translations["product:"+productID+":name"]; value != "" {
				item.ProductName = value
			}
			if value := translations["product:"+productID+":description"]; value != "" {
				item.Description = value
			}
			if value := translations["product:"+productID+":unit"]; value != "" {
				item.Unit = value
			}
		}
		if value := translations["store_item:"+id+":product_name"]; value != "" {
			item.ProductName = value
		}
		if value := translations["store_item:"+id+":description"]; value != "" {
			item.Description = value
		}
		if value := translations["store_item:"+id+":extra_description"]; value != "" {
			item.ExtraDescription = value
		}
	}
}

type AddStoreItemRequest struct {
	ProductID        string     `json:"product_id"`
	ProductName      string     `json:"product_name"`
	Description      string     `json:"description"`
	ParentCategory   string     `json:"parent_category"`
	Category         string     `json:"category"`
	Subcategory      string     `json:"subcategory"`
	Origin           string     `json:"origin"`
	Unit             string     `json:"unit"`
	QuantityPerUnit  float64    `json:"quantity_per_unit"`
	PriceTrueque     float64    `json:"price_trueque"`
	BasePrice        float64    `json:"base_price"`
	ExtraCosts       float64    `json:"extra_costs"`
	FinalPrice       float64    `json:"final_price"`
	ExtraDescription string     `json:"extra_description"`
	Stock            int64      `json:"stock"`
	ExternalOpID     *uuid.UUID `json:"external_op_id"`
	OwnerID          string     `json:"owner_id,omitempty"`
	IsService        bool       `json:"is_service"`
}

func (eh *ExternalHandler) addStoreItem(w http.ResponseWriter, r *http.Request) {
	var req AddStoreItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	// Get owner ID from auth context — si no hay, NO crear item con dueño
	// nulo (después ningún chequeo de dueño matchea: toggle/categoría 404)
	ownerIDVal, err := eh.Auth.GetUserID(r)
	if err != nil || ownerIDVal == uuid.Nil {
		writeError(w, 401, "no se pudo determinar el dueño del item")
		return
	}
	ownerID := &ownerIDVal

	// Tienda de organización: si el request indica otro owner (la org),
	// el llamador debe ser board member de esa organización — así la org
	// tiene su propia tienda administrada por sus autorizados.
	if req.OwnerID != "" {
		target, tErr := uuid.Parse(strings.TrimSpace(req.OwnerID))
		if tErr != nil {
			writeError(w, 400, "invalid owner_id")
			return
		}
		if target != ownerIDVal {
			var acctType string
			var isBoard bool
			err := eh.Pool.QueryRow(r.Context(), `
				SELECT COALESCE(u.account_type,''), EXISTS(
					SELECT 1 FROM organization_board_members
					WHERE organization_id = $1 AND user_id = $2 AND COALESCE(is_active, true) = true
				) FROM users u WHERE u.id = $1`, target, ownerIDVal,
			).Scan(&acctType, &isBoard)
			if err != nil || acctType != "organization" || !isBoard {
				writeError(w, 403, "solo miembros del board de la organización pueden gestionar su tienda")
				return
			}
			ownerID = &target
		}
	}

	var productID *uuid.UUID
	if req.ProductID != "" {
		pid, err := uuid.Parse(req.ProductID)
		if err == nil {
			productID = &pid
		}
	}

	// If product_id provided, look up product info from catalog
	productName := req.ProductName
	description := req.Description
	category := req.Category
	origin := req.Origin
	unit := req.Unit
	// quantity_per_unit: cantidad de unidades de venta por presentación (por defecto 1).
	quantityPerUnit := req.QuantityPerUnit
	if quantityPerUnit <= 0 {
		quantityPerUnit = 1
	}
	priceTrueque := req.PriceTrueque
	basePrice := req.BasePrice
	extraCosts := req.ExtraCosts
	finalPrice := req.FinalPrice
	extraDescription := req.ExtraDescription

	if productID != nil {
		var pname, pdesc, pcat, punit, porigin, pBaseUnit string
		var pprice, pPricePerKg, pWeightKg float64
		err := eh.Pool.QueryRow(r.Context(), `
			SELECT
				COALESCE(fed.name, p.name),
				COALESCE(NULLIF(fed.description,''), COALESCE(p.description,'')),
				COALESCE(NULLIF(fed.category,''), p.category),
				COALESCE(NULLIF(fed.unit,''), p.unit),
				COALESCE(p.origin, 'internal'),
				COALESCE(fed.price_per_unit, p.price_per_unit, 0),
				COALESCE(fed.price_per_kg, p.price_per_kg, 0),
				COALESCE(fed.weight_kg, p.weight_kg, 0),
				COALESCE(NULLIF(fed.base_unit,''), NULLIF(p.base_unit,''), 'kg')
			FROM products p
			LEFT JOIN LATERAL (
				SELECT f.name, f.description, f.category, f.unit, f.price_per_unit, f.price_per_kg, f.weight_kg, f.base_unit
				FROM products f
				WHERE f.node_domain = '__FEDERATION__' AND f.is_active = true
				  AND (
				    (COALESCE(p.catalog_key, '') <> '' AND f.catalog_key = p.catalog_key)
				    OR (COALESCE(p.product_code, '') <> '' AND f.product_code = p.product_code)
				    OR LOWER(TRIM(f.name)) = LOWER(TRIM(p.name))
				  )
				ORDER BY (f.catalog_key = p.catalog_key) DESC
				LIMIT 1
			) fed ON true
			WHERE p.id = $1`, *productID).Scan(
			&pname, &pdesc, &pcat, &punit, &porigin, &pprice, &pPricePerKg, &pWeightKg, &pBaseUnit)
		if err == nil {
			productName = pname
			if description == "" {
				description = pdesc
			}
			if category == "" {
				category = pcat
			}
			origin = porigin
			if unit == "" {
				unit = punit
			}
			// Derivar precio exacto desde la Federación según unidad y cantidad
			computedCents := db.ComputeVariantPriceCents(pprice, pPricePerKg, pWeightKg, punit, pBaseUnit, unit, quantityPerUnit)
			if computedCents > 0 {
				basePrice = computedCents
				priceTrueque = computedCents + extraCosts
				finalPrice = priceTrueque
			}
		}
	}

	// Calcular precio final si no se envio: base + extras
	if finalPrice == 0 {
		if basePrice == 0 {
			basePrice = priceTrueque
		}
		finalPrice = basePrice + extraCosts
	}
	// Asegurar que price_trueque (compat) = finalPrice
	if priceTrueque == 0 {
		priceTrueque = finalPrice
	}

	if productName == "" {
		writeError(w, 400, "product_name or product_id required")
		return
	}

	item, err := eh.Store.AddItem(r.Context(), external.AddStoreItemParams{
		OwnerID:          ownerID,
		ProductID:        productID,
		ProductName:      productName,
		Description:      description,
		ParentCategory:   req.ParentCategory,
		Category:         category,
		Subcategory:      req.Subcategory,
		Origin:           origin,
		Unit:             unit,
		QuantityPerUnit:  quantityPerUnit,
		PriceTrueque:     priceTrueque,
		BasePrice:        basePrice,
		ExtraCosts:       extraCosts,
		FinalPrice:       finalPrice,
		ExtraDescription: extraDescription,
		Stock:            req.Stock,
		ExternalOpID:     req.ExternalOpID,
		IsService:        req.IsService,
	})
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}
	registerEntityFields(r.Context(), eh.Pool, item.NodeDomain, "store_item", item.ID.String(), map[string]string{
		"product_name": item.ProductName, "description": item.Description, "extra_description": item.ExtraDescription,
	}, map[string]interface{}{"label": item.ProductName})
	writeJSON(w, 201, item)
}

func (eh *ExternalHandler) getStoreItem(w http.ResponseWriter, r *http.Request) {
	itemID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid item id")
		return
	}

	item, err := eh.Store.GetItem(r.Context(), itemID)
	if err != nil {
		writeError(w, 404, err.Error())
		return
	}
	writeJSON(w, 200, item)
}

type UpdateStockRequest struct {
	Delta int64 `json:"delta"`
}

func (eh *ExternalHandler) updateStock(w http.ResponseWriter, r *http.Request) {
	itemID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid item id")
		return
	}

	var req UpdateStockRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	if err := eh.Store.UpdateStock(r.Context(), itemID, req.Delta); err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "updated"})
}

type UpdatePriceRequest struct {
	NewPrice int64 `json:"new_price"`
}

func (eh *ExternalHandler) updatePrice(w http.ResponseWriter, r *http.Request) {
	itemID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid item id")
		return
	}

	var req UpdatePriceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	if err := eh.Store.UpdatePrice(r.Context(), itemID, req.NewPrice); err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "updated"})
}

func (eh *ExternalHandler) deactivateStoreItem(w http.ResponseWriter, r *http.Request) {
	itemID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid item id")
		return
	}

	if err := eh.Store.DeactivateItem(r.Context(), itemID); err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "deactivated"})
}

// listStoreCategories lista las categorías propias del dueño (o de la org
// que administra). El dueño las crea y luego asigna items por nombre.
func (eh *ExternalHandler) listStoreCategories(w http.ResponseWriter, r *http.Request) {
	userID, err := eh.Auth.GetUserID(r)
	if err != nil || userID == uuid.Nil {
		writeError(w, 401, "authentication required")
		return
	}
	// Une: categorías creadas + categorías ya usadas por los items del dueño
	// (incluyendo multi-categorías en si.categories y vista admin del nodo)
	rows, err := eh.Pool.Query(r.Context(), `
		WITH is_admin AS (
			SELECT EXISTS(
				SELECT 1 FROM users
				WHERE id = $1 AND (COALESCE(is_super_admin, false) = true OR role IN ('admin', 'super_admin'))
			) AS val
		)
		SELECT DISTINCT ON (name) id, name, src, show_in_pos FROM (
			SELECT sc.id, sc.name, 'created' AS src, COALESCE(sc.show_in_pos, true) AS show_in_pos, 1 AS prio
			FROM store_categories sc, is_admin ia
			WHERE sc.owner_id = $1
			   OR ia.val = true
			   OR sc.owner_id IN (SELECT organization_id FROM organization_board_members
			                      WHERE user_id = $1 AND COALESCE(is_active, true) = true)
			UNION ALL
			SELECT NULL::uuid, si.category, 'items', COALESCE(sc2.show_in_pos, true), 2 AS prio
			FROM store_items si
			CROSS JOIN is_admin ia
			LEFT JOIN store_categories sc2
			       ON sc2.owner_id = COALESCE(si.owner_id, $1) AND sc2.name = si.category
			WHERE (si.owner_id = $1 OR si.owner_id IS NULL OR ia.val = true
			   OR si.owner_id IN (SELECT organization_id FROM organization_board_members
			                      WHERE user_id = $1 AND COALESCE(is_active, true) = true))
			  AND COALESCE(si.category, '') <> ''
			  AND si.is_active = true
			UNION ALL
			SELECT NULL::uuid, TRIM(cat_elem), 'items', COALESCE(sc_arr.show_in_pos, true), 2 AS prio
			FROM store_items si_arr
			CROSS JOIN is_admin ia
			CROSS JOIN LATERAL unnest(COALESCE(si_arr.categories, ARRAY[]::text[])) AS cat_elem
			LEFT JOIN store_categories sc_arr
			       ON sc_arr.owner_id = COALESCE(si_arr.owner_id, $1) AND sc_arr.name = TRIM(cat_elem)
			WHERE (si_arr.owner_id = $1 OR si_arr.owner_id IS NULL OR ia.val = true
			   OR si_arr.owner_id IN (SELECT organization_id FROM organization_board_members
			                          WHERE user_id = $1 AND COALESCE(is_active, true) = true))
			  AND TRIM(cat_elem) <> ''
			  AND si_arr.is_active = true
			UNION ALL
			SELECT NULL::uuid, p.category, 'universal', COALESCE(sc3.show_in_pos, true), 3 AS prio
			FROM products p
			LEFT JOIN store_categories sc3
			       ON sc3.owner_id = $1 AND sc3.name = p.category
			WHERE COALESCE(p.is_universal_service, false) = true
			  AND COALESCE(p.category, '') <> ''
			UNION ALL
			SELECT NULL::uuid, p2.category, 'items', true, 4 AS prio
			FROM store_items si2
			CROSS JOIN is_admin ia
			JOIN products p2 ON p2.id = si2.product_id
			WHERE (si2.owner_id = $1 OR si2.owner_id IS NULL OR ia.val = true
			   OR si2.owner_id IN (SELECT organization_id FROM organization_board_members
			                      WHERE user_id = $1 AND COALESCE(is_active, true) = true))
			  AND COALESCE(si2.category, '') = ''
			  AND COALESCE(p2.category, '') <> ''
			  AND si2.is_active = true
		) all_cats
		ORDER BY name, prio`, userID,
	)
	if err != nil {
		writeError(w, 500, "failed to list categories")
		return
	}
	defer rows.Close()
	cats := []map[string]interface{}{}
	for rows.Next() {
		var id *uuid.UUID
		var name, src string
		var showInPos bool
		if rows.Scan(&id, &name, &src, &showInPos) == nil {
			entry := map[string]interface{}{"name": name, "source": src, "show_in_pos": showInPos}
			if id != nil {
				entry["id"] = id.String()
			}
			cats = append(cats, entry)
		}
	}
	writeJSON(w, 200, cats)
}

// createStoreCategory crea una categoría propia del dueño — aparece en la
// lista para asignarla a productos y el POS la replica cuando tiene items.
func (eh *ExternalHandler) createStoreCategory(w http.ResponseWriter, r *http.Request) {
	userID, err := eh.Auth.GetUserID(r)
	if err != nil || userID == uuid.Nil {
		writeError(w, 401, "authentication required")
		return
	}
	var req struct {
		Name    string `json:"name"`
		OwnerID string `json:"owner_id"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	name := strings.TrimSpace(req.Name)
	if name == "" {
		writeError(w, 400, "nombre requerido")
		return
	}
	ownerID := userID
	if req.OwnerID != "" {
		if t, e := uuid.Parse(req.OwnerID); e == nil && t != userID {
			var ok bool
			_ = eh.Pool.QueryRow(r.Context(), `
				SELECT EXISTS(SELECT 1 FROM organization_board_members
					WHERE organization_id = $1 AND user_id = $2 AND COALESCE(is_active, true) = true)`,
				t, userID,
			).Scan(&ok)
			if ok {
				ownerID = t
			}
		}
	}
	var id uuid.UUID
	err = eh.Pool.QueryRow(r.Context(), `
		INSERT INTO store_categories (node_domain, owner_id, name)
		VALUES ($1, $2, $3)
		ON CONFLICT (owner_id, name) DO UPDATE SET name = EXCLUDED.name
		RETURNING id`, eh.NodeDomain, ownerID, name,
	).Scan(&id)
	if err != nil {
		writeError(w, 500, "failed to create category")
		return
	}
	writeJSON(w, 201, map[string]interface{}{"id": id.String(), "name": name})
}

// deleteStoreCategory elimina una categoría propia (los items conservan su
// texto de categoría — la categoría solo desaparece de la lista).
func (eh *ExternalHandler) deleteStoreCategory(w http.ResponseWriter, r *http.Request) {
	userID, err := eh.Auth.GetUserID(r)
	if err != nil || userID == uuid.Nil {
		writeError(w, 401, "authentication required")
		return
	}
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid id")
		return
	}
	res, err := eh.Pool.Exec(r.Context(), `
		DELETE FROM store_categories
		WHERE id = $1 AND (owner_id = $2
		   OR owner_id IN (SELECT organization_id FROM organization_board_members
		                   WHERE user_id = $2 AND COALESCE(is_active, true) = true))`,
		id, userID,
	)
	if err != nil || res.RowsAffected() == 0 {
		writeError(w, 404, "categoría no encontrada")
		return
	}
	writeJSON(w, 200, map[string]interface{}{"status": "deleted"})
}

// toggleCategoryVisibility marca si una categoría aparece en el POS.
// Hace UPSERT en store_categories — sirve tanto para categorías creadas
// como para las traídas del catálogo (inserta la fila si no existía).
func (eh *ExternalHandler) toggleCategoryVisibility(w http.ResponseWriter, r *http.Request) {
	userID, err := eh.Auth.GetUserID(r)
	if err != nil || userID == uuid.Nil {
		writeError(w, 401, "authentication required")
		return
	}
	var req struct {
		Name      string `json:"name"`
		ShowInPos bool   `json:"show_in_pos"`
		OwnerID   string `json:"owner_id"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	name := strings.TrimSpace(req.Name)
	if name == "" {
		writeError(w, 400, "name requerido")
		return
	}
	ownerID := userID
	if req.OwnerID != "" {
		if t, e := uuid.Parse(req.OwnerID); e == nil && t != userID {
			var ok bool
			_ = eh.Pool.QueryRow(r.Context(), `
				SELECT EXISTS(SELECT 1 FROM organization_board_members
					WHERE organization_id = $1 AND user_id = $2 AND COALESCE(is_active, true) = true)`,
				t, userID,
			).Scan(&ok)
			if ok {
				ownerID = t
			}
		}
	}
	// Upsert: si la categoría viene del catálogo (sin fila propia), la crea
	// con la visibilidad elegida — funciona para ambas fuentes.
	_, err = eh.Pool.Exec(r.Context(), `
		INSERT INTO store_categories (node_domain, owner_id, name, show_in_pos)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (owner_id, name)
		DO UPDATE SET show_in_pos = $4, created_at = store_categories.created_at`,
		eh.NodeDomain, ownerID, name, req.ShowInPos,
	)
	if err != nil {
		writeError(w, 500, "failed to update category visibility")
		return
	}
	writeJSON(w, 200, map[string]interface{}{"status": "updated", "show_in_pos": req.ShowInPos})
}

// ensureStoreItemFromProduct materializa automáticamente una fila en store_items si el ID
// recibido corresponde a un producto del catálogo o servicio universal que aún no tenía
// fila propia en store_items, evitando errores 404 al editar o asignar categoría.
func (eh *ExternalHandler) ensureStoreItemFromProduct(ctx context.Context, itemOrProductID, userID uuid.UUID) uuid.UUID {
	var existingID uuid.UUID
	// 1. Verificar si ya existe por store_items.id
	if err := eh.Pool.QueryRow(ctx, `SELECT id FROM store_items WHERE id = $1`, itemOrProductID).Scan(&existingID); err == nil {
		return existingID
	}
	// 2. Verificar si existe por product_id para este usuario o en la tienda del nodo
	if err := eh.Pool.QueryRow(ctx, `
		SELECT id FROM store_items
		WHERE product_id = $1 AND is_active = true
		ORDER BY (owner_id = $2) DESC, created_at ASC
		LIMIT 1`, itemOrProductID, userID).Scan(&existingID); err == nil {
		return existingID
	}
	// 3. Si es un producto válido en products, crear su fila en store_items con id = itemOrProductID
	var pname, pdesc, pparent, pcat, psub, punit, porigin, pcode string
	var pprice float64
	var isUniv, isServ bool
	err := eh.Pool.QueryRow(ctx, `
		SELECT name, COALESCE(description,''), COALESCE(parent_category,''), COALESCE(category,''),
		       COALESCE(subcategory,''), COALESCE(unit,'unidad'), COALESCE(origin,'internal'),
		       COALESCE(item_code,''), COALESCE(price_per_unit,0),
		       COALESCE(is_universal_service,false), (COALESCE(item_type,'') = 'service' OR COALESCE(is_universal_service,false) = true)
		FROM products WHERE id = $1`, itemOrProductID,
	).Scan(&pname, &pdesc, &pparent, &pcat, &psub, &punit, &porigin, &pcode, &pprice, &isUniv, &isServ)
	if err != nil {
		return itemOrProductID
	}
	_, _ = eh.Pool.Exec(ctx, `
		INSERT INTO store_items (
			id, node_domain, owner_id, product_id, item_code, product_name, description,
			parent_category, category, subcategory, origin, unit, quantity_per_unit,
			price_trueque, base_price, extra_costs, final_price, stock, is_active, show_in_pos, is_service
		) VALUES (
			$1, $2, $3, $1, NULLIF($4,''), $5, $6,
			$7, $8, $9, $10, $11, 1,
			$12, $12, 0, $12, 0, true, true, $13
		) ON CONFLICT (id) DO NOTHING`,
		itemOrProductID, eh.NodeDomain, userID, pcode, pname, pdesc,
		pparent, pcat, psub, porigin, punit, int64(math.Round(pprice)), isServ,
	)
	return itemOrProductID
}

// updateStoreItem edita un item de la tienda: nombre, categoría, unidad,
// cantidad por unidad (ej: saco = 25 kg → vender 1 kg divide el precio),
// precio, stock y modo ilimitado (is_service). Solo el dueño, board o admin del nodo.
func (eh *ExternalHandler) updateStoreItem(w http.ResponseWriter, r *http.Request) {
	userID, err := eh.Auth.GetUserID(r)
	if err != nil || userID == uuid.Nil {
		writeError(w, 401, "authentication required")
		return
	}
	itemID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid item id")
		return
	}
	itemID = eh.ensureStoreItemFromProduct(r.Context(), itemID, userID)

	var req struct {
		ProductName     string   `json:"product_name"`
		Description     string   `json:"description"`
		Category        string   `json:"category"`
		Categories      []string `json:"categories"`
		ParentCategory  string   `json:"parent_category"`
		Subcategory     string   `json:"subcategory"`
		Unit            string   `json:"unit"`
		QuantityPerUnit *float64 `json:"quantity_per_unit"`
		PriceTrueque    *float64 `json:"price_trueque"`
		ExtraCosts      *float64 `json:"extra_costs"`
		Stock           *int64   `json:"stock"`
		IsService       *bool    `json:"is_service"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	// Multi-categoría: 'category' = primera (compat) + 'categories' = todas
	// Siempre text[] (vacío o con valores) — nil sin tipo causa 500
	categories := req.Categories
	if categories == nil {
		categories = []string{}
	}
	primaryCat := strings.TrimSpace(req.Category)
	if len(req.Categories) > 0 && primaryCat == "" {
		primaryCat = req.Categories[0]
	}
	if primaryCat != "" && len(categories) == 0 {
		categories = []string{primaryCat}
	}
	res, err := eh.Pool.Exec(r.Context(), `
		UPDATE store_items SET
			product_name      = COALESCE(NULLIF($1,''), product_name),
			description       = COALESCE(NULLIF($2,''), description),
			category          = $3,
			categories        = $12,
			parent_category   = COALESCE(NULLIF($4,''), parent_category),
			subcategory       = COALESCE(NULLIF($5,''), subcategory),
			unit              = COALESCE(NULLIF($6,''), unit),
			quantity_per_unit = COALESCE($7, quantity_per_unit),
			price_trueque     = COALESCE($8, price_trueque),
			extra_costs       = COALESCE($9, extra_costs),
			stock             = COALESCE($10, stock),
			is_service        = COALESCE($11, is_service),
			updated_at        = NOW()
		WHERE id = $13 AND (
			owner_id = $14 OR owner_id IS NULL
			OR EXISTS(SELECT 1 FROM users WHERE id = $14 AND (COALESCE(is_super_admin, false) = true OR role IN ('admin', 'super_admin')))
			OR EXISTS(SELECT 1 FROM organization_board_members obm
				WHERE obm.organization_id = store_items.owner_id
				  AND obm.user_id = $14 AND COALESCE(obm.is_active, true) = true)
		)`,
		req.ProductName, req.Description, primaryCat,
		req.ParentCategory, req.Subcategory, req.Unit,
		req.QuantityPerUnit, req.PriceTrueque, req.ExtraCosts, req.Stock, req.IsService,
		categories,
		itemID, userID,
	)
	if err != nil {
		writeError(w, 500, "failed to update item: "+err.Error())
		return
	}
	if res.RowsAffected() == 0 {
		writeError(w, 404, "item not found or you are not the owner")
		return
	}

	// Si el item está vinculado a un producto del catálogo federado, recalcular siempre su
	// precio exacto desde __FEDERATION__ según la unidad y cantidad configuradas.
	_, _ = eh.Pool.Exec(r.Context(), `
		UPDATE store_items si
		SET base_price = compute_federation_variant_price_cents(
				COALESCE(fed.price_per_unit, p.price_per_unit, 0),
				COALESCE(fed.price_per_kg, p.price_per_kg, 0),
				COALESCE(NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
				COALESCE(fed.weight_kg, p.weight_kg, 0),
				COALESCE(NULLIF(fed.base_unit, ''), NULLIF(p.base_unit, ''), 'kg'),
				COALESCE(NULLIF(si.unit, ''), NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
				COALESCE(NULLIF(si.quantity_per_unit, 0), 1)
			),
			price_trueque = compute_federation_variant_price_cents(
				COALESCE(fed.price_per_unit, p.price_per_unit, 0),
				COALESCE(fed.price_per_kg, p.price_per_kg, 0),
				COALESCE(NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
				COALESCE(fed.weight_kg, p.weight_kg, 0),
				COALESCE(NULLIF(fed.base_unit, ''), NULLIF(p.base_unit, ''), 'kg'),
				COALESCE(NULLIF(si.unit, ''), NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
				COALESCE(NULLIF(si.quantity_per_unit, 0), 1)
			) + COALESCE(si.extra_costs, 0),
			final_price = compute_federation_variant_price_cents(
				COALESCE(fed.price_per_unit, p.price_per_unit, 0),
				COALESCE(fed.price_per_kg, p.price_per_kg, 0),
				COALESCE(NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
				COALESCE(fed.weight_kg, p.weight_kg, 0),
				COALESCE(NULLIF(fed.base_unit, ''), NULLIF(p.base_unit, ''), 'kg'),
				COALESCE(NULLIF(si.unit, ''), NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
				COALESCE(NULLIF(si.quantity_per_unit, 0), 1)
			) + COALESCE(si.extra_costs, 0)
		FROM products p
		LEFT JOIN LATERAL (
			SELECT f.price_per_unit, f.price_per_kg, f.unit, f.weight_kg, f.base_unit
			FROM products f
			WHERE f.node_domain = '__FEDERATION__' AND f.is_active = true
			  AND (
			    (COALESCE(p.catalog_key, '') <> '' AND f.catalog_key = p.catalog_key)
			    OR (COALESCE(p.product_code, '') <> '' AND f.product_code = p.product_code)
			    OR LOWER(TRIM(f.name)) = LOWER(TRIM(p.name))
			  )
			ORDER BY (f.catalog_key = p.catalog_key) DESC
			LIMIT 1
		) fed ON true
		WHERE si.id = $1 AND si.product_id = p.id`, itemID)

	writeJSON(w, 200, map[string]interface{}{"status": "updated"})
}

// updateItemCategory cambia la categoría de un item — el dueño organiza su
// tienda en categorías propias que el POS replica automáticamente.
func (eh *ExternalHandler) updateItemCategory(w http.ResponseWriter, r *http.Request) {
	userID, err := eh.Auth.GetUserID(r)
	if err != nil || userID == uuid.Nil {
		writeError(w, 401, "authentication required")
		return
	}
	itemID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid item id")
		return
	}
	itemID = eh.ensureStoreItemFromProduct(r.Context(), itemID, userID)

	var req struct {
		Category       string `json:"category"`
		ParentCategory string `json:"parent_category"`
		Subcategory    string `json:"subcategory"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}
	cat := strings.TrimSpace(req.Category)
	cats := []string{}
	if cat != "" {
		cats = []string{cat}
	}
	res, err := eh.Pool.Exec(r.Context(), `
		UPDATE store_items
		SET category = $1,
		    categories = CASE WHEN $1 = '' THEN ARRAY[]::text[] ELSE $6 END,
		    parent_category = COALESCE(NULLIF($2,''), parent_category),
		    subcategory = COALESCE(NULLIF($3,''), subcategory),
		    updated_at = NOW()
		WHERE id = $4 AND (
			owner_id = $5 OR owner_id IS NULL
			OR EXISTS(SELECT 1 FROM users WHERE id = $5 AND (COALESCE(is_super_admin, false) = true OR role IN ('admin', 'super_admin')))
			OR EXISTS(SELECT 1 FROM organization_board_members obm
				WHERE obm.organization_id = store_items.owner_id
				  AND obm.user_id = $5 AND COALESCE(obm.is_active, true) = true)
		)`,
		cat, strings.TrimSpace(req.ParentCategory), strings.TrimSpace(req.Subcategory), itemID, userID, cats,
	)
	if err != nil {
		writeError(w, 500, "failed to update category")
		return
	}
	if res.RowsAffected() == 0 {
		writeError(w, 404, "item not found or you are not the owner")
		return
	}
	writeJSON(w, 200, map[string]interface{}{"status": "updated"})
}

// togglePosVisibility marca si un item de la tienda del dueño aparece en el
// catálogo del punto de venta (show_in_pos). Solo el dueño o admin puede cambiarlo.
func (eh *ExternalHandler) togglePosVisibility(w http.ResponseWriter, r *http.Request) {
	itemID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid item id")
		return
	}
	userID, err := getUserID(r)
	if err != nil && eh.Auth != nil {
		userID, err = eh.Auth.GetUserID(r)
	}
	if err != nil || userID == uuid.Nil {
		writeError(w, 401, "not authenticated")
		return
	}
	itemID = eh.ensureStoreItemFromProduct(r.Context(), itemID, userID)

	var req struct {
		ShowInPos bool `json:"show_in_pos"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	res, err := eh.Pool.Exec(r.Context(), `
		UPDATE store_items SET show_in_pos = $1, updated_at = NOW()
		WHERE id = $2 AND (
			owner_id = $3 OR owner_id IS NULL
			OR EXISTS(SELECT 1 FROM users WHERE id = $3 AND (COALESCE(is_super_admin, false) = true OR role IN ('admin', 'super_admin')))
			OR EXISTS(
				SELECT 1 FROM organization_board_members obm
				WHERE obm.organization_id = store_items.owner_id
				  AND obm.user_id = $3 AND COALESCE(obm.is_active, true) = true
			)
		)`,
		req.ShowInPos, itemID, userID,
	)
	if err != nil {
		writeError(w, 500, "failed to update visibility")
		return
	}
	if res.RowsAffected() == 0 {
		writeError(w, 404, "item not found or you are not the owner")
		return
	}
	writeJSON(w, 200, map[string]interface{}{
		"status":      "updated",
		"show_in_pos": req.ShowInPos,
	})
}

type PurchaseRequest struct {
	ItemID   uuid.UUID `json:"item_id"`
	BuyerID  uuid.UUID `json:"buyer_id"`
	Quantity int64     `json:"quantity"`
}

func (eh *ExternalHandler) purchase(w http.ResponseWriter, r *http.Request) {
	var req PurchaseRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	purchase, err := eh.Store.Purchase(r.Context(), req.ItemID, req.BuyerID, req.Quantity)
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, purchase)
}

// ============ PRODUCTOS COMPUESTOS ============

type CompositeComponent struct {
	ComponentProductID  string  `json:"component_product_id"`
	ComponentName       string  `json:"component_name"`
	ComponentUnit       string  `json:"component_unit"`
	ComponentPrice      float64 `json:"component_price"`
	Quantity            float64 `json:"quantity"`
	ComponentCategory   string  `json:"component_category"`
	ComponentCatalogKey string  `json:"component_catalog_key"`
}

type AddCompositeItemRequest struct {
	ProductName     string               `json:"product_name"`
	Description     string               `json:"description"`
	ParentCategory  string               `json:"parent_category"`
	Category        string               `json:"category"`
	Subcategory     string               `json:"subcategory"`
	Unit            string               `json:"unit"`
	QuantityPerUnit float64              `json:"quantity_per_unit"`
	Stock           int64                `json:"stock"`
	Components      []CompositeComponent `json:"components"`
}

func (eh *ExternalHandler) addCompositeItem(w http.ResponseWriter, r *http.Request) {
	var req AddCompositeItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, 400, "invalid request body")
		return
	}

	if len(req.Components) == 0 {
		writeError(w, 400, "debe agregar al menos un componente")
		return
	}

	ownerIDVal, err := eh.Auth.GetUserID(r)
	if err != nil || ownerIDVal == uuid.Nil {
		writeError(w, 401, "no se pudo determinar el dueño del item")
		return
	}
	var ownerID *uuid.UUID
	if ownerIDVal != uuid.Nil {
		ownerID = &ownerIDVal
	}

	// Calcular precio total sumando componentes
	var totalPrice float64
	compositeDesc := ""
	for i := range req.Components {
		c := &req.Components[i]
		// Verificar que el componente existe y esta aprobado.
		// Los componentes viven en el catalogo federado (__FEDERATION__) o son
		// compuestos locales aprobados (__LOCAL__).
		if c.ComponentProductID != "" {
			pid, err := uuid.Parse(c.ComponentProductID)
			if err == nil {
				var pname, punit, pCatalogKey, pItemType string
				var pprice float64
				var pApproved bool
				err := eh.Pool.QueryRow(r.Context(),
					`SELECT name, unit, price_per_unit, is_approved, COALESCE(catalog_key,''), COALESCE(item_type,'')
					 FROM products WHERE id = $1 AND is_active = true
					   AND (node_domain = '__FEDERATION__'
					        OR (node_domain IN ($2,'localhost','default') AND COALESCE(is_composite,false) = true))`,
					pid, db.LOCAL_NODE_DOMAIN).Scan(&pname, &punit, &pprice, &pApproved, &pCatalogKey, &pItemType)
				if err != nil {
					writeError(w, 400, "componente no encontrado: "+c.ComponentName)
					return
				}
				if !pApproved {
					writeError(w, 400, "componente no aprobado: "+pname)
					return
				}
				// Usar precio del catalogo, no el enviado por el cliente
				c.ComponentPrice = pprice
				c.ComponentName = pname
				c.ComponentUnit = punit
				c.ComponentCatalogKey = pCatalogKey
				// Clasificar por item_type (metadata del catalogo, no heuristica de texto)
				switch pItemType {
				case "service":
					c.ComponentCategory = "trabajo"
				case "packaging":
					c.ComponentCategory = "embalaje"
				case "shipping":
					c.ComponentCategory = "envio"
				case "base_product", "composite":
					c.ComponentCategory = "producto_base"
				case "raw_material":
					c.ComponentCategory = "materia_prima"
				}
			}
		}
		subtotal := c.ComponentPrice * c.Quantity
		totalPrice += subtotal
		if compositeDesc != "" {
			compositeDesc += ", "
		}
		compositeDesc += fmt.Sprintf("%s x%.4f (%.2f TQ)", c.ComponentName, c.Quantity, subtotal/100.0)
	}
	totalPrice = math.Round(totalPrice)

	// Publicar automáticamente el producto compuesto en el nodo local y en la Federación (__FEDERATION__)
	// para que su precio y composición vivan en la Federación como fuente única de verdad.
	var compProdIDPtr *uuid.UUID
	compUnit := strings.TrimSpace(req.Unit)
	if compUnit == "" {
		compUnit = "unidad"
	}
	compQty := req.QuantityPerUnit
	if compQty <= 0 {
		compQty = 1
	}
	catKey := db.CatalogItemSlug(req.ProductName)
	var compProdID uuid.UUID
	err = eh.Pool.QueryRow(r.Context(), `
		INSERT INTO products (
			node_domain, catalog_key, name, description, parent_category, category, subcategory,
			origin, unit, base_unit, weight_kg, price_per_kg, price_per_unit,
			is_composite, item_type, is_approved, is_active, created_by
		) VALUES (
			$1, $2, $3, $4, COALESCE(NULLIF($5,''), 'Transformacion'), COALESCE(NULLIF($6,''), 'General'), $7,
			'internal', $8, $8, $9, ROUND(($10::numeric / 100.0) / GREATEST($9::numeric, 0.0001), 4), $10,
			true, 'composite', true, true, $11
		)
		RETURNING id`,
		eh.NodeDomain, catKey, req.ProductName,
		func() string {
			if strings.TrimSpace(req.Description) != "" {
				return req.Description
			}
			return compositeDesc
		}(),
		req.ParentCategory, req.Category, req.Subcategory,
		compUnit, compQty, totalPrice, ownerID,
	).Scan(&compProdID)
	if err == nil && compProdID != uuid.Nil {
		compProdIDPtr = &compProdID
	}

	// Crear el store item con el precio calculado y vinculado al producto de la Federación
	item, err := eh.Store.AddItem(r.Context(), external.AddStoreItemParams{
		OwnerID:          ownerID,
		ProductID:        compProdIDPtr,
		ProductName:      req.ProductName,
		Description:      req.Description,
		ParentCategory:   req.ParentCategory,
		Category:         req.Category,
		Subcategory:      req.Subcategory,
		Origin:           "internal",
		Unit:             compUnit,
		QuantityPerUnit:  compQty,
		PriceTrueque:     totalPrice,
		BasePrice:        totalPrice,
		ExtraCosts:       0,
		FinalPrice:       totalPrice,
		ExtraDescription: compositeDesc,
		Stock:            req.Stock,
	})
	if err != nil {
		writeError(w, 400, err.Error())
		return
	}
	registerEntityFields(r.Context(), eh.Pool, item.NodeDomain, "store_item", item.ID.String(), map[string]string{
		"product_name": item.ProductName, "description": item.Description, "extra_description": item.ExtraDescription,
	}, map[string]interface{}{"label": item.ProductName})

	// Guardar la composicion en el store_item y en el producto base
	for i, c := range req.Components {
		var componentID *uuid.UUID
		if c.ComponentProductID != "" {
			pid, err := uuid.Parse(c.ComponentProductID)
			if err == nil {
				componentID = &pid
			}
		}
		subtotal := c.ComponentPrice * c.Quantity
		_, _ = eh.Pool.Exec(r.Context(),
			`INSERT INTO product_compositions (product_id, product_type, component_product_id, component_catalog_key, component_name, component_unit, component_price, quantity, subtotal, component_category, sort_order)
			 VALUES ($1, 'store_item', $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
			item.ID, componentID, c.ComponentCatalogKey, c.ComponentName, c.ComponentUnit, c.ComponentPrice, c.Quantity, subtotal, c.ComponentCategory, i)
		if compProdIDPtr != nil {
			_, _ = eh.Pool.Exec(r.Context(),
				`INSERT INTO product_compositions (product_id, product_type, component_product_id, component_catalog_key, component_name, component_unit, component_price, quantity, subtotal, component_category, sort_order)
				 VALUES ($1, 'product', $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
				*compProdIDPtr, componentID, c.ComponentCatalogKey, c.ComponentName, c.ComponentUnit, c.ComponentPrice, c.Quantity, subtotal, c.ComponentCategory, i)
		}
	}

	if compProdIDPtr != nil {
		_, _ = db.UpsertProductToFederation(r.Context(), eh.Pool, *compProdIDPtr)
	}

	writeJSON(w, 201, map[string]interface{}{
		"item":        item,
		"total_price": totalPrice,
		"composition": compositeDesc,
		"components":  req.Components,
	})
}

func (eh *ExternalHandler) getComposition(w http.ResponseWriter, r *http.Request) {
	productID, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		writeError(w, 400, "invalid product id")
		return
	}

	rows, err := eh.Pool.Query(r.Context(),
		`SELECT id, component_product_id, component_name, component_unit, component_price, quantity, subtotal, component_category, sort_order
		 FROM product_compositions
		 WHERE product_id = $1
		 ORDER BY sort_order`, productID)
	if err != nil {
		writeJSON(w, 200, []interface{}{})
		return
	}
	defer rows.Close()

	components := []map[string]interface{}{}
	for rows.Next() {
		var id string
		var componentProductID *uuid.UUID
		var name, unit, category string
		var price float64
		var quantity float64
		var subtotal float64
		var sortOrder int
		_ = rows.Scan(&id, &componentProductID, &name, &unit, &price, &quantity, &subtotal, &category, &sortOrder)

		cpID := ""
		if componentProductID != nil {
			cpID = componentProductID.String()
		}
		components = append(components, map[string]interface{}{
			"id":                   id,
			"component_product_id": cpID,
			"component_name":       name,
			"component_unit":       unit,
			"component_price":      price,
			"quantity":             quantity,
			"subtotal":             subtotal,
			"component_category":   category,
		})
	}
	writeJSON(w, 200, components)
}

func (eh *ExternalHandler) listComponents(w http.ResponseWriter, r *http.Request) {
	// Usar el dominio del header (enviado por el frontend) como prioridad
	nodeDomain := r.Header.Get("X-Node-Domain")
	if nodeDomain == "" {
		nodeDomain = eh.NodeDomain
	}
	nodeDomain = db.ResolveNodeDomain(r.Context(), eh.Pool, nodeDomain, eh.NodeDomain)
	// Listar productos que pueden ser usados como componentes
	// materias primas, productos base aprobados, trabajo, embalaje, envio
	// Incluye items individuales dentro de grupos (group_id no nulo)
	// y productos que no son grupos ni pertenecen a un grupo
	category := r.URL.Query().Get("category")
	if category == "" {
		category = "all"
	}
	search := strings.ToLower(strings.TrimSpace(r.URL.Query().Get("search")))

	// Componentes elegibles: catalogo federado (__FEDERATION__) + compuestos
	// locales aprobados. La clasificacion usa item_type, no texto de categoria.
	query := `SELECT id, name, parent_category, category, subcategory, unit, price_per_unit, description, badge, image_url, group_id,
		COALESCE(catalog_key,''), COALESCE(item_type,'product'), node_domain
		FROM products
		WHERE is_approved = true AND is_active = true AND is_hidden = false AND COALESCE(is_group, false) = false
		  AND (node_domain = '__FEDERATION__'
		       OR (node_domain IN ($1, 'localhost', 'default') AND COALESCE(is_composite, false) = true))`
	args := []interface{}{nodeDomain}
	argIdx := 2

	switch category {
	case "materia_prima":
		query += ` AND item_type = 'raw_material' AND node_domain = '__FEDERATION__'`
	case "producto_base":
		query += ` AND (item_type = 'base_product' OR COALESCE(is_composite, false) = true)`
	case "trabajo":
		query += ` AND item_type = 'service'`
	case "embalaje":
		query += ` AND item_type = 'packaging'`
	case "envio":
		query += ` AND item_type = 'shipping'`
	}

	if search != "" {
		query += fmt.Sprintf(` AND (LOWER(name) LIKE $%d OR LOWER(description) LIKE $%d OR LOWER(category) LIKE $%d OR LOWER(parent_category) LIKE $%d)`,
			argIdx, argIdx, argIdx, argIdx)
		args = append(args, "%"+search+"%")
		argIdx++
	}

	query += ` ORDER BY parent_category, category, name`

	rows, err := eh.Pool.Query(r.Context(), query, args...)
	if err != nil {
		writeJSON(w, 200, []interface{}{})
		return
	}
	defer rows.Close()

	components := []map[string]interface{}{}
	for rows.Next() {
		var id, name, parentCategory, cat, subcat, unit, description, catalogKey, itemType, rowDomain string
		var price float64
		var badge, imageURL *string
		var groupID *string
		_ = rows.Scan(&id, &name, &parentCategory, &cat, &subcat, &unit, &price, &description, &badge, &imageURL, &groupID, &catalogKey, &itemType, &rowDomain)

		bdg := ""
		if badge != nil {
			bdg = *badge
		}
		imgURL := ""
		if imageURL != nil {
			imgURL = *imageURL
		}
		gid := ""
		if groupID != nil {
			gid = *groupID
		}

		components = append(components, map[string]interface{}{
			"id":              id,
			"name":            name,
			"parent_category": parentCategory,
			"category":        cat,
			"subcategory":     subcat,
			"unit":            unit,
			"price_per_unit":  price,
			"description":     description,
			"badge":           bdg,
			"image_url":       imgURL,
			"group_id":        gid,
			"catalog_key":     catalogKey,
			"item_type":       itemType,
			"node_domain":     rowDomain,
		})
	}
	lang, fallbackLang := resolveRequestLanguages(r, eh.Pool, nodeDomain)
	localizeEntityMaps(r.Context(), eh.Pool, components, "product", lang, fallbackLang, "name", "description", "badge", "unit")
	writeJSON(w, 200, components)
}
