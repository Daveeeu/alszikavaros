package room

import "github.com/go-chi/chi/v5"

func RegisterRoutes(r chi.Router, h *Handler) {
	r.Post("/rooms", h.CreateRoom)
	r.Post("/rooms/join", h.JoinRoom)
	r.Get("/rooms/{code}", h.GetRoomByCode)
	r.Post("/rooms/{code}/leave", h.LeaveRoom)
	r.Post("/rooms/{code}/start", h.StartGame)
	r.Post("/rooms/{code}/restart", h.RestartRoom)
}
