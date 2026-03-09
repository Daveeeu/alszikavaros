package vote

import (
	"errors"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"gorm.io/gorm"
)

type Repository struct{ db *gorm.DB }

func NewRepository(db *gorm.DB) *Repository { return &Repository{db: db} }

func (r *Repository) Create(v *Vote) error { return r.db.Create(v).Error }

func (r *Repository) CreateTx(tx *gorm.DB, v *Vote) error { return tx.Create(v).Error }

func (r *Repository) FindAlivePlayerInRoom(tx *gorm.DB, roomID, playerID string) (*player.Player, error) {
	var p player.Player
	if err := tx.Where("id = ? AND room_id = ? AND is_alive = ?", playerID, roomID, true).First(&p).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrTargetNotAlive
		}
		return nil, err
	}
	return &p, nil
}
