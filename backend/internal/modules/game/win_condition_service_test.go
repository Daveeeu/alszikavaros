package game

import (
	"testing"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

func TestWinnerFromAliveRoles_VillagersWinWhenNoKillers(t *testing.T) {
	roles := []PlayerRole{
		{PlayerID: "d1", Role: shared.RoleDoctor},
		{PlayerID: "v1", Role: shared.RoleVillager},
		{PlayerID: "v2", Role: shared.RoleVillager},
	}

	got := winnerFromAliveRoles(roles)
	if got != shared.WinnerTypeVillagers {
		t.Fatalf("expected villagers winner, got %s", got)
	}
}

func TestWinnerFromAliveRoles_KillersWinWhenParityReached(t *testing.T) {
	roles := []PlayerRole{
		{PlayerID: "k1", Role: shared.RoleKiller},
		{PlayerID: "k2", Role: shared.RoleKiller},
		{PlayerID: "v1", Role: shared.RoleVillager},
		{PlayerID: "d1", Role: shared.RoleDoctor},
	}

	got := winnerFromAliveRoles(roles)
	if got != shared.WinnerTypeKillers {
		t.Fatalf("expected killers winner, got %s", got)
	}
}

func TestWinnerFromAliveRoles_NoWinnerYet(t *testing.T) {
	roles := []PlayerRole{
		{PlayerID: "k1", Role: shared.RoleKiller},
		{PlayerID: "v1", Role: shared.RoleVillager},
		{PlayerID: "v2", Role: shared.RoleVillager},
		{PlayerID: "d1", Role: shared.RoleDoctor},
	}

	got := winnerFromAliveRoles(roles)
	if got != shared.WinnerTypeNone {
		t.Fatalf("expected no winner, got %s", got)
	}
}
