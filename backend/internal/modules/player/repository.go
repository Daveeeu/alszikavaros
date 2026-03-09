package player

import "gorm.io/gorm"

type Repository struct{ db *gorm.DB }

func NewRepository(db *gorm.DB) *Repository { return &Repository{db: db} }

func (r *Repository) Create(p *Player) error { return r.db.Create(p).Error }

func (r *Repository) ListByRoomID(roomID string) ([]Player, error) {
	var out []Player
	err := r.db.Where("room_id = ?", roomID).Find(&out).Error
	return out, err
}
