package external

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Store struct {
	Pool       *pgxpool.Pool
	NodeDomain string
}

func NewStore(pool *pgxpool.Pool, nodeDomain string) *Store {
	return &Store{Pool: pool, NodeDomain: nodeDomain}
}

type StoreItem struct {
	ID                 uuid.UUID  `json:"id"`
	NodeDomain         string     `json:"node_domain"`
	OwnerID            *uuid.UUID `json:"owner_id"`
	OwnerName          string     `json:"owner_name"`
	ProductID          *uuid.UUID `json:"product_id"`
	ItemCode           string     `json:"item_code"`
	ProductName        string     `json:"product_name"`
	Description        string     `json:"description"`
	ParentCategory     string     `json:"parent_category"`
	Category           string     `json:"category"`
	Categories         []string   `json:"categories,omitempty"`
	Subcategory        string     `json:"subcategory"`
	Origin             string     `json:"origin"`
	Unit               string     `json:"unit"`
	QuantityPerUnit    float64    `json:"quantity_per_unit"`
	PriceTrueque       float64    `json:"price_trueque"`
	BasePrice          float64    `json:"base_price"`
	ExtraCosts         float64    `json:"extra_costs"`
	FinalPrice         float64    `json:"final_price"`
	ExtraDescription   string     `json:"extra_description"`
	Stock              int64      `json:"stock"`
	IsService          bool       `json:"is_service"`
	IsUniversalService bool       `json:"is_universal_service,omitempty"`
	ShowInPos          bool       `json:"show_in_pos"`
	// Medida del catálogo padre — para dosificar (saco=X kg → precio/kg auto)
	PricePerKg         float64    `json:"price_per_kg"`
	WeightKg           float64    `json:"weight_kg"`
	BaseUnit           string     `json:"base_unit"`
	IsActive           bool       `json:"is_active"`
	ExternalOpID       *uuid.UUID `json:"external_op_id"`
	ImageURL           string     `json:"image_url"`
	ImageIconURL       string     `json:"image_icon_url"`
	CreatedAt          time.Time  `json:"created_at"`
	UpdatedAt          time.Time  `json:"updated_at"`
}

type AddStoreItemParams struct {
	OwnerID          *uuid.UUID
	ProductID        *uuid.UUID
	ItemCode         string
	ProductName      string
	Description      string
	ParentCategory   string
	Category         string
	Subcategory      string
	Origin           string
	Unit             string
	QuantityPerUnit  float64
	PriceTrueque     float64
	BasePrice        float64
	ExtraCosts       float64
	FinalPrice       float64
	ExtraDescription string
	Stock            int64
	IsService        bool
	ImageIconURL     string
	ExternalOpID     *uuid.UUID
}

func (s *Store) AddItem(ctx context.Context, p AddStoreItemParams) (*StoreItem, error) {
	itemCode := strings.TrimSpace(p.ItemCode)
	if itemCode == "" {
		var nextNum int
		_ = s.Pool.QueryRow(ctx, `
			SELECT 10001 + (COUNT(*) % 79998)
			FROM store_items
			WHERE ($1::uuid IS NULL OR owner_id = $1)`, p.OwnerID).Scan(&nextNum)
		if nextNum < 10001 {
			nextNum = 10001
		}
		itemCode = fmt.Sprintf("%05d", nextNum)
	}
	isService := p.IsService
	if !isService {
		u := strings.ToLower(strings.TrimSpace(p.Unit))
		if u == "hora" || u == "jornada" || u == "sesion" || u == "clase" || u == "consulta" || u == "servicio" || u == "taller" || u == "dia" {
			isService = true
		}
	}

	var item StoreItem
	err := s.Pool.QueryRow(ctx, `
		INSERT INTO store_items (node_domain, owner_id, product_id, item_code, product_name, description, parent_category, category, subcategory, origin,
								 unit, quantity_per_unit, price_trueque, base_price, extra_costs, final_price, extra_description,
								 stock, is_service, image_icon_url, is_active, external_op_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, true, $21)
		RETURNING id, node_domain, owner_id, product_id, COALESCE(item_code,''), product_name, description, parent_category, category, subcategory, origin,
				  unit, quantity_per_unit, price_trueque, base_price, extra_costs, final_price, extra_description,
				  stock, COALESCE(is_service,false), COALESCE(image_icon_url,''), is_active, external_op_id, created_at, updated_at`,
		s.NodeDomain, p.OwnerID, p.ProductID, itemCode, p.ProductName, p.Description, p.ParentCategory, p.Category, p.Subcategory, p.Origin,
		p.Unit, p.QuantityPerUnit, p.PriceTrueque, p.BasePrice, p.ExtraCosts, p.FinalPrice, p.ExtraDescription,
		p.Stock, isService, p.ImageIconURL, p.ExternalOpID,
	).Scan(&item.ID, &item.NodeDomain, &item.OwnerID, &item.ProductID, &item.ItemCode, &item.ProductName, &item.Description,
		&item.ParentCategory, &item.Category, &item.Subcategory, &item.Origin, &item.Unit, &item.QuantityPerUnit, &item.PriceTrueque,
		&item.BasePrice, &item.ExtraCosts, &item.FinalPrice, &item.ExtraDescription,
		&item.Stock, &item.IsService, &item.ImageIconURL, &item.IsActive, &item.ExternalOpID, &item.CreatedAt, &item.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("adding store item: %w", err)
	}
	return &item, nil
}

