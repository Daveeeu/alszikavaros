package action

import (
	"net/http"

	"github.com/Daveeeu/alszikavaros/backend/internal/auth"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"github.com/go-chi/chi/v5"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) SubmitAction(w http.ResponseWriter, r *http.Request) {
	gameID := chi.URLParam(r, "id")
	if err := shared.RequireNonEmptyTrimmed(gameID, "id"); err != nil {
		shared.FailError(w, r, err)
		return
	}

	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	var req SubmitNightActionRequest
	if err := shared.DecodeJSON(r, &req); err != nil {
		shared.FailError(w, r, shared.InvalidRequest("invalid request payload", nil))
		return
	}
	if err := shared.RequireNonEmptyTrimmed(req.TargetPlayerID, "targetPlayerId"); err != nil {
		shared.FailError(w, r, err)
		return
	}

	resp, err := h.svc.Submit(gameID, currentPlayer.ID, req)
	if err != nil {
		shared.FailError(w, r, mapServiceError(err))
		return
	}

	shared.OK(w, r, resp)
}
