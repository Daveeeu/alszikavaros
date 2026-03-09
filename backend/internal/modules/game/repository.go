package game

import (
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Repository struct{ db *gorm.DB }

func NewRepository(db *gorm.DB) *Repository { return &Repository{db: db} }

func (r *Repository) Transaction(fn func(tx *gorm.DB) error) error {
	return r.db.Transaction(fn)
}

func (r *Repository) CreateGame(tx *gorm.DB, g *Game) error {
	return tx.Create(g).Error
}

func (r *Repository) CreateRoles(tx *gorm.DB, roles []PlayerRole) error {
	if len(roles) == 0 {
		return nil
	}
	return tx.Create(&roles).Error
}

func (r *Repository) FindByID(id string) (*Game, error) {
	var g Game
	if err := r.db.First(&g, "id = ?", id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrGameNotFound
		}
		return nil, err
	}
	return &g, nil
}

func (r *Repository) FindByIDForUpdate(tx *gorm.DB, id string) (*Game, error) {
	var g Game
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("id = ?", id).First(&g).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrGameNotFound
		}
		return nil, err
	}
	return &g, nil
}

func (r *Repository) UpdateGame(tx *gorm.DB, g *Game) error {
	return tx.Save(g).Error
}

func (r *Repository) SetPlayerAlive(tx *gorm.DB, playerID string, isAlive bool) error {
	return tx.Model(&player.Player{}).Where("id = ?", playerID).Update("is_alive", isAlive).Error
}

func (r *Repository) FindPlayerByID(playerID string) (*player.Player, error) {
	var p player.Player
	if err := r.db.Where("id = ?", playerID).First(&p).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUnauthorized
		}
		return nil, err
	}
	return &p, nil
}

func (r *Repository) FindPlayerByIDTx(tx *gorm.DB, playerID string) (*player.Player, error) {
	var p player.Player
	if err := tx.Where("id = ?", playerID).First(&p).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUnauthorized
		}
		return nil, err
	}
	return &p, nil
}

func (r *Repository) FindRole(gameID, playerID string) (*PlayerRole, error) {
	var pr PlayerRole
	if err := r.db.Where("game_id = ? AND player_id = ?", gameID, playerID).First(&pr).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrPlayerNotInGame
		}
		return nil, err
	}
	return &pr, nil
}

func (r *Repository) FindRoleTx(tx *gorm.DB, gameID, playerID string) (*PlayerRole, error) {
	var pr PlayerRole
	if err := tx.Where("game_id = ? AND player_id = ?", gameID, playerID).First(&pr).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrPlayerNotInGame
		}
		return nil, err
	}
	return &pr, nil
}

func (r *Repository) ListAlivePlayers(roomID string) ([]player.Player, error) {
	var players []player.Player
	err := r.db.Where("room_id = ? AND is_alive = ?", roomID, true).Order("joined_at ASC").Find(&players).Error
	return players, err
}

func (r *Repository) ListPlayersByRoomID(roomID string) ([]player.Player, error) {
	var players []player.Player
	err := r.db.Where("room_id = ?", roomID).Order("joined_at ASC").Find(&players).Error
	return players, err
}

func (r *Repository) CountAlivePlayers(tx *gorm.DB, roomID string) (int64, error) {
	var count int64
	err := tx.Model(&player.Player{}).Where("room_id = ? AND is_alive = ?", roomID, true).Count(&count).Error
	return count, err
}

func (r *Repository) CountAlivePlayersByRole(tx *gorm.DB, gameID, roomID string, role shared.Role) (int64, error) {
	var count int64
	err := tx.Table("player_roles pr").
		Joins("JOIN players p ON p.id = pr.player_id").
		Where("pr.game_id = ? AND p.room_id = ? AND p.is_alive = ? AND pr.role = ?", gameID, roomID, true, role).
		Count(&count).Error
	return count, err
}

func (r *Repository) ListAliveRoles(tx *gorm.DB, gameID, roomID string) ([]PlayerRole, error) {
	var roles []PlayerRole
	err := tx.Table("player_roles pr").
		Select("pr.id, pr.game_id, pr.player_id, pr.role").
		Joins("JOIN players p ON p.id = pr.player_id").
		Where("pr.game_id = ? AND p.room_id = ? AND p.is_alive = ?", gameID, roomID, true).
		Scan(&roles).Error
	return roles, err
}

func (r *Repository) ListNightActionsByRoleAndRound(tx *gorm.DB, gameID string, dayNumber int, role shared.Role) ([]NightActionRow, error) {
	var rows []NightActionRow
	err := tx.Table("night_actions").
		Select("game_id, player_id, role, target_player_id, round_number").
		Where("game_id = ? AND round_number = ? AND role = ?", gameID, dayNumber, role).
		Find(&rows).Error
	return rows, err
}