func (s *Store) ListItems(ctx context.Context, category string) ([]StoreItem, error) {
	query := `SELECT si.id, si.node_domain, si.owner_id, si.product_id, COALESCE(si.item_code, ''), si.product_name, si.description, si.parent_category,
			  COALESCE(NULLIF(si.category, ''), si.categories[1], COALESCE(p.category, '')),
			  COALESCE(si.categories, ARRAY[]::text[]),
			  si.subcategory, si.origin,
			  si.unit, si.quantity_per_unit,
		  -- Precio consultado EN VIVO desde __FEDERATION__ (src) mediante divisiones/multiplicaciones exactas por variante
		  CASE WHEN si.product_id IS NOT NULL THEN
		    compute_federation_variant_price_cents(
		      COALESCE(src.price_per_unit, p.price_per_unit, 0),
		      COALESCE(src.price_per_kg, p.price_per_kg, 0),
		      COALESCE(src.weight_kg, p.weight_kg, 0),
		      COALESCE(src.unit, p.unit, 'unidad'),
		      COALESCE(src.base_unit, p.base_unit, 'kg'),
		      si.unit,
		      si.quantity_per_unit
		    )
		  ELSE COALESCE(si.price_trueque,0) END as price_trueque,
		  COALESCE(src.price_per_unit, p.price_per_unit, si.base_price) as base_price,
		  si.extra_costs,
		  CASE WHEN si.product_id IS NOT NULL THEN
		    compute_federation_variant_price_cents(
		      COALESCE(src.price_per_unit, p.price_per_unit, 0),
		      COALESCE(src.price_per_kg, p.price_per_kg, 0),
		      COALESCE(src.weight_kg, p.weight_kg, 0),
		      COALESCE(src.unit, p.unit, 'unidad'),
		      COALESCE(src.base_unit, p.base_unit, 'kg'),
		      si.unit,
		      si.quantity_per_unit
		    ) + COALESCE(si.extra_costs,0)
		  ELSE COALESCE(si.final_price,0) END as final_price,
		  si.extra_description,
			  si.stock, COALESCE(si.is_service, false), COALESCE(si.show_in_pos, true), si.is_active, si.external_op_id, si.created_at, si.updated_at,
			  COALESCE(u.username, '') as owner_name,
			  COALESCE(src.image_url, p.image_url, '') as image_url,
			  COALESCE(NULLIF(si.image_icon_url, ''), COALESCE(src.image_icon_url, ''), COALESCE(p.image_icon_url, ''), COALESCE(src.image_thumb_url, ''), COALESCE(p.image_thumb_url, '')) as image_icon_url,
			  COALESCE(NULLIF(src.price_per_kg, 0), COALESCE(p.price_per_kg, 0)) as price_per_kg,
			  COALESCE(NULLIF(src.weight_kg, 0), COALESCE(p.weight_kg, 0)) as weight_kg,
			  COALESCE(NULLIF(src.base_unit, ''), COALESCE(p.base_unit, 'kg')) as base_unit
			  FROM store_items si
			  LEFT JOIN users u ON si.owner_id = u.id
			  LEFT JOIN products p ON si.product_id = p.id
			  LEFT JOIN LATERAL (
			      SELECT f.id, f.price_per_unit, f.price_per_kg, f.weight_kg, f.unit, f.base_unit, f.image_url, f.image_icon_url, f.image_thumb_url
			      FROM products f
			      WHERE f.node_domain = '__FEDERATION__'
			        AND (
			            (NULLIF(p.catalog_key, '') IS NOT NULL AND f.catalog_key = p.catalog_key)
			            OR (NULLIF(p.product_code, '') IS NOT NULL AND f.product_code = p.product_code)
			            OR LOWER(f.name) = LOWER(p.name)
			        )
			      ORDER BY
			        CASE
			          WHEN NULLIF(p.catalog_key, '') IS NOT NULL AND f.catalog_key = p.catalog_key THEN 1
			          WHEN NULLIF(p.product_code, '') IS NOT NULL AND f.product_code = p.product_code THEN 2
			          ELSE 3
			        END
			      LIMIT 1
			  ) src ON true
			  WHERE si.node_domain = $1 AND si.is_active = true
			    AND (p.id IS NULL OR COALESCE(p.is_allowed, true) = true)`
	args := []interface{}{s.NodeDomain}
	if category != "" {
		query += ` AND (si.parent_category = $2 OR si.category = $2 OR $2 = ANY(COALESCE(si.categories, ARRAY[]::text[])))`
		args = append(args, category)
	}
	query += ` ORDER BY si.product_name ASC`

	rows, err := s.Pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("listing store items: %w", err)
	}
	defer rows.Close()

	var items []StoreItem
	for rows.Next() {
		var item StoreItem
		err := rows.Scan(&item.ID, &item.NodeDomain, &item.OwnerID, &item.ProductID, &item.ItemCode, &item.ProductName, &item.Description,
			&item.ParentCategory, &item.Category, &item.Categories, &item.Subcategory, &item.Origin, &item.Unit, &item.QuantityPerUnit, &item.PriceTrueque,
			&item.BasePrice, &item.ExtraCosts, &item.FinalPrice, &item.ExtraDescription,
			&item.Stock, &item.IsService, &item.ShowInPos, &item.IsActive, &item.ExternalOpID, &item.CreatedAt, &item.UpdatedAt, &item.OwnerName, &item.ImageURL, &item.ImageIconURL,
			&item.PricePerKg, &item.WeightKg, &item.BaseUnit)
		if err != nil {
			return nil, fmt.Errorf("scanning store item: %w", err)
		}
		items = append(items, item)
	}
	return items, nil
}

