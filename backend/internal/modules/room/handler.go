package room

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

func (h *Handler) CreateRoom(w http.ResponseWriter, r *http.Request) {
	var req CreateRoomRequest
	if err := shared.DecodeJSON(r, &req); err != nil {
		shared.FailError(w, r, shared.InvalidRequest("invalid request payload", nil))
		return
	}
	if err := shared.RequireNonEmptyTrimmed(req.PlayerName, "playerName"); err != nil {
		shared.FailError(w, r, err)
		return
	}

	resp, err := h.svc.CreateRoom(req.PlayerName)
	if err != nil {
		h.handleError(w, r, err)
		return
	}
	shared.Created(w, r, resp)
}

func (h *Handler) JoinRoom(w http.ResponseWriter, r *http.Request) {
	var req JoinRoomRequest
	if err := shared.DecodeJSON(r, &req); err != nil {
		shared.FailError(w, r, shared.InvalidRequest("invalid request payload", nil))
		return
	}
	if err := shared.RequireNonEmptyTrimmed(req.PlayerName, "playerName"); err != nil {
		shared.FailError(w, r, err)
		return
	}
	if err := shared.RequireMinLength(req.RoomCode, "roomCode", 4); err != nil {
		shared.FailError(w, r, err)
		return
	}

	resp, err := h.svc.JoinRoom(req.PlayerName, req.RoomCode)
	if err != nil {
		h.handleError(w, r, err)
		return
	}
	h.publishPlayerJoined(resp.Room)
	shared.OK(w, r, resp)
}

func (h *Handler) GetRoomByCode(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	if err := shared.RequireMinLength(code, "code", 4); err != nil {
		shared.FailError(w, r, err)
		return
	}
	state, err := h.svc.GetRoomState(code)
	if err != nil {
		h.handleError(w, r, err)
		return
	}
	shared.OK(w, r, state)
}

func (h *Handler) LeaveRoom(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	if err := shared.RequireMinLength(code, "code", 4); err != nil {
		shared.FailError(w, r, err)
		return
	}
	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	state, err := h.svc.LeaveRoom(code, currentPlayer.ID)
	if err != nil {
		h.handleError(w, r, err)
		return
	}
	h.publishPlayerLeft(*state, currentPlayer.ID, currentPlayer.Name)
	shared.OK(w, r, state)
}

func (h *Handler) StartGame(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	if err := shared.RequireMinLength(code, "code", 4); err != nil {
		shared.FailError(w, r, err)
		return
	}
	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	resp, err := h.svc.StartGame(code, currentPlayer.ID)
	if err != nil {
		h.handleError(w, r, err)
		return
	}
	h.publishGameStarted(code, resp.GameID)
	shared.OK(w, r, resp)
}

func (h *Handler) RestartRoom(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	if err := shared.RequireMinLength(code, "code", 4); err != nil {
		shared.FailError(w, r, err)
		return
	}
	currentPlayer, ok := auth.CurrentPlayer(r)
	if !ok {
		shared.FailError(w, r, shared.Unauthorized("unauthorized"))
		return
	}

	resp, err := h.svc.RestartRoom(code, currentPlayer.ID)
	if err != nil {
		h.handleError(w, r, err)
		return
	}

	h.publishRestartEvents(resp)
	shared.OK(w, r, resp)
}

func (h *Handler) handleError(w http.ResponseWriter, r *http.Request, err error) {
	shared.FailError(w, r, mapServiceError(err))
}

func (h *Handler) publishRestartEvents(resp *RestartRoomResponse) {
	if h.publisher == nil || resp == nil {
		return
	}

	h.publisher.PublishRoom("room.updated", resp.Room.Code, resp.Room)
	h.publisher.PublishRoomAndGame("game.started", resp.Room.Code, resp.GameID, ws.GameStartedPayload{
		GameID:   resp.GameID,
		RoomID:   resp.Room.ID,
		RoomCode: resp.Room.Code,
	})
	h.publisher.PublishGamePhaseChanged(ws.GamePhaseChangedPayload{
		GameID:    resp.GameID,
		RoomID:    resp.Room.ID,
		RoomCode:  resp.Room.Code,
		FromPhase: "ended",
		ToPhase:   string(resp.Phase),
		DayNumber: 1,
	})
}

func (h *Handler) publishPlayerJoined(roomState RoomStateDTO) {
	if h.publisher == nil || len(roomState.Players) == 0 {
		return
	}
	player := roomState.Players[len(roomState.Players)-1]
	h.publisher.PublishRoom("room.player_joined", roomState.Code, ws.RoomPlayerEventPayload{
		RoomID:     roomState.ID,
		RoomCode:   roomState.Code,
		PlayerID:   player.ID,
		PlayerName: player.Name,
	})
	h.publisher.PublishRoom("room.updated", roomState.Code, roomState)
}

func (h *Handler) publishPlayerLeft(roomState RoomStateDTO, playerID, playerName string) {
	if h.publisher == nil {
		return
	}
	h.publisher.PublishRoom("room.player_left", roomState.Code, ws.RoomPlayerEventPayload{
		RoomID:     roomState.ID,
		RoomCode:   roomState.Code,
		PlayerID:   playerID,
		PlayerName: playerName,
	})
	h.publisher.PublishRoom("room.updated", roomState.Code, roomState)
}

func (h *Handler) publishGameStarted(roomCode, gameID string) {
	if h.publisher == nil {
		return
	}
	h.publisher.PublishRoomAndGame("game.started", roomCode, gameID, ws.GameStartedPayload{
		GameID:   gameID,
		RoomCode: roomCode,
	})
	h.publisher.PublishGamePhaseChanged(ws.GamePhaseChangedPayload{
		GameID:    gameID,
		RoomCode:  roomCode,
		FromPhase: "lobby",
		ToPhase:   "role_reveal",
		DayNumber: 1,
	})
}
