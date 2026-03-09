package player

import (
	"net/http"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"github.com/go-chi/chi/v5"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) ListByRoomID(w http.ResponseWriter, r *http.Request) {
	roomID := chi.URLParam(r, "roomID")
	if err := shared.RequireNonEmptyTrimmed(roomID, "roomID"); err != nil {
		shared.FailError(w, r, err)
		return
	}
	players, err := h.svc.ListByRoomID(roomID)
	if err != nil {
		shared.FailError(w, r, shared.Internal("failed to fetch players"))
		return
	}
	shared.OK(w, r, players)
}
