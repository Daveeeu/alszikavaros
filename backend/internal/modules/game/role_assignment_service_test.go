package game

import (
	"testing"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

func TestRoleAssignmentService_AssignRoles_MVPSetup(t *testing.T) {
	svc := NewRoleAssignmentService()
	playerIDs := []string{"p1", "p2", "p3", "p4", "p5", "p6"}

	got := svc.AssignRoles(playerIDs)
	if len(got) != len(playerIDs) {
		t.Fatalf("expected %d assigned roles, got %d", len(playerIDs), len(got))
	}

	killers := 0
	doctors := 0
	villagers := 0
	for _, pid := range playerIDs {
		role, ok := got[pid]
		if !ok {
			t.Fatalf("player %s missing from role assignment", pid)
		}
		switch role {
		case shared.RoleKiller:
			killers++
		case shared.RoleDoctor:
			doctors++
		case shared.RoleVillager:
			villagers++
		default:
			t.Fatalf("unexpected role for %s: %s", pid, role)
		}
	}

	if killers != 2 {
		t.Fatalf("expected 2 killers, got %d", killers)
	}
	if doctors != 1 {
		t.Fatalf("expected 1 doctor, got %d", doctors)
	}
	if villagers != 3 {
		t.Fatalf("expected 3 villagers, got %d", villagers)
	}
}
