package vote

import "time"

type Vote struct {
	ID             string    `gorm:"primaryKey;size:64" json:"id"`
	GameID         string    `gorm:"index;size:64;not null" json:"gameId"`
	VoterPlayerID  string    `gorm:"index;size:64;not null" json:"voterPlayerId"`
	TargetPlayerID string    `gorm:"index;size:64;not null" json:"targetPlayerId"`
	DayNumber      int       `gorm:"not null" json:"dayNumber"`
	SubmittedAt    time.Time `gorm:"autoCreateTime" json:"submittedAt"`
}
