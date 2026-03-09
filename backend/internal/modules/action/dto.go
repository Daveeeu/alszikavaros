package action

import "github.com/Daveeeu/alszikavaros/backend/internal/shared"

type SubmitNightActionRequest struct {
	TargetPlayerID string `json:"targetPlayerId"`
}

type SubmitNightActionResponse struct {
	GameID       string           `json:"gameId"`
	Phase        shared.GamePhase `json:"phase"`
	Transitioned bool             `json:"transitioned"`
	RoundNumber  int              `json:"roundNumber"`
}
