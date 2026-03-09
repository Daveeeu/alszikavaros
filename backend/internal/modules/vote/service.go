package vote

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/game"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
)

type Service struct {
	repo     *Repository
	gameRepo *game.Repository
	engine   *game.GameStateEngine
}

func NewService(repo *Repository, gameRepo *game.Repository, engine *game.GameStateEngine) *Service {
	return &Service{
		repo:     repo,
		gameRepo: gameRepo,
		engine:   engine,
	}
}

func (s *Service) Submit(gameID, requesterPlayerID string, req SubmitVoteRequest) (*SubmitVoteResponse, error) {
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}
	if strings.TrimSpace(req.TargetPlayerID) == "" {
		return nil, ErrInvalidTarget
	}

	dayNumber := 0
	err := s.gameRepo.Transaction(func(tx *gorm.DB) error {
		g, err := s.gameRepo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			if errors.Is(err, game.ErrGameNotFound) {
				return ErrGameNotFound
			}
			return err
		}
		if g.Phase != shared.GamePhaseVoting {
			return ErrInvalidPhase
		}

		playerRow, err := s.gameRepo.FindPlayerByIDTx(tx, requesterPlayerID)
		if err != nil {
			if errors.Is(err, game.ErrUnauthorized) {
				return ErrUnauthorized
			}
			return err
		}
		if playerRow.RoomID != g.RoomID {
			return ErrPlayerNotInGame
		}
		if !playerRow.IsAlive {
			return ErrPlayerDead
		}

		if _, err := s.gameRepo.FindRoleTx(tx, g.ID, playerRow.ID); err != nil {
			if errors.Is(err, game.ErrPlayerNotInGame) {
				return ErrPlayerNotInGame
			}
			return err
		}

		hasVoted, err := s.gameRepo.HasVoted(g.ID, playerRow.ID, g.DayNumber)
		if err != nil {
			return err
		}
		if hasVoted {
			return ErrDuplicateVote
		}

		targetPlayer, err := s.repo.FindAlivePlayerInRoom(tx, g.RoomID, req.TargetPlayerID)
		if err != nil {
			if errors.Is(err, ErrTargetNotAlive) {
				return ErrTargetNotAlive
			}
			return err
		}
		if targetPlayer.ID == playerRow.ID {
			return ErrSelfVoteNotAllowed
		}
		if _, err := s.gameRepo.FindRoleTx(tx, g.ID, targetPlayer.ID); err != nil {
			if errors.Is(err, game.ErrPlayerNotInGame) {
				return ErrInvalidTarget
			}
			return err
		}

		dayNumber = g.DayNumber
		v := &Vote{
			ID:             generateVoteID(),
			GameID:         g.ID,
			VoterPlayerID:  playerRow.ID,
			TargetPlayerID: targetPlayer.ID,
			DayNumber:      g.DayNumber,
		}
		return s.repo.CreateTx(tx, v)
	})
	if err != nil {
		return nil, err
	}

	progress, err := s.engine.AdvanceIfComplete(gameID)
	if err != nil {
		return nil, err
	}

	latest, err := s.gameRepo.FindByID(gameID)
	if err != nil {
		if errors.Is(err, game.ErrGameNotFound) {
			return nil, ErrGameNotFound
		}
		return nil, err
	}

	return &SubmitVoteResponse{
		GameID:       latest.ID,
		RoomID:       latest.RoomID,
		Phase:        latest.Phase,
		DayNumber:    dayNumber,
		Transitioned: progress != nil,
	}, nil
}

func generateVoteID() string {
	return fmt.Sprintf("vote-%d", time.Now().UnixNano())
}
