package game

import "github.com/Daveeeu/alszikavaros/backend/internal/shared"

type PlayerSummaryDTO struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	IsAlive     bool   `json:"isAlive"`
	IsConnected bool   `json:"isConnected"`
	IsHost      bool   `json:"isHost"`
}

type TargetPlayerDTO struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

type CurrentPlayerGameStateDTO struct {
	PlayerID         string            `json:"playerId"`
	Role             *shared.Role      `json:"role,omitempty"`
	IsAlive          bool              `json:"isAlive"`
	CanAct           bool              `json:"canAct"`
	HasActed         bool              `json:"hasActed"`
	HasVoted         bool              `json:"hasVoted"`
	AvailableTargets []TargetPlayerDTO `json:"availableTargets"`
}

type RoleRevealSummaryDTO struct {
	Role      *shared.Role `json:"role,omitempty"`
	Confirmed bool         `json:"confirmed"`
}

type DayResultSummaryDTO struct {
	DayNumber        int     `json:"dayNumber"`
	KilledPlayerID   *string `json:"killedPlayerId,omitempty"`
	NobodyDied       bool    `json:"nobodyDied"`
	SavedByDoctor    bool    `json:"savedByDoctor"`
	AttackedPlayerID *string `json:"attackedPlayerId,omitempty"`
	DoctorTargetID   *string `json:"doctorTargetPlayerId,omitempty"`
}

type VoteResultSummaryDTO struct {
	DayNumber          int     `json:"dayNumber"`
	EliminatedPlayerID *string `json:"eliminatedPlayerId,omitempty"`
	Tie                bool    `json:"tie"`
}

type GameEndSummaryDTO struct {
	Winner         shared.WinnerType  `json:"winner"`
	EndedDayNumber int                `json:"endedDayNumber"`
	Survivors      []PlayerSummaryDTO `json:"survivors"`
}

type FilteredGameStateResponse struct {
	GameID       string             `json:"gameId"`
	RoomID       string             `json:"roomId"`
	Phase        shared.GamePhase   `json:"phase"`
	DayNumber    int                `json:"dayNumber"`
	Winner       shared.WinnerType  `json:"winner"`
	Players      []PlayerSummaryDTO `json:"players"`
	AlivePlayers []PlayerSummaryDTO `json:"alivePlayers"`

	CurrentPlayer CurrentPlayerGameStateDTO `json:"currentPlayer"`
	RoleReveal    *RoleRevealSummaryDTO     `json:"roleReveal,omitempty"`
	DayResult     *DayResultSummaryDTO      `json:"dayResult,omitempty"`
	VoteResult    *VoteResultSummaryDTO     `json:"voteResult,omitempty"`
	GameEnd       *GameEndSummaryDTO        `json:"gameEnd,omitempty"`
}

type StartGameResponse struct {
	GameID string           `json:"gameId"`
	Phase  shared.GamePhase `json:"phase"`
}

type RoleRevealConfirmResponse struct {
	GameID       string           `json:"gameId"`
	Phase        shared.GamePhase `json:"phase"`
	Transitioned bool             `json:"transitioned"`
}

type PhaseTransitionResponse struct {
	GameID    string            `json:"gameId"`
	RoomID    string            `json:"roomId"`
	FromPhase shared.GamePhase  `json:"fromPhase"`
	ToPhase   shared.GamePhase  `json:"toPhase"`
	DayNumber int               `json:"dayNumber"`
	Winner    shared.WinnerType `json:"winner"`
}
