package server

import (
	"log"
	"net/http"
	"runtime/debug"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"github.com/go-chi/chi/v5/middleware"
)

type statusRecorder struct {
	http.ResponseWriter
	statusCode int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.statusCode = code
	r.ResponseWriter.WriteHeader(code)
}

func requestLogger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		startedAt := time.Now()
		recorder := &statusRecorder{ResponseWriter: w, statusCode: http.StatusOK}

		next.ServeHTTP(recorder, r)

		reqID := middleware.GetReqID(r.Context())
		log.Printf("request_id=%s method=%s path=%s status=%d duration=%s", reqID, r.Method, r.URL.Path, recorder.statusCode, time.Since(startedAt).String())
	})
}

func recoverer(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				log.Printf("panic recovered: %v\n%s", rec, string(debug.Stack()))
				shared.FailError(w, r, shared.Internal("internal server error"))
			}
		}()

		next.ServeHTTP(w, r)
	})
}
