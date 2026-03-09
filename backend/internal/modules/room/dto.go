package room

import (
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type CreateRoomRequest struct {
	PlayerName string `json:"playerName"`
}

type JoinRoomRequest struct {
	PlayerName string `json:"playerName"`
	RoomCode   string `json:"roomCode"`
}

type PlayerDTO struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	IsHost      bool      `json:"isHost"`
	IsAlive     bool      `json:"isAlive"`
	IsConnected bool      `json:"isConnected"`
	JoinedAt    time.Time `json:"joinedAt"`
}

type RoomStateDTO struct {
	ID            string      `json:"id"`
	Code          string      `json:"code"`
	Status        string      `json:"status"`
	HostPlayerID  string      `json:"hostPlayerId,omitempty"`
	CurrentGameID *string     `json:"currentGameId,omitempty"`
	CreatedAt     time.Time   `json:"createdAt"`
	UpdatedAt     time.Time   `json:"updatedAt"`
	Players       []PlayerDTO `json:"players"`
	Host          *PlayerDTO  `json:"host,omitempty"`
}

type RoomAuthResponse struct {
	Room         RoomStateDTO `json:"room"`
	PlayerID     string       `json:"playerId"`
	SessionToken string       `json:"sessionToken"`
}

type RestartRoomResponse struct {
	Room   RoomStateDTO     `json:"room"`
	GameID string           `json:"gameId"`
	Phase  shared.GamePhase `json:"phase"`
}
