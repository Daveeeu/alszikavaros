package game

import (
	"net/http"

	"github.com/Daveeeu/alszikavaros/backend/internal/auth"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/ws"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"github.com/go-chi/chi/v5"
)

type Handler struct {
	svc       *Service
	publisher *ws.Publisher
}

func NewHandler(svc *Service, publisher *ws.Publisher) *Handler {
	return &Handler{svc: svc, publisher: publisher}
}

func (h *Handler) GetGameState(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := shared.RequireNonEmptyTrimmed(id, "id"); err != nil {
		shared.FailError(w, r, err)
		return
	}

	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	state, err := h.svc.GetState(id, currentPlayer.ID)
	if err != nil {
		shared.FailError(w, r, mapServiceError(err))
		return
	}
	shared.OK(w, r, state)
}

func (h *Handler) RevealRole(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := shared.RequireNonEmptyTrimmed(id, "id"); err != nil {
		shared.FailError(w, r, err)
		return
	}

	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	resp, err := h.svc.ConfirmRoleReveal(id, currentPlayer.ID)
	if err != nil {
		shared.FailError(w, r, mapServiceError(err))
		return
	}

	shared.OK(w, r, resp)
}

func (h *Handler) StartDiscussion(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := shared.RequireNonEmptyTrimmed(id, "id"); err != nil {
		shared.FailError(w, r, err)
		return
	}

	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	resp, err := h.svc.StartDiscussion(id, currentPlayer.ID)
	if err != nil {
		h.handleError(w, r, err)
		return
	}

	h.publishPhaseChanged(resp)
	shared.OK(w, r, resp)
}

func (h *Handler) StartVoting(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := shared.RequireNonEmptyTrimmed(id, "id"); err != nil {
		shared.FailError(w, r, err)
		return
	}

	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	resp, err := h.svc.StartVoting(id, currentPlayer.ID)
	if err != nil {
		h.handleError(w, r, err)
		return
	}

	h.publishPhaseChanged(resp)
	shared.OK(w, r, resp)
}

func (h *Handler) publishPhaseChanged(resp *PhaseTransitionResponse) {
	if h.publisher == nil || resp == nil {
		return
	}
	h.publisher.PublishGamePhaseChanged(ws.GamePhaseChangedPayload{
		GameID:    resp.GameID,
		RoomID:    resp.RoomID,
		RoomCode:  "",
		FromPhase: string(resp.FromPhase),
		ToPhase:   string(resp.ToPhase),
		DayNumber: resp.DayNumber,
	})
}

func (h *Handler) handleError(w http.ResponseWriter, r *http.Request, err error) {
	shared.FailError(w, r, mapServiceError(err))
}
