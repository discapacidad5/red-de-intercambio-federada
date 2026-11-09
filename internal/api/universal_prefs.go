package api

import (
	"context"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// universalServiceIDs son los 6 servicios universales de Trabajo (categoría fija
// "Trabajo"). No son filas propias de store_items de cada dueño: se agregan en vivo
// a Mi Tienda y al POS. Su visibilidad en el POS se guarda por dueño en
// store_universal_service_prefs (migración 200).
var universalServiceIDs = map[string]bool{
	"00000000-0000-4000-8000-0000000900a1": true,
	"00000000-0000-4000-8000-0000000900a2": true,
	"00000000-0000-4000-8000-0000000900b1": true,
	"00000000-0000-4000-8000-0000000900b2": true,
	"00000000-0000-4000-8000-0000000900c1": true,
	"00000000-0000-4000-8000-0000000900c2": true,
}

// isUniversalServiceID indica si el id corresponde a uno de los 6 servicios universales.
func isUniversalServiceID(id uuid.UUID) bool {
	return universalServiceIDs[id.String()]
}

// loadHiddenUniversalServices devuelve los servicios universales que el dueño
// decidió ocultar del punto de venta.
func loadHiddenUniversalServices(ctx context.Context, pool *pgxpool.Pool, ownerID uuid.UUID) map[string]bool {
	hidden := map[string]bool{}
	if ownerID == uuid.Nil {
		return hidden
	}
	rows, err := pool.Query(ctx, `
		SELECT product_id::text FROM store_universal_service_prefs
		WHERE owner_id = $1 AND show_in_pos = false`, ownerID)
	if err != nil {
		return hidden
	}
	defer rows.Close()
	for rows.Next() {
		var id string
		if rows.Scan(&id) == nil {
			hidden[id] = true
		}
	}
	return hidden
}

// isCategoryHiddenInPOS indica si el dueño ocultó una categoría del punto de venta.
func isCategoryHiddenInPOS(ctx context.Context, pool *pgxpool.Pool, ownerID uuid.UUID, name string) bool {
	if ownerID == uuid.Nil || strings.TrimSpace(name) == "" {
		return false
	}
	var hidden bool
	_ = pool.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM store_categories
			WHERE owner_id = $1 AND LOWER(name) = LOWER($2) AND show_in_pos = false
		)`, ownerID, name).Scan(&hidden)
	return hidden
}

