package game

import (
	"errors"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
)

type WinConditionResult struct {
	Winner shared.WinnerType `json:"winner"`
	Ended  bool              `json:"ended"`
}

type WinConditionService struct {
	repo *Repository
}

func NewWinConditionService(repo *Repository) *WinConditionService {
	return &WinConditionService{repo: repo}
}

func (s *WinConditionService) CheckWinCondition(gameID string) (*WinConditionResult, error) {
	var out *WinConditionResult

	err := s.repo.Transaction(func(tx *gorm.DB) error {
		g, err := s.repo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			return err
		}

		winner, err := s.CheckWinConditionInTx(tx, g)
		if err != nil {
			return err
		}
		if winner != shared.WinnerTypeNone {
			g.Winner = winner
			g.Phase = shared.GamePhaseEnded
			if g.EndedAt == nil {
				now := nowUTC()
				g.EndedAt = &now
			}
			if err := s.repo.UpdateGame(tx, g); err != nil {
				return err
			}
		}

		out = &WinConditionResult{
			Winner: winner,
			Ended:  winner != shared.WinnerTypeNone,
		}
		return nil
	})
	if err != nil {
		if errors.Is(err, ErrGameNotFound) {
			return nil, ErrGameNotFound
		}
		return nil, err
	}
	return out, nil
}

func (s *WinConditionService) CheckWinConditionInTx(tx *gorm.DB, g *Game) (shared.WinnerType, error) {
	roles, err := s.repo.ListAliveRoles(tx, g.ID, g.RoomID)
	if err != nil {
		return shared.WinnerTypeNone, err
	}
	return winnerFromAliveRoles(roles), nil
}

func winnerFromAliveRoles(roles []PlayerRole) shared.WinnerType {
	killerCount := 0
	nonKillerCount := 0
	for _, role := range roles {
		if role.Role == shared.RoleKiller {
			killerCount++
		} else {
			nonKillerCount++
		}
	}

	if killerCount == 0 {
		return shared.WinnerTypeVillagers
	}
	if killerCount >= nonKillerCount {
		return shared.WinnerTypeKillers
	}
	return shared.WinnerTypeNone
}
