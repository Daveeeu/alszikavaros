package game

import (
	"fmt"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
)

type StartGameInput struct {
	RoomID               string
	ParticipantPlayerIDs []string
}

type StartService struct {
	repo         *Repository
	roleAssigner *RoleAssignmentService
}

func NewStartService(repo *Repository, roleAssigner *RoleAssignmentService) *StartService {
	return &StartService{repo: repo, roleAssigner: roleAssigner}
}

func (s *StartService) StartInTx(tx *gorm.DB, input StartGameInput) (*Game, error) {
	game := &Game{
		ID:        generateGameID(),
		RoomID:    input.RoomID,
		Phase:     shared.GamePhaseRoleReveal,
		DayNumber: 1,
		Winner:    shared.WinnerTypeNone,
	}
	if err := s.repo.CreateGame(tx, game); err != nil {
		return nil, err
	}

	assigned := s.roleAssigner.AssignRoles(input.ParticipantPlayerIDs)
	roles := make([]PlayerRole, 0, len(input.ParticipantPlayerIDs))
	for _, playerID := range input.ParticipantPlayerIDs {
		roles = append(roles, PlayerRole{
			ID:       generatePlayerRoleID(),
			GameID:   game.ID,
			PlayerID: playerID,
			Role:     assigned[playerID],
		})
	}

	if err := s.repo.CreateRoles(tx, roles); err != nil {
		return nil, err
	}

	return game, nil
}

func generateGameID() string {
	return fmt.Sprintf("game-%d", time.Now().UnixNano())
}

func generatePlayerRoleID() string {
	return fmt.Sprintf("prole-%d", time.Now().UnixNano())
}