func (r *Repository) ListVotesByDay(tx *gorm.DB, gameID string, dayNumber int) ([]VoteRow, error) {
	var rows []VoteRow
	err := tx.Table("votes").
		Select("game_id, voter_player_id, target_player_id, day_number").
		Where("game_id = ? AND day_number = ?", gameID, dayNumber).
		Find(&rows).Error
	return rows, err
}

func (r *Repository) HasVoted(gameID, voterID string, dayNumber int) (bool, error) {
	var count int64
	err := r.db.Table("votes").
		Where("game_id = ? AND voter_player_id = ? AND day_number = ?", gameID, voterID, dayNumber).
		Count(&count).Error
	return count > 0, err
}

func (r *Repository) CountVotesByDay(tx *gorm.DB, gameID string, dayNumber int) (int64, error) {
	var count int64
	err := tx.Table("votes").Where("game_id = ? AND day_number = ?", gameID, dayNumber).Count(&count).Error
	return count, err
}

func (r *Repository) HasNightActionSubmitted(gameID, playerID string, roundNumber int) (bool, error) {
	var count int64
	err := r.db.Table("night_actions").
		Where("game_id = ? AND player_id = ? AND round_number = ?", gameID, playerID, roundNumber).
		Count(&count).Error
	return count > 0, err
}

func (r *Repository) HasNightActionSubmittedTx(tx *gorm.DB, gameID, playerID string, roundNumber int) (bool, error) {
	var count int64
	err := tx.Table("night_actions").
		Where("game_id = ? AND player_id = ? AND round_number = ?", gameID, playerID, roundNumber).
		Count(&count).Error
	return count > 0, err
}

func (r *Repository) CountNightActionsByRoleAndRound(tx *gorm.DB, gameID string, dayNumber int, role shared.Role) (int64, error) {
	var count int64
	err := tx.Table("night_actions").
		Where("game_id = ? AND round_number = ? AND role = ?", gameID, dayNumber, role).
		Count(&count).Error
	return count, err
}

func (r *Repository) AddPhaseLog(tx *gorm.DB, gameID string, phase shared.GamePhase, dayNumber int, eventName string, payload any) error {
	payloadJSON, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	logRow := &PhaseLog{
		ID:        fmt.Sprintf("plog-%s-%d", gameID, time.Now().UnixNano()),
		GameID:    gameID,
		Phase:     phase,
		DayNumber: dayNumber,
		EventName: eventName,
		Payload:   string(payloadJSON),
	}
	return tx.Create(logRow).Error
}

func (r *Repository) SetLatestNightResult(tx *gorm.DB, gameID string, result *NightResolution) error {
	payloadJSON, err := json.Marshal(result)
	if err != nil {
		return err
	}
	return tx.Model(&Game{}).Where("id = ?", gameID).Update("latest_night_result", string(payloadJSON)).Error
}

func (r *Repository) SetLatestVoteResult(tx *gorm.DB, gameID string, result *VoteResolution) error {
	payloadJSON, err := json.Marshal(result)
	if err != nil {
		return err
	}
	return tx.Model(&Game{}).Where("id = ?", gameID).Update("latest_vote_result", string(payloadJSON)).Error
}

func (r *Repository) HasRoleRevealConfirmation(tx *gorm.DB, gameID, playerID string) (bool, error) {
	var count int64
	err := tx.Model(&PhaseLog{}).
		Where("game_id = ? AND event_name = ? AND payload LIKE ?", gameID, "role_reveal.confirmed", "%\"playerId\":\""+playerID+"\"%").
		Count(&count).Error
	return count > 0, err
}

func (r *Repository) CountRoleRevealConfirmations(tx *gorm.DB, gameID string) (int64, error) {
	var count int64
	err := tx.Model(&PhaseLog{}).Where("game_id = ? AND event_name = ?", gameID, "role_reveal.confirmed").Count(&count).Error
	return count, err
}

func (r *Repository) HasRoleRevealConfirmationByPlayer(gameID, playerID string) (bool, error) {
	var count int64
	err := r.db.Model(&PhaseLog{}).
		Where("game_id = ? AND event_name = ? AND payload LIKE ?", gameID, "role_reveal.confirmed", "%\"playerId\":\""+playerID+"\"%").
		Count(&count).Error
	return count > 0, err
}

func (r *Repository) IsCurrentRoomHost(tx *gorm.DB, roomID, playerID string) (bool, error) {
	type row struct {
		HostPlayerID *string `gorm:"column:host_player_id"`
	}

	var out row
	if err := tx.Table("rooms").Select("host_player_id").Where("id = ?", roomID).First(&out).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return false, ErrGameNotFound
		}
		return false, err
	}
	return out.HostPlayerID != nil && *out.HostPlayerID == playerID, nil
}
