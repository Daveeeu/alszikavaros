package action

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
	rules    TargetingRules
}

func NewService(repo *Repository, gameRepo *game.Repository, engine *game.GameStateEngine, rules TargetingRules) *Service {
	return &Service{repo: repo, gameRepo: gameRepo, engine: engine, rules: rules}
}

func (s *Service) Submit(gameID, requesterPlayerID string, req SubmitNightActionRequest) (*SubmitNightActionResponse, error) {
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}
	if strings.TrimSpace(req.TargetPlayerID) == "" {
		return nil, ErrInvalidTarget
	}

	roundNumber := 0
	err := s.gameRepo.Transaction(func(tx *gorm.DB) error {
		g, err := s.gameRepo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			if errors.Is(err, game.ErrGameNotFound) {
				return ErrGameNotFound
			}
			return err
		}

		if g.Phase != shared.GamePhaseNightKiller && g.Phase != shared.GamePhaseNightDoctor {
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

		roleRow, err := s.gameRepo.FindRoleTx(tx, g.ID, playerRow.ID)
		if err != nil {
			if errors.Is(err, game.ErrPlayerNotInGame) {
				return ErrPlayerNotInGame
			}
			return err
		}

		hasSubmitted, err := s.gameRepo.HasNightActionSubmittedTx(tx, g.ID, playerRow.ID, g.DayNumber)
		if err != nil {
			return err
		}
		if hasSubmitted {
			return ErrDuplicateSubmission
		}

		if !game.CanPlayerActInPhase(g.Phase, roleRow.Role, playerRow.IsAlive, false) {
			return ErrRoleCannotAct
		}

		targetPlayer, err := s.repo.FindAlivePlayerInRoom(tx, g.RoomID, req.TargetPlayerID)
		if err != nil {
			if errors.Is(err, ErrTargetNotAlive) {
				return ErrTargetNotAlive
			}
			return err
		}
		if _, err := s.gameRepo.FindRoleTx(tx, g.ID, targetPlayer.ID); err != nil {
			if errors.Is(err, game.ErrPlayerNotInGame) {
				return ErrInvalidTarget
			}
			return err
		}

		if targetPlayer.ID == playerRow.ID && !s.rules.AllowsSelfTarget(roleRow.Role) {
			return ErrSelfTargetNotAllowed
		}

		roundNumber = g.DayNumber
		a := &NightAction{
			ID:             generateNightActionID(),
			GameID:         g.ID,
			PlayerID:       playerRow.ID,
			Role:           roleRow.Role,
			TargetPlayerID: targetPlayer.ID,
			RoundNumber:    g.DayNumber,
		}
		if err := s.repo.CreateTx(tx, a); err != nil {
			return err
		}

		return nil
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

	return &SubmitNightActionResponse{
		GameID:       latest.ID,
		Phase:        latest.Phase,
		Transitioned: progress != nil,
		RoundNumber:  roundNumber,
	}, nil
}

func generateNightActionID() string {
	return fmt.Sprintf("na-%d", time.Now().UnixNano())
}
