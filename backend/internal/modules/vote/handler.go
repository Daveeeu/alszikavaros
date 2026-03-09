package vote

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

func (h *Handler) SubmitVote(w http.ResponseWriter, r *http.Request) {
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

	var req SubmitVoteRequest
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

	h.publishVoteEvents(resp)
	shared.OK(w, r, resp)
}

func (h *Handler) publishVoteEvents(resp *SubmitVoteResponse) {
	if h.publisher == nil || resp == nil || !resp.Transitioned {
		return
	}
	if resp.Phase != shared.GamePhaseVoteResult {
		return
	}

	h.publisher.PublishGamePhaseChanged(ws.GamePhaseChangedPayload{
		GameID:    resp.GameID,
		RoomID:    resp.RoomID,
		RoomCode:  "",
		FromPhase: string(shared.GamePhaseVoting),
		ToPhase:   string(shared.GamePhaseVoteResult),
		DayNumber: resp.DayNumber,
	})
	h.publisher.PublishRoomAndGame("game.vote_result", resp.RoomID, resp.GameID, ws.GameVoteResultPayload{
		GameID:    resp.GameID,
		RoomID:    resp.RoomID,
		DayNumber: resp.DayNumber,
		Tie:       false,
	})
}
