package room

import (
	"errors"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) Transaction(fn func(tx *gorm.DB) error) error {
	return r.db.Transaction(fn)
}

func (r *Repository) CreateRoom(tx *gorm.DB, room *Room) error {
	return tx.Create(room).Error
}

func (r *Repository) UpdateRoom(tx *gorm.DB, room *Room) error {
	return tx.Save(room).Error
}

func (r *Repository) CreatePlayer(tx *gorm.DB, p *player.Player) error {
	return tx.Create(p).Error
}

func (r *Repository) UpdatePlayer(tx *gorm.DB, p *player.Player) error {
	return tx.Save(p).Error
}

func (r *Repository) FindPlayerByIDForUpdate(tx *gorm.DB, playerID string) (*player.Player, error) {
	var p player.Player
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("id = ?", playerID).First(&p).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUnauthorized
		}
		return nil, err
	}
	return &p, nil
}

func (r *Repository) FindRoomByCode(code string) (*Room, error) {
	var room Room
	if err := r.db.Where("code = ?", code).First(&room).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrRoomNotFound
		}
		return nil, err
	}
	return &room, nil
}

func (r *Repository) FindRoomByCodeForUpdate(tx *gorm.DB, code string) (*Room, error) {
	var room Room
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("code = ?", code).First(&room).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrRoomNotFound
		}
		return nil, err
	}
	return &room, nil
}

func (r *Repository) RoomCodeExists(tx *gorm.DB, code string) (bool, error) {
	var count int64
	if err := tx.Model(&Room{}).Where("code = ?", code).Count(&count).Error; err != nil {
		return false, err
	}
	return count > 0, nil
}

func (r *Repository) FindPlayerByToken(tx *gorm.DB, token string) (*player.Player, error) {
	var p player.Player
	if err := tx.Where("session_token = ?", token).First(&p).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUnauthorized
		}
		return nil, err
	}
	return &p, nil
}

func (r *Repository) ListPlayersByRoomID(roomID string) ([]player.Player, error) {
	var players []player.Player
	err := r.db.Where("room_id = ?", roomID).Order("joined_at ASC").Find(&players).Error
	return players, err
}

func (r *Repository) ListPlayersByRoomIDForUpdate(tx *gorm.DB, roomID string) ([]player.Player, error) {
	var players []player.Player
	err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("room_id = ?", roomID).Order("joined_at ASC").Find(&players).Error
	return players, err
}

func (r *Repository) ListConnectedPlayersByRoomIDForUpdate(tx *gorm.DB, roomID string) ([]player.Player, error) {
	var players []player.Player
	err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("room_id = ? AND is_connected = ?", roomID, true).
		Order("joined_at ASC").
		Find(&players).Error
	return players, err
}

func (r *Repository) MarkAllPlayersAlive(tx *gorm.DB, roomID string) error {
	return tx.Model(&player.Player{}).Where("room_id = ?", roomID).Update("is_alive", true).Error
}

func (r *Repository) ConnectedPlayerCount(tx *gorm.DB, roomID string) (int64, error) {
	var count int64
	err := tx.Model(&player.Player{}).Where("room_id = ? AND is_connected = ?", roomID, true).Count(&count).Error
	return count, err
}
