package game

import (
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type Game struct {
	ID                string            `gorm:"primaryKey;size:64" json:"id"`
	RoomID            string            `gorm:"index;size:64;not null" json:"roomId"`
	Phase             shared.GamePhase  `gorm:"index;type:varchar(40);not null" json:"phase"`
	DayNumber         int               `gorm:"not null;default:1" json:"dayNumber"`
	Winner            shared.WinnerType `gorm:"type:varchar(20);not null;default:'none'" json:"winner"`
	LatestNightResult string            `gorm:"type:text" json:"-"`
	LatestVoteResult  string            `gorm:"type:text" json:"-"`
	StartedAt         time.Time         `gorm:"autoCreateTime" json:"startedAt"`
	EndedAt           *time.Time        `json:"endedAt,omitempty"`
}

type PlayerRole struct {
	ID       string      `gorm:"primaryKey;size:64" json:"id"`
	GameID   string      `gorm:"index;size:64;not null" json:"gameId"`
	PlayerID string      `gorm:"index;size:64;not null" json:"playerId"`
	Role     shared.Role `gorm:"type:varchar(20);not null" json:"role"`
}

type PhaseLog struct {
	ID        string           `gorm:"primaryKey;size:64" json:"id"`
	GameID    string           `gorm:"index;size:64;not null" json:"gameId"`
	Phase     shared.GamePhase `gorm:"type:varchar(40);not null" json:"phase"`
	DayNumber int              `gorm:"not null;default:1" json:"dayNumber"`
	EventName string           `gorm:"size:64;not null" json:"eventName"`
	Payload   string           `gorm:"type:text" json:"payload"`
	CreatedAt time.Time        `gorm:"autoCreateTime" json:"createdAt"`
}
