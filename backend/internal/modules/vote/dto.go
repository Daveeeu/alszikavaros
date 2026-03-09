package vote

import "github.com/Daveeeu/alszikavaros/backend/internal/shared"

type SubmitVoteRequest struct {
	TargetPlayerID string `json:"targetPlayerId"`
}

type SubmitVoteResponse struct {
	GameID       string           `json:"gameId"`
	RoomID       string           `json:"roomId"`
	Phase        shared.GamePhase `json:"phase"`
	DayNumber    int              `json:"dayNumber"`
	Transitioned bool             `json:"transitioned"`
}
