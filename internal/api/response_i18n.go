package api

import (
	"bufio"
	"bytes"
	"context"
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"errors"
	"net"
	"net/http"
	"strings"

	"federated-credit-node/internal/db"

	"github.com/jackc/pgx/v5/pgxpool"
)

// i18nResponseMiddleware localiza los campos de texto de nivel superior
// ("error", "message", "detail") de las respuestas JSON segun el idioma
// del request (?lang= / Accept-Language). Los textos originales (espanol)
// se registran como fuentes traducibles con entity_type 'api_message' para
// que aparezcan en el modulo de traducciones.
//
// Solo afecta respuestas JSON; contenido binario/streaming pasa intacto.
func i18nResponseMiddleware(pool *pgxpool.Pool, configDomain string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Solo interceptar respuestas de la API. Este middleware corre
			// antes del strip de basePath, asi que el path puede venir con
			// prefijo (ej: /demo/api/...).
			if !strings.Contains(r.URL.Path, "/api/") {
				next.ServeHTTP(w, r)
				return
			}

			nodeDomain := db.ResolveNodeDomain(r.Context(), pool, r.Header.Get("X-Node-Domain"), configDomain)
			lang, fallbackLang := resolveRequestLanguages(r, pool, nodeDomain)

			bw := &i18nBufferWriter{ResponseWriter: w, status: http.StatusOK}
			next.ServeHTTP(bw, r)

			if bw.passthrough {
				return
			}

			body := bw.buf.Bytes()
			ct := bw.Header().Get("Content-Type")
			if !strings.Contains(ct, "json") || len(body) == 0 || body[0] != '{' ||
				(!bytes.Contains(body, []byte(`"error"`)) &&
					!bytes.Contains(body, []byte(`"message"`)) &&
					!bytes.Contains(body, []byte(`"detail"`))) {
				writeBuffered(w, bw, body)
				return
			}

			var payload map[string]interface{}
			if err := json.Unmarshal(body, &payload); err != nil {
				writeBuffered(w, bw, body)
				return
			}

			changed := false
			for _, field := range []string{"error", "message", "detail"} {
				text, ok := payload[field].(string)
				if !ok || strings.TrimSpace(text) == "" {
					continue
				}
				key := registerAPIMessageSource(r.Context(), pool, text)
				if !strings.EqualFold(lang, fallbackLang) {
					if v := localizedContentValues(r.Context(), pool, []string{key}, lang)[key]; v != "" {
						payload[field] = v
						changed = true
					}
				}
			}

			if changed {
				if out, err := json.Marshal(payload); err == nil {
					body = out
					bw.Header().Set("Content-Length", "")
					bw.Header().Del("Content-Length")
				}
			}
			writeBuffered(w, bw, body)
		})
	}
}

// writeBuffered vuelca el status y body capturados al writer real.
func writeBuffered(w http.ResponseWriter, bw *i18nBufferWriter, body []byte) {
	w.WriteHeader(bw.status)
	_, _ = w.Write(body)
}

// i18nBufferWriter captura la respuesta completa para post-procesarla.
// Si el handler hace Flush (SSE/streaming) o escribe binario, pasa a modo
// passthrough y deja de acumular.
type i18nBufferWriter struct {
	http.ResponseWriter
	status      int
	buf         bytes.Buffer
	passthrough bool
}

func (w *i18nBufferWriter) WriteHeader(code int) {
	if w.passthrough {
		w.ResponseWriter.WriteHeader(code)
		return
	}
	w.status = code
}

func (w *i18nBufferWriter) Write(p []byte) (int, error) {
	if w.passthrough {
		return w.ResponseWriter.Write(p)
	}
	// Si el Content-Type ya fue seteado y no es JSON (descargas binarias,
	// PDFs, firmware), no bufferear: pasar directo.
	if ct := w.Header().Get("Content-Type"); ct != "" && !strings.Contains(ct, "json") {
		w.passthrough = true
		w.ResponseWriter.WriteHeader(w.status)
		return w.ResponseWriter.Write(p)
	}
	return w.buf.Write(p)
}

// Flush implementa http.Flusher: al hacerse streaming, se vuelca lo
// acumulado y el writer queda en passthrough.
func (w *i18nBufferWriter) Flush() {
	if w.passthrough {
		if f, ok := w.ResponseWriter.(http.Flusher); ok {
			f.Flush()
		}
		return
	}
	w.passthrough = true
	w.ResponseWriter.WriteHeader(w.status)
	_, _ = w.ResponseWriter.Write(w.buf.Bytes())
	w.buf.Reset()
	if f, ok := w.ResponseWriter.(http.Flusher); ok {
		f.Flush()
	}
}

// Hijack implementa http.Hijacker para no romper upgrades (websockets).
func (w *i18nBufferWriter) Hijack() (net.Conn, *bufio.ReadWriter, error) {
	h, ok := w.ResponseWriter.(http.Hijacker)
	if !ok {
		return nil, nil, errors.New("hijack not supported")
	}
	return h.Hijack()
}

// registerAPIMessageSource registra un texto de respuesta como fuente
// traducible global (entity_type 'api_message'). Devuelve la clave.
func registerAPIMessageSource(ctx context.Context, pool *pgxpool.Pool, text string) string {
	sum := md5.Sum([]byte(text))
	entityID := hex.EncodeToString(sum[:8])
	key, err := upsertContentSource(ctx, pool, "__GLOBAL__", "api_message", entityID, "text", text,
		map[string]interface{}{"label": truncateRunes(text, 60)})
	if err != nil {
		return "api_message:" + entityID + ":text"
	}
	return key
}

func truncateRunes(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n]) + "..."
}