// ListUniversalServices devuelve los 6 servicios universales de trabajo
// bajo la categoría fija "Trabajo" que están siempre disponibles tanto en Mi Tienda
// como en el Punto de Venta (POS) Android.
func (s *Store) ListUniversalServices(ctx context.Context, ownerID *uuid.UUID, ownerName string) ([]StoreItem, error) {
	rateAdmin, rateTech, rateAgr := 1.00, 1.15, 1.30
	workHours := 8
	var multJSON string
	if err := s.Pool.QueryRow(ctx, `
		SELECT COALESCE(work_multipliers::text,''), COALESCE(workday_hours, 8)
		FROM node_config WHERE node_domain = $1`, s.NodeDomain,
	).Scan(&multJSON, &workHours); err == nil && multJSON != "" {
		var mults map[string]float64
		if json.Unmarshal([]byte(multJSON), &mults) == nil {
			if v := mults["admin"]; v > 0 {
				rateAdmin = v
			}
			if v := mults["tecnico"]; v > 0 {
				rateTech = v
			}
			if v := mults["agricola"]; v > 0 {
				rateAgr = v
			}
			if v := mults["technical"]; v > 0 {
				rateTech = v
			}
			if v := mults["agricultural"]; v > 0 {
				rateAgr = v
			}
		}
	}
	if workHours <= 0 {
		workHours = 8
	}

	type workSvcDef struct {
		id      string
		code    string
		name    string
		desc    string
		subcat  string
		unit    string
		priceTQ float64
	}
	defs := []workSvcDef{
		{
			id:      "00000000-0000-4000-8000-0000000900a1",
			code:    "900a1",
			name:    "Trabajo sedentario / oficina (1 hora)",
			desc:    fmt.Sprintf("Hora de trabajo sedentario, oficina, atención o gestión administrativa (%.2f TQ/hora). Servicio universal disponible en todas las tiendas y puntos de venta.", rateAdmin),
			subcat:  "Oficina y Gestion",
			unit:    "hora",
			priceTQ: rateAdmin,
		},
		{
			id:      "00000000-0000-4000-8000-0000000900a2",
			code:    "900a2",
			name:    "Jornada completa — Trabajo sedentario / oficina",
			desc:    fmt.Sprintf("Jornada completa (%d horas) de trabajo sedentario, oficina, atención o gestión administrativa (%.2f TQ/jornada). Servicio universal.", workHours, rateAdmin*float64(workHours)),
			subcat:  "Oficina y Gestion",
			unit:    "jornada",
			priceTQ: rateAdmin * float64(workHours),
		},
		{
			id:      "00000000-0000-4000-8000-0000000900b1",
			code:    "900t1",
			name:    "Trabajo profesional / especialista (1 hora)",
			desc:    fmt.Sprintf("Hora de trabajo profesional, técnico o especialista calificado (%.2f TQ/hora). Servicio universal disponible en todas las tiendas y puntos de venta.", rateTech),
			subcat:  "Profesional y Tecnico",
			unit:    "hora",
			priceTQ: rateTech,
		},
		{
			id:      "00000000-0000-4000-8000-0000000900b2",
			code:    "900t2",
			name:    "Jornada completa — Trabajo profesional / especialista",
			desc:    fmt.Sprintf("Jornada completa (%d horas) de trabajo profesional, técnico o especialista calificado (%.2f TQ/jornada). Servicio universal.", workHours, rateTech*float64(workHours)),
			subcat:  "Profesional y Tecnico",
			unit:    "jornada",
			priceTQ: rateTech * float64(workHours),
		},
		{
			id:      "00000000-0000-4000-8000-0000000900c1",
			code:    "900g1",
			name:    "Trabajo pesado / agrícola (conuco) (1 hora)",
			desc:    fmt.Sprintf("Hora de trabajo pesado o agrícola en el conuco / Mano Vuelta (%.2f TQ/hora). Servicio universal disponible en todas las tiendas y puntos de venta.", rateAgr),
			subcat:  "Trabajo Agricola y Pesado",
			unit:    "hora",
			priceTQ: rateAgr,
		},
		{
			id:      "00000000-0000-4000-8000-0000000900c2",
			code:    "900g2",
			name:    "Jornada completa — Trabajo pesado / agrícola (conuco)",
			desc:    fmt.Sprintf("Jornada completa (%d horas) de trabajo pesado o agrícola en el conuco / Mano Vuelta (%.2f TQ/jornada). Servicio universal.", workHours, rateAgr*float64(workHours)),
			subcat:  "Trabajo Agricola y Pesado",
			unit:    "jornada",
			priceTQ: rateAgr * float64(workHours),
		},
	}

	// Visibilidad en el POS elegida por el dueño (migración 200)
	hiddenInPos := map[string]bool{}
	if ownerID != nil {
		if hRows, hErr := s.Pool.Query(ctx, `
			SELECT product_id::text FROM store_universal_service_prefs
			WHERE owner_id = $1 AND show_in_pos = false`, *ownerID); hErr == nil {
			for hRows.Next() {
				var hid string
				if hRows.Scan(&hid) == nil {
					hiddenInPos[hid] = true
				}
			}
			hRows.Close()
		}
	}

	now := time.Now()
	list := make([]StoreItem, 0, len(defs))
	for _, d := range defs {
		pid := uuid.MustParse(d.id)
		pidCopy := pid
		priceCents := math.Round(d.priceTQ * 100)
		list = append(list, StoreItem{
			ID:                 pidCopy,
			NodeDomain:         s.NodeDomain,
			OwnerID:            ownerID,
			OwnerName:          ownerName,
			ProductID:          &pidCopy,
			ItemCode:           d.code,
			ProductName:        d.name,
			Description:        d.desc,
			ParentCategory:     "Servicios",
			Category:           "Trabajo",
			Categories:         []string{"Trabajo"},
			Subcategory:        d.subcat,
			Origin:             "internal",
			Unit:               d.unit,
			QuantityPerUnit:    1,
			PriceTrueque:       priceCents,
			BasePrice:          priceCents,
			ExtraCosts:         0,
			FinalPrice:         priceCents,
			PricePerKg:         d.priceTQ,
			WeightKg:           1,
			BaseUnit:           d.unit,
			Stock:              999999,
			IsService:          true,
			IsUniversalService: true,
			ShowInPos:          !hiddenInPos[d.id],
			IsActive:           true,
			CreatedAt:          now,
			UpdatedAt:          now,
		})
	}
	return list, nil
}

