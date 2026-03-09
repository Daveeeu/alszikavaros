package game

import (
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type NightResolution struct {
	RoundNumber          int            `json:"roundNumber"`
	AttackedPlayerID     *string        `json:"attackedPlayerId,omitempty"`
	DoctorTargetPlayerID *string        `json:"doctorTargetPlayerId,omitempty"`
	KilledPlayerID       *string        `json:"killedPlayerId,omitempty"`
	SavedByDoctor        bool           `json:"savedByDoctor"`
	WasKillerVoteTie     bool           `json:"wasKillerVoteTie"`
	KillerVoteCounts     map[string]int `json:"killerVoteCounts"`
	ResolvedAt           time.Time      `json:"resolvedAt"`
}

type VoteResolution struct {
	DayNumber          int            `json:"dayNumber"`
	EliminatedPlayerID *string        `json:"eliminatedPlayerId,omitempty"`
	Tie                bool           `json:"tie"`
	VoteCounts         map[string]int `json:"voteCounts"`
	ResolvedAt         time.Time      `json:"resolvedAt"`
}

type PhaseProgressResult struct {
	FromPhase shared.GamePhase  `json:"fromPhase"`
	ToPhase   shared.GamePhase  `json:"toPhase"`
	DayNumber int               `json:"dayNumber"`
	Winner    shared.WinnerType `json:"winner"`
}

type NightActionRow struct {
	GameID         string      `gorm:"column:game_id"`
	PlayerID       string      `gorm:"column:player_id"`
	Role           shared.Role `gorm:"column:role"`
	TargetPlayerID string      `gorm:"column:target_player_id"`
	RoundNumber    int         `gorm:"column:round_number"`
}

type VoteRow struct {
	GameID         string `gorm:"column:game_id"`
	VoterPlayerID  string `gorm:"column:voter_player_id"`
	TargetPlayerID string `gorm:"column:target_player_id"`
	DayNumber      int    `gorm:"column:day_number"`
}
