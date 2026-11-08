package db

import (
	"context"
	"math"
	"regexp"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// FEDERATION_NODE_DOMAIN es el dominio reservado del catalogo federado global.
// Los items con este dominio son identicos en todos los nodos (materia prima,
// productos base aprobados, servicios, embalaje y envio) y solo cambian por
// votacion de la federacion (federation_proposals: catalog_item_upsert/remove).
const FEDERATION_NODE_DOMAIN = "__FEDERATION__"

var nonAlnumDash = regexp.MustCompile(`[^a-z0-9]+`)

// CatalogItemSlug genera el identificador estable de un item del catalogo
// federado a partir de su nombre (ej: "fed-tomate-fresco").
// Replica federation_catalog_slug() de la migracion 182.
func CatalogItemSlug(name string) string {
	r := strings.NewReplacer(
		"á", "a", "é", "e", "í", "i", "ó", "o", "ú", "u", "ü", "u", "ñ", "n",
		"Á", "a", "É", "e", "Í", "i", "Ó", "o", "Ú", "u", "Ü", "u", "Ñ", "n")
	slug := nonAlnumDash.ReplaceAllString(strings.ToLower(r.Replace(name)), "-")
	return "fed-" + strings.Trim(slug, "-")
}

var serviceUnits = map[string]bool{
	"hora": true, "jornada": true, "sesion": true, "clase": true, "dia": true,
	"visita": true, "viaje": true, "consulta": true, "servicio": true,
	"evento": true, "taller": true, "curso": true, "turno": true, "mes": true,
	"semana": true, "anio": true, "tratamiento": true, "ajuste": true,
	"diagnostico": true, "diseno": true, "alojamiento": true, "corte": true,
	"poda": true, "asesoria": true, "traduccion": true, "copia": true,
	"lavado": true, "entrega": true, "dia-persona": true, "instalacion": true,
	"mantenimiento": true, "reparacion": true, "paseo": true, "excursion": true,
	"inscripcion": true, "alquiler": true, "arriendo": true, "capacitacion": true,
	"charla": true, "presentacion": true, "funcion": true, "avaluo": true,
	"inspeccion": true, "evaluacion": true, "licencia": true, "suscripcion": true,
	"noche": true, "pasaje": true, "km": true,
}

var serviceParents = map[string]bool{
	"Servicios": true, "Educacion": true,
}

var serviceCategories = map[string]bool{
	"Trabajo Agricola": true, "Trabajo Tecnico": true, "Trabajo General": true,
	"Reparaciones": true, "Oficina": true, "Limpieza": true, "Talleres": true,
	"Alfabetizacion": true, "Terapias": true, "servicios": true, "Salud": true,
	"Entrega": true, "Eventos": true, "Educacion": true, "Transporte": true,
	"Construccion": true, "Mecanica": true, "Electricidad": true,
	"Plomeria": true, "Albanileria": true, "Carpinteria": true,
	"Estetica": true, "Jardineria": true, "Herreria": true, "Veterinaria": true,
	"Consultoria": true, "Soporte Tecnico": true, "Diseno": true,
	"Instalacion": true, "Mantenimiento": true, "Reparacion": true,
	"Costura": true, "Sastreria": true, "Turismo": true, "Hospedaje": true,
	"Comunicacion": true, "Belleza": true, "Barberia": true, "Peluqueria": true,
	"Cuidado": true, "Guarderia": true, "Entrenamiento": true, "Idiomas": true,
}

var packagingCategories = map[string]bool{
	"Envases": true, "Contenedores": true, "Envolturas": true, "Bolsas": true,
	"Empaque": true, "Embalaje": true,
}

var shippingCategories = map[string]bool{
	"Entrega": true, "Envio": true, "Envios": true, "Flete": true, "Logistica": true,
}

var rawMaterialCategories = map[string]bool{
	"Cosecha Fresca": true, "Granos y Cereales": true, "Carnes y Pescados": true,
	"Fibras": true, "Materiales": true, "Metales": true, "Metal": true,
	"Agregados": true, "Minerales": true, "Tierra y Compost": true, "Agua": true,
	"Combustibles": true, "energeticos": true, "Lena": true, "Cuero": true,
	"Caucho": true, "Vidrio": true, "Papel": true, "Carton": true,
	"Animales": true, "Vivero": true, "Semillas": true, "Semillas y Plantulas": true,
	"Semillas & Plantulas": true, "Plantulas": true, "Esquejes": true,
	"Frutos Secos": true, "Insumos Agricolas": true, "Insumos Agroecologicos": true,
	"Miel y Apicultura": true, "Huevos": true, "alimentos": true,
	"Aromaticas": true, "Especias": true, "Cafe": true, "Cacao": true,
	"Hongos": true, "Hierbas": true, "Plantas": true, "Pesca": true,
	"Legumbres": true, "Tuberculos": true, "Frutas": true, "Hortalizas": true,
	"Cereales": true, "Oleaginosas": true, "Raices": true, "Abonos": true,
	"Forraje": true, "Carbon": true, "Gas": true, "Biomasa": true,
	"Componentes": true, "Resinas": true, "Recursos Basicos": true,
	"Miel": true, "Sal": true, "Insumos": true, "Mineria": true,
	"Petroleo": true, "Madera": true, "Construccion": true, "Acabados": true,
}

var baseProductCategories = map[string]bool{
	"Dulces": true, "Bebidas": true, "Salsas": true, "Conservas": true,
	"Fermentados": true, "Lacteos": true, "Extractos": true, "Aceites": true,
	"Endulzantes": true, "Condimentos": true, "Harinas": true, "Embutidos": true,
	"Deshidratados": true, "Medicina Botanica": true, "Primeros Auxilios": true,
	"Herramientas": true, "Manuales": true, "Hilos y Materiales": true,
	"Textiles": true, "textiles": true, "Tintes": true, "Pinturas": true,
	"Barnices": true, "Adhesivos": true, "Repuestos": true, "Utensilios": true,
	"Riego": true, "Solar": true, "Eolica": true, "Hidraulica": true,
	"Electricas": true, "Higiene": true, "Chocolate": true,
	"Componentes Electronicos": true,
}

var finishedProductNames = []*regexp.Regexp{
	regexp.MustCompile(`(?i)mesa|silla|mueble|banco |cama|estante|puerta|ventana|ropero|gabinete|mortero|tabla de picar`),
}

// ClassifyCatalogItemType clasifica un item del catalogo segun las mismas
// reglas de la migracion 182. Devuelve:
//
//	raw_material | base_product | service | packaging | shipping | composite | product
//
// 'product' significa bien final (no pertenece al catalogo federado).
func ClassifyCatalogItemType(name, parent, category, subcategory, unit string, isComposite bool) string {
	if isComposite {
		return "composite"
	}
	if parent == "Embalaje" || packagingCategories[category] {
		return "packaging"
	}
	if parent == "Envio" || shippingCategories[category] {
		return "shipping"
	}
	if serviceUnits[strings.ToLower(unit)] || serviceParents[parent] || serviceCategories[category] {
		return "service"
	}
	if rawMaterialCategories[category] {
		for _, re := range finishedProductNames {
			if re.MatchString(name) {
				return "product"
			}
		}
		return "raw_material"
	}
	if baseProductCategories[category] {
		return "base_product"
	}
	return "product"
}

// ComputeVariantPriceCents calcula el precio en CENTAVOS de una variante de presentación
// (saco, kg, g, lb, oz, L, ml, m, cm, docena, unidad, etc.) derivándolo directamente
// del precio base de la Federación mediante multiplicaciones/divisiones exactas.
func ComputeVariantPriceCents(fedPricePerUnitCents, fedPricePerKgTQ, fedWeightKg float64, fedUnit, fedBaseUnit, sellUnit string, sellQty float64) float64 {
	// Normalizar fedPricePerUnitCents solo si tiene decimales (escala TQ fraccionaria)
	ppuCents := fedPricePerUnitCents
	if ppuCents > 0 && ppuCents != math.Trunc(ppuCents) {
		ppuCents = math.Round(ppuCents * 100)
	}
	if sellQty <= 0 {
		sellQty = 1
	}
	fu := strings.ToLower(strings.TrimSpace(fedUnit))
	if fu == "" {
		fu = "unidad"
	}
	su := strings.ToLower(strings.TrimSpace(sellUnit))
	if su == "" {
		su = fu
	}
	bu := strings.ToLower(strings.TrimSpace(fedBaseUnit))
	if bu == "" {
		bu = "kg"
	}

	// Precio en centavos por 1 unidad base (ej. 1 kg o 1 L) en la Federación
	baseUnitCents := 0.0
	if fedWeightKg > 0 && ppuCents > 0 {
		baseUnitCents = ppuCents / fedWeightKg
	} else if fedPricePerKgTQ > 0 {
		if fedPricePerKgTQ >= 100 && ppuCents > 0 && math.Abs(fedPricePerKgTQ-ppuCents) < 1 {
			baseUnitCents = fedPricePerKgTQ
		} else {
			baseUnitCents = fedPricePerKgTQ * 100.0
		}
	} else {
		baseUnitCents = ppuCents
	}

	// Si la unidad de venta es la misma que la unidad de la Federación (ej. saco == saco, kg == kg)
	if su == fu {
		// Si es un envase/saco y sellQty == fedWeightKg (por ej. saco con quantity_per_unit=25), es 1 saco
		if fedWeightKg > 1 && math.Abs(sellQty-fedWeightKg) < 0.001 && (su == "saco" || su == "bulto" || su == "paquete" || su == "frasco" || su == "botella" || su == "canasta") {
			return math.Round(ppuCents)
		}
		return math.Round(ppuCents * sellQty)
	}

	// Conversión entre unidades por divisiones/multiplicaciones exactas
	factorToBase := 1.0
	qty := sellQty
	switch su {
	case "saco", "bulto":
		if fedWeightKg > 0 {
			factorToBase = fedWeightKg
		} else {
			factorToBase = 25.0
		}
		if fedWeightKg > 1 && math.Abs(qty-fedWeightKg) < 0.001 {
			qty = 1.0
		}
	case "quintal":
		factorToBase = 46.0
	case "arroba":
		factorToBase = 11.5
	case "kg", "kilo", "kilogramo", "kilogramos", "l", "litro", "litros", "m", "metro", "metros":
		factorToBase = 1.0
	case "g", "gr", "gramo", "gramos", "ml", "mililitro", "mililitros", "cc", "mm", "milimetro", "milimetros":
		// Si qty < 1 (ej. 0.001 o 0.5 guardado por el selector antiguo), ya está expresado en unidad base (kg/L/m).
		// Si qty >= 1 (ej. 1, 100, 250, 500 gramos/ml), dividimos entre 1000.
		if qty >= 1.0 {
			factorToBase = 1.0 / 1000.0
		} else {
			factorToBase = 1.0
		}
	case "mg", "miligramo", "miligramos":
		if qty >= 1.0 {
			factorToBase = 1.0 / 1000000.0
		} else {
			factorToBase = 1.0
		}
	case "cm", "centimetro", "centimetros", "centímetro":
		if qty >= 1.0 {
			factorToBase = 1.0 / 100.0
		} else {
			factorToBase = 1.0
		}
	case "lb", "libra", "libras":
		if qty >= 1.0 || math.Abs(qty-0.4536) > 0.001 {
			factorToBase = 0.45359237
		} else {
			factorToBase = 1.0
		}
	case "oz", "onza", "onzas":
		if qty >= 1.0 || math.Abs(qty-0.02835) > 0.001 {
			factorToBase = 0.0283495
		} else {
			factorToBase = 1.0
		}
	case "galon", "galón":
		if qty >= 1.0 || math.Abs(qty-3.78541) > 0.001 {
			factorToBase = 3.78541
		} else {
			factorToBase = 1.0
		}
	case "pulgada", "pulgadas", "in":
		if qty >= 1.0 || math.Abs(qty-0.0254) > 0.001 {
			factorToBase = 0.0254
		} else {
			factorToBase = 1.0
		}
	case "pie", "pies", "ft":
		if qty >= 1.0 || math.Abs(qty-0.3048) > 0.001 {
			factorToBase = 0.3048
		} else {
			factorToBase = 1.0
		}
	case "docena":
		if fu == "unidad" {
			factorToBase = 12.0
		} else {
			factorToBase = 1.0
		}
	case "media docena":
		if fu == "docena" {
			factorToBase = 0.5
		} else {
			factorToBase = 6.0
		}
	case "par":
		if fu == "docena" {
			factorToBase = 2.0 / 12.0
		} else {
			factorToBase = 2.0
		}
	case "unidad", "und":
		if fu == "docena" {
			factorToBase = 1.0 / 12.0
		} else {
			factorToBase = 1.0
		}
	default:
		factorToBase = 1.0
	}

	if baseUnitCents > 0 {
		return math.Round(baseUnitCents * factorToBase * qty)
	}
	return math.Round(ppuCents * factorToBase * qty)
}

// UpsertProductToFederation garantiza que cualquier producto (base o compuesto) creado
// o actualizado en un nodo local o tienda personal quede registrado en el catálogo
// global de la Federación (__FEDERATION__), manteniendo su precio en centavos y su
// composición sincronizados como fuente única de verdad.
func UpsertProductToFederation(ctx context.Context, pool *pgxpool.Pool, productID uuid.UUID) (uuid.UUID, error) {
	var (
		nodeDomain, name, desc, parentCat, cat, subcat, unit, origin, baseUnit, itemType, catalogKey string
		pricePerUnit, pricePerKg, weightKg                                                           float64
		badge, imageURL, thumbURL, productCode                                                       *string
		isComposite, isService                                                                       bool
	)
	err := pool.QueryRow(ctx, `
		SELECT node_domain, name, COALESCE(description,''), COALESCE(parent_category,''),
		       COALESCE(category,''), COALESCE(subcategory,''), COALESCE(unit,'unidad'),
		       price_per_unit, COALESCE(price_per_kg,0), COALESCE(weight_kg,0),
		       COALESCE(base_unit,'kg'), COALESCE(origin,'internal'), badge, image_url,
		       image_thumb_url, product_code, COALESCE(is_composite,false),
		       COALESCE(item_type,'composite'), COALESCE(catalog_key,'')
		FROM products WHERE id = $1`, productID,
	).Scan(&nodeDomain, &name, &desc, &parentCat, &cat, &subcat, &unit,
		&pricePerUnit, &pricePerKg, &weightKg, &baseUnit, &origin, &badge, &imageURL,
		&thumbURL, &productCode, &isComposite, &itemType, &catalogKey)
	if err != nil {
		return uuid.Nil, err
	}

	if catalogKey == "" {
		catalogKey = CatalogItemSlug(name)
	}
	if itemType == "" || itemType == "product" {
		if isComposite {
			itemType = "composite"
		} else {
			itemType = ClassifyCatalogItemType(name, parentCat, cat, subcat, unit, isComposite)
			if itemType == "product" {
				itemType = "base_product"
			}
		}
	}
	_ = isService

	// Asegurar que el producto origen tenga catalog_key asignado
	_, _ = pool.Exec(ctx, `UPDATE products SET catalog_key = $1 WHERE id = $2 AND COALESCE(catalog_key,'') = ''`, catalogKey, productID)

	if nodeDomain == FEDERATION_NODE_DOMAIN {
		return productID, nil
	}

	pcode := ""
	if productCode != nil {
		pcode = strings.TrimSpace(*productCode)
	}

	// Buscar si ya existe en __FEDERATION__
	var fedID uuid.UUID
	err = pool.QueryRow(ctx, `
		SELECT id FROM products
		WHERE node_domain = '__FEDERATION__'
		  AND (
		      (NULLIF($1, '') IS NOT NULL AND catalog_key = $1)
		      OR (NULLIF($2, '') IS NOT NULL AND product_code = $2)
		      OR LOWER(name) = LOWER($3)
		  )
		ORDER BY
		  CASE
		    WHEN NULLIF($1, '') IS NOT NULL AND catalog_key = $1 THEN 1
		    WHEN NULLIF($2, '') IS NOT NULL AND product_code = $2 THEN 2
		    ELSE 3
		  END
		LIMIT 1`, catalogKey, pcode, name).Scan(&fedID)

	if err == nil && fedID != uuid.Nil {
		// Actualizar la fila existente en __FEDERATION__ (solo si era un compuesto/producto subido por el nodo o si faltan datos)
		_, _ = pool.Exec(ctx, `
			UPDATE products SET
				description = CASE WHEN COALESCE(description,'') = '' THEN $1 ELSE description END,
				parent_category = CASE WHEN COALESCE(parent_category,'') = '' THEN $2 ELSE parent_category END,
				category = CASE WHEN COALESCE(category,'') = '' THEN $3 ELSE category END,
				subcategory = CASE WHEN COALESCE(subcategory,'') = '' THEN $4 ELSE subcategory END,
				unit = COALESCE(NULLIF($5,''), unit),
				price_per_unit = CASE WHEN is_composite = true OR COALESCE(price_per_unit,0) <= 0 THEN $6 ELSE price_per_unit END,
				price_per_kg = CASE WHEN COALESCE(price_per_kg,0) <= 0 AND $7 > 0 THEN $7 ELSE price_per_kg END,
				weight_kg = CASE WHEN COALESCE(weight_kg,0) <= 0 AND $8 > 0 THEN $8 ELSE weight_kg END,
				base_unit = COALESCE(NULLIF($9,''), base_unit),
				image_url = COALESCE(NULLIF($10,''), image_url),
				image_thumb_url = COALESCE(NULLIF($11,''), image_thumb_url),
				catalog_key = COALESCE(NULLIF(catalog_key,''), $12),
				is_approved = true,
				is_active = true,
				is_hidden = false,
				updated_at = NOW()
			WHERE id = $13`,
			desc, parentCat, cat, subcat, unit, pricePerUnit, pricePerKg, weightKg, baseUnit,
			derefStr(imageURL), derefStr(thumbURL), catalogKey, fedID)
	} else {
		fedID = uuid.New()
		_, err = pool.Exec(ctx, `
			INSERT INTO products (
				id, node_domain, name, description, parent_category, category, subcategory,
				unit, price_per_unit, price_per_kg, weight_kg, base_unit, origin, badge,
				image_url, image_thumb_url, product_code, source_node, source_product_id,
				catalog_key, item_type, is_Composite, is_approved, is_system, is_active, is_hidden
			) VALUES (
				$1, '__FEDERATION__', $2, $3, $4, $5, $6,
				$7, $8, $9, $10, $11, $12, $13,
				$14, $15, $16, $17, $18,
				$19, $20, $21, true, true, true, false
			)`,
			fedID, name, desc, parentCat, cat, subcat,
			unit, pricePerUnit, pricePerKg, weightKg, baseUnit, origin, badge,
			imageURL, thumbURL, productCode, nodeDomain, productID,
			catalogKey, itemType, isComposite)
		if err != nil {
			return uuid.Nil, err
		}
	}

	// Sincronizar la composición en product_compositions hacia el producto federado
	if isComposite {
		_, _ = pool.Exec(ctx, `DELETE FROM product_compositions WHERE product_id = $1 AND product_type = 'catalog'`, fedID)
		_, _ = pool.Exec(ctx, `
			INSERT INTO product_compositions (
				product_id, product_type, component_product_id, component_catalog_key,
				component_name, component_unit, component_price, quantity, subtotal,
				component_category, sort_order
			)
			SELECT $1, 'catalog', component_product_id, component_catalog_key,
			       component_name, component_unit, component_price, quantity, subtotal,
			       component_category, sort_order
			FROM product_compositions
			WHERE product_id = $2`, fedID, productID)
	}

	return fedID, nil
}

func derefStr(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}