func (s *Store) GetItem(ctx context.Context, id uuid.UUID) (*StoreItem, error) {
	var item StoreItem
	err := s.Pool.QueryRow(ctx, `
		SELECT id, node_domain, product_name, description, parent_category, category, subcategory, origin,
			  unit, quantity_per_unit, price_trueque, base_price, extra_costs, final_price, extra_description,
			  stock, is_active, external_op_id, created_at, updated_at
		FROM store_items WHERE id = $1`,
		id,
	).Scan(&item.ID, &item.NodeDomain, &item.ProductName, &item.Description,
		&item.ParentCategory, &item.Category, &item.Subcategory, &item.Origin, &item.Unit, &item.QuantityPerUnit,
		&item.PriceTrueque, &item.BasePrice, &item.ExtraCosts, &item.FinalPrice, &item.ExtraDescription,
		&item.Stock, &item.IsActive, &item.ExternalOpID, &item.CreatedAt, &item.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("getting store item: %w", err)
	}
	return &item, nil
}

func (s *Store) UpdateStock(ctx context.Context, id uuid.UUID, delta int64) error {
	_, err := s.Pool.Exec(ctx, `
		UPDATE store_items SET stock = stock + $2, updated_at = NOW() WHERE id = $1`,
		id, delta,
	)
	if err != nil {
		return fmt.Errorf("updating stock: %w", err)
	}
	return nil
}

