package player

import "time"

type Player struct {
	ID           string    `gorm:"primaryKey;size:64" json:"id"`
	RoomID       string    `gorm:"index;size:64;not null" json:"roomId"`
	Name         string    `gorm:"size:80;not null" json:"name"`
	IsHost       bool      `gorm:"not null;default:false" json:"isHost"`
	IsAlive      bool      `gorm:"not null;default:true" json:"isAlive"`
	IsConnected  bool      `gorm:"not null;default:true" json:"isConnected"`
	SessionToken *string   `gorm:"size:120;uniqueIndex" json:"sessionToken,omitempty"`
	JoinedAt     time.Time `gorm:"autoCreateTime" json:"joinedAt"`
}
