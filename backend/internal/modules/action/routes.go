package action

import "github.com/go-chi/chi/v5"

func RegisterRoutes(r chi.Router, h *Handler) {
	r.Post("/games/{id}/actions", h.SubmitAction)
}