func (s *Store) UpdatePrice(ctx context.Context, id uuid.UUID, newPrice int64) error {
	_, err := s.Pool.Exec(ctx, `
		UPDATE store_items SET price_trueque = $2, updated_at = NOW() WHERE id = $1`,
		id, newPrice,
	)
	if err != nil {
		return fmt.Errorf("updating price: %w", err)
	}
	return nil
}

func (s *Store) DeactivateItem(ctx context.Context, id uuid.UUID) error {
	_, err := s.Pool.Exec(ctx, `
		UPDATE store_items SET is_active = false, updated_at = NOW() WHERE id = $1`,
		id,
	)
	if err != nil {
		return fmt.Errorf("deactivating store item: %w", err)
	}
	return nil
}

type StorePurchase struct {
	ID          uuid.UUID `json:"id"`
	StoreItemID uuid.UUID `json:"store_item_id"`
	BuyerID     uuid.UUID `json:"buyer_id"`
	Quantity    int64     `json:"quantity"`
	TotalPrice  int64     `json:"total_price"`
	Status      string    `json:"status"`
	CreatedAt   time.Time `json:"created_at"`
}

func (s *Store) Purchase(ctx context.Context, itemID, buyerID uuid.UUID, quantity int64) (*StorePurchase, error) {
	if quantity <= 0 {
		return nil, fmt.Errorf("quantity must be positive")
	}

	var stock, price int64
	err := s.Pool.QueryRow(ctx,
		`SELECT stock, price_trueque FROM store_items WHERE id = $1 AND is_active = true`,
		itemID,
	).Scan(&stock, &price)
	if err != nil {
		return nil, fmt.Errorf("getting store item: %w", err)
	}

	if stock < quantity {
		return nil, fmt.Errorf("insufficient stock: have %d, want %d", stock, quantity)
	}

	// Verificar que todos los componentes del producto compuesto esten aprobados en este nodo
	// Un producto compuesto solo se puede comprar si todos sus materiales estan aprobados localmente
	rows, err := s.Pool.Query(ctx, `
		SELECT pc.component_product_id, pc.component_name
		FROM product_compositions pc
		WHERE pc.product_id = $1 AND pc.product_type = 'store_item'
		  AND pc.component_product_id IS NOT NULL`,
		itemID)
	if err == nil {
		defer rows.Close()
		var unapproved []string
		for rows.Next() {
			var componentID uuid.UUID
			var componentName string
			_ = rows.Scan(&componentID, &componentName)
			var isApproved bool
			err := s.Pool.QueryRow(ctx, `SELECT is_approved FROM products WHERE id = $1`, componentID).Scan(&isApproved)
			if err != nil || !isApproved {
				unapproved = append(unapproved, componentName)
			}
		}
		if len(unapproved) > 0 {
			return nil, fmt.Errorf("no se puede comprar: los siguientes componentes no estan aprobados en este nodo: %s", strings.Join(unapproved, ", "))
		}
	}

	totalPrice := price * quantity

	var purchase StorePurchase
	err = s.Pool.QueryRow(ctx, `
		INSERT INTO store_purchases (store_item_id, buyer_id, quantity, total_price, status)
		VALUES ($1, $2, $3, $4, 'completed')
		RETURNING id, store_item_id, buyer_id, quantity, total_price, status, created_at`,
		itemID, buyerID, quantity, totalPrice,
	).Scan(&purchase.ID, &purchase.StoreItemID, &purchase.BuyerID, &purchase.Quantity,
		&purchase.TotalPrice, &purchase.Status, &purchase.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("creating purchase: %w", err)
	}

	_, err = s.Pool.Exec(ctx, `
		UPDATE store_items SET stock = stock - $2, updated_at = NOW() WHERE id = $1`,
		itemID, quantity)
	if err != nil {
		return nil, fmt.Errorf("reducing stock: %w", err)
	}

	return &purchase, nil
}
