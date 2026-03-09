package server

import (
	"net/http"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	shared.OK(w, r, map[string]string{"status": "ok"})
}
