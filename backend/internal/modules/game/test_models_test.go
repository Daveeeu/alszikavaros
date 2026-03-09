package game

import "github.com/Daveeeu/alszikavaros/backend/internal/shared"

type testRoom struct {
	ID           string            `gorm:"primaryKey;size:64"`
	Code         string            `gorm:"uniqueIndex;size:12;not null"`
	Status       shared.RoomStatus `gorm:"index;type:varchar(20);not null"`
	HostPlayerID *string           `gorm:"index;size:64"`
}

func (testRoom) TableName() string { return "rooms" }

type testPlayer struct {
	ID          string `gorm:"primaryKey;size:64"`
	RoomID      string `gorm:"index;size:64;not null"`
	Name        string `gorm:"size:80;not null"`
	IsHost      bool   `gorm:"not null;default:false"`
	IsAlive     bool   `gorm:"not null;default:true"`
	IsConnected bool   `gorm:"not null;default:true"`
}

func (testPlayer) TableName() string { return "players" }
