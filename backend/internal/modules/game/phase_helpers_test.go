package game

import (
	"testing"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

func TestNextPhaseFlow(t *testing.T) {
	cases := []struct {
		current shared.GamePhase
		next    shared.GamePhase
	}{
		{shared.GamePhaseRoleReveal, shared.GamePhaseNightKiller},
		{shared.GamePhaseNightKiller, shared.GamePhaseNightDoctor},
		{shared.GamePhaseNightDoctor, shared.GamePhaseNightResolve},
		{shared.GamePhaseNightResolve, shared.GamePhaseDayReveal},
		{shared.GamePhaseDayReveal, shared.GamePhaseDiscussion},
		{shared.GamePhaseDiscussion, shared.GamePhaseVoting},
		{shared.GamePhaseVoting, shared.GamePhaseVoteResult},
		{shared.GamePhaseVoteResult, shared.GamePhaseNightKiller},
	}

	for _, tc := range cases {
		got := NextPhase(tc.current)
		if got != tc.next {
			t.Fatalf("next phase mismatch for %s: expected %s got %s", tc.current, tc.next, got)
		}
	}
}
