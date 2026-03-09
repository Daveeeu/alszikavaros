package room

import (
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type Room struct {
	ID            string            `gorm:"primaryKey;size:64" json:"id"`
	Code          string            `gorm:"uniqueIndex;size:12;not null" json:"code"`
	Status        shared.RoomStatus `gorm:"index;type:varchar(20);not null" json:"status"`
	HostPlayerID  *string           `gorm:"index;size:64" json:"hostPlayerId,omitempty"`
	CurrentGameID *string           `gorm:"index;size:64" json:"currentGameId,omitempty"`
	CreatedAt     time.Time         `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt     time.Time         `gorm:"autoUpdateTime" json:"updatedAt"`
}
