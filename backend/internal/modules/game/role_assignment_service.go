package game

import (
	"math/rand"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type RoleAssignmentService struct{}

func NewRoleAssignmentService() *RoleAssignmentService {
	return &RoleAssignmentService{}
}

func (s *RoleAssignmentService) AssignRoles(playerIDs []string) map[string]shared.Role {
	ids := make([]string, len(playerIDs))
	copy(ids, playerIDs)

	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	r.Shuffle(len(ids), func(i, j int) {
		ids[i], ids[j] = ids[j], ids[i]
	})

	assigned := make(map[string]shared.Role, len(ids))
	for i, playerID := range ids {
		switch {
		case i < 2:
			assigned[playerID] = shared.RoleKiller
		case i < 3:
			assigned[playerID] = shared.RoleDoctor
		default:
			assigned[playerID] = shared.RoleVillager
		}
	}
	return assigned
}
