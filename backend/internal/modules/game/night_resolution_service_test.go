package game

import (
	"testing"
)

type fixedTieBreaker struct {
	pick string
}

func (b fixedTieBreaker) Choose(candidates []string) string {
	if b.pick != "" {
		return b.pick
	}
	if len(candidates) == 0 {
		return ""
	}
	return candidates[0]
}

func TestDetermineKillerTarget_Majority(t *testing.T) {
	actions := []NightActionRow{
		{TargetPlayerID: "p4"},
		{TargetPlayerID: "p4"},
		{TargetPlayerID: "p5"},
	}

	target, tie, counts := determineKillerTarget(actions, fixedTieBreaker{})
	if tie {
		t.Fatal("expected no tie")
	}
	if target == nil || *target != "p4" {
		t.Fatalf("expected p4 target, got %#v", target)
	}
	if counts["p4"] != 2 || counts["p5"] != 1 {
		t.Fatalf("unexpected vote counts: %#v", counts)
	}
}

func TestDetermineKillerTarget_TieUsesTieBreaker(t *testing.T) {
	actions := []NightActionRow{
		{TargetPlayerID: "p4"},
		{TargetPlayerID: "p5"},
	}

	target, tie, counts := determineKillerTarget(actions, fixedTieBreaker{pick: "p5"})
	if !tie {
		t.Fatal("expected tie")
	}
	if target == nil || *target != "p5" {
		t.Fatalf("expected p5 tie-break target, got %#v", target)
	}
	if counts["p4"] != 1 || counts["p5"] != 1 {
		t.Fatalf("unexpected vote counts: %#v", counts)
	}
}

func TestDetermineKillerTarget_NoActions(t *testing.T) {
	target, tie, counts := determineKillerTarget(nil, fixedTieBreaker{})
	if tie {
		t.Fatal("expected no tie for empty action list")
	}
	if target != nil {
		t.Fatalf("expected nil target, got %#v", target)
	}
	if len(counts) != 0 {
		t.Fatalf("expected empty vote map, got %#v", counts)
	}
}

func TestNightResolution_DoctorSaveRule(t *testing.T) {
	gameID := "g1"
	round := 1

	killerActions := []NightActionRow{
		{GameID: gameID, PlayerID: "k1", Role: "killer", TargetPlayerID: "v1", RoundNumber: round},
		{GameID: gameID, PlayerID: "k2", Role: "killer", TargetPlayerID: "v1", RoundNumber: round},
	}
	doctorTargetID := "v1"

	attacked, _, _ := determineKillerTarget(killerActions, fixedTieBreaker{})
	if attacked == nil || *attacked != "v1" {
		t.Fatalf("expected attacked player v1, got %#v", attacked)
	}
	if doctorTargetID != "v1" {
		t.Fatalf("doctor save setup invalid: %s", doctorTargetID)
	}
}
