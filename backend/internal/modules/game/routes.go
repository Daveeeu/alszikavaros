package game

import "github.com/go-chi/chi/v5"

func RegisterRoutes(r chi.Router, h *Handler) {
	r.Get("/games/{id}/state", h.GetGameState)
	r.Post("/games/{id}/role/reveal", h.RevealRole)
	r.Post("/games/{id}/discussion/start", h.StartDiscussion)
	r.Post("/games/{id}/voting/start", h.StartVoting)
}
