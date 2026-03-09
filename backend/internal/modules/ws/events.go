package ws

import (
	"encoding/json"
	"strings"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type EventEnvelope struct {
	Event   string `json:"event"`
	Payload any    `json:"payload,omitempty"`
}

type RoomPlayerEventPayload struct {
	RoomID     string `json:"roomId"`
	RoomCode   string `json:"roomCode"`
	PlayerID   string `json:"playerId"`
	PlayerName string `json:"playerName,omitempty"`
}

type RoomUpdatedPayload struct {
	RoomID    string `json:"roomId"`
	RoomCode  string `json:"roomCode"`
	Status    string `json:"status,omitempty"`
	GameID    string `json:"gameId,omitempty"`
	PlayerCnt int    `json:"playerCount,omitempty"`
}

type GameStartedPayload struct {
	GameID    string `json:"gameId"`
	RoomID    string `json:"roomId"`
	RoomCode  string `json:"roomCode,omitempty"`
	DayNumber int    `json:"dayNumber,omitempty"`
}

type GamePhaseChangedPayload struct {
	GameID    string `json:"gameId"`
	RoomID    string `json:"roomId"`
	RoomCode  string `json:"roomCode,omitempty"`
	FromPhase string `json:"fromPhase"`
	ToPhase   string `json:"toPhase"`
	DayNumber int    `json:"dayNumber"`
}

type GameDayStartedPayload struct {
	GameID    string `json:"gameId"`
	RoomID    string `json:"roomId"`
	DayNumber int    `json:"dayNumber"`
}

type GameVoteStartedPayload struct {
	GameID    string `json:"gameId"`
	RoomID    string `json:"roomId"`
	DayNumber int    `json:"dayNumber"`
}

type GameVoteResultPayload struct {
	GameID             string `json:"gameId"`
	RoomID             string `json:"roomId"`
	DayNumber          int    `json:"dayNumber"`
	EliminatedPlayerID string `json:"eliminatedPlayerId,omitempty"`
	Tie                bool   `json:"tie"`
}

type GameEndedPayload struct {
	GameID string `json:"gameId"`
	RoomID string `json:"roomId"`
	Winner string `json:"winner"`
}

type Publisher struct {
	hub *Hub
}

func NewPublisher(hub *Hub) *Publisher {
	return &Publisher{hub: hub}
}

func (p *Publisher) Publish(event string, payload any) {
	if p == nil || p.hub == nil {
		return
	}
	body, err := encodeEnvelope(event, payload)
	if err != nil {
		return
	}
	p.hub.Broadcast(body)
}

func (p *Publisher) PublishRoom(event, roomCode string, payload any) {
	if p == nil || p.hub == nil {
		return
	}
	body, err := encodeEnvelope(event, payload)
	if err != nil {
		return
	}
	p.hub.BroadcastRoom(roomCode, body)
}

func (p *Publisher) PublishGame(event, gameID string, payload any) {
	if p == nil || p.hub == nil {
		return
	}
	body, err := encodeEnvelope(event, payload)
	if err != nil {
		return
	}
	p.hub.BroadcastGame(gameID, body)
}

func (p *Publisher) PublishRoomAndGame(event, roomCode, gameID string, payload any) {
	if p == nil || p.hub == nil {
		return
	}
	body, err := encodeEnvelope(event, payload)
	if err != nil {
		return
	}
	if strings.TrimSpace(roomCode) != "" {
		p.hub.BroadcastRoom(roomCode, body)
	}
	if strings.TrimSpace(gameID) != "" {
		p.hub.BroadcastGame(gameID, body)
	}
}

func (p *Publisher) PublishGamePhaseChanged(payload GamePhaseChangedPayload) {
	if p == nil || p.hub == nil {
		return
	}
	roomKey := payload.RoomCode
	if strings.TrimSpace(roomKey) == "" {
		roomKey = payload.RoomID
	}
	p.PublishRoomAndGame("game.phase_changed", roomKey, payload.GameID, payload)

	if payload.ToPhase == string(shared.GamePhaseVoting) {
		p.PublishRoomAndGame("game.vote_started", roomKey, payload.GameID, GameVoteStartedPayload{
			GameID:    payload.GameID,
			RoomID:    payload.RoomID,
			DayNumber: payload.DayNumber,
		})
	}
	if payload.ToPhase == string(shared.GamePhaseNightKiller) {
		p.PublishRoomAndGame("game.day_started", roomKey, payload.GameID, GameDayStartedPayload{
			GameID:    payload.GameID,
			RoomID:    payload.RoomID,
			DayNumber: payload.DayNumber,
		})
	}
	if payload.ToPhase == string(shared.GamePhaseEnded) {
		p.PublishRoomAndGame("game.ended", roomKey, payload.GameID, GameEndedPayload{
			GameID: payload.GameID,
			RoomID: payload.RoomID,
		})
	}
}

func encodeEnvelope(event string, payload any) ([]byte, error) {
	msg := EventEnvelope{Event: event, Payload: payload}
	return json.Marshal(msg)
}
