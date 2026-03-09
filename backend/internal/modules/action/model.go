package action

import (
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type NightAction struct {
	ID             string      `gorm:"primaryKey;size:64" json:"id"`
	GameID         string      `gorm:"index;size:64;not null" json:"gameId"`
	PlayerID       string      `gorm:"index;size:64;not null" json:"playerId"`
	Role           shared.Role `gorm:"type:varchar(20);not null" json:"role"`
	TargetPlayerID string      `gorm:"index;size:64;not null" json:"targetPlayerId"`
	RoundNumber    int         `gorm:"not null" json:"roundNumber"`
	SubmittedAt    time.Time   `gorm:"autoCreateTime" json:"submittedAt"`
}
