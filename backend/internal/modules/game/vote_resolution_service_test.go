package game

import "testing"

func TestSelectVoteOutcomeForAliveTargets_ClearWinner(t *testing.T) {
	votes := []VoteRow{
		{TargetPlayerID: "p2"},
		{TargetPlayerID: "p2"},
		{TargetPlayerID: "p3"},
	}
	alive := map[string]struct{}{
		"p2": {},
		"p3": {},
	}

	eliminated, tie, counts := selectVoteOutcomeForAliveTargets(votes, alive)
	if tie {
		t.Fatal("expected no tie")
	}
	if eliminated == nil || *eliminated != "p2" {
		t.Fatalf("expected eliminated p2, got %#v", eliminated)
	}
	if counts["p2"] != 2 || counts["p3"] != 1 {
		t.Fatalf("unexpected vote counts: %#v", counts)
	}
}

func TestSelectVoteOutcomeForAliveTargets_TieMeansNoElimination(t *testing.T) {
	votes := []VoteRow{
		{TargetPlayerID: "p2"},
		{TargetPlayerID: "p3"},
	}
	alive := map[string]struct{}{
		"p2": {},
		"p3": {},
	}

	eliminated, tie, _ := selectVoteOutcomeForAliveTargets(votes, alive)
	if !tie {
		t.Fatal("expected tie")
	}
	if eliminated != nil {
		t.Fatalf("expected nil eliminated target on tie, got %#v", eliminated)
	}
}

func TestSelectVoteOutcomeForAliveTargets_IgnoreDeadTargets(t *testing.T) {
	votes := []VoteRow{
		{TargetPlayerID: "dead"},
		{TargetPlayerID: "dead"},
		{TargetPlayerID: "alive"},
	}
	alive := map[string]struct{}{
		"alive": {},
	}

	eliminated, tie, counts := selectVoteOutcomeForAliveTargets(votes, alive)
	if tie {
		t.Fatal("expected no tie")
	}
	if eliminated == nil || *eliminated != "alive" {
		t.Fatalf("expected eliminated alive, got %#v", eliminated)
	}
	if counts["dead"] != 0 {
		t.Fatalf("dead target should be ignored: %#v", counts)
	}
}
