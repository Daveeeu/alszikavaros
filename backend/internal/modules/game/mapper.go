package game

import (
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

func mapPlayersToSummary(players []player.Player) []PlayerSummaryDTO {
	out := make([]PlayerSummaryDTO, 0, len(players))
	for _, p := range players {
		out = append(out, mapPlayerToSummary(p))
	}
	return out
}

func mapPlayerToSummary(p player.Player) PlayerSummaryDTO {
	return PlayerSummaryDTO{
		ID:          p.ID,
		Name:        p.Name,
		IsAlive:     p.IsAlive,
		IsConnected: p.IsConnected,
		IsHost:      p.IsHost,
	}
}

func mapTargets(players []player.Player, currentPlayerID string, includeSelf bool) []TargetPlayerDTO {
	out := make([]TargetPlayerDTO, 0)
	for _, p := range players {
		if !includeSelf && p.ID == currentPlayerID {
			continue
		}
		if !p.IsAlive {
			continue
		}
		out = append(out, TargetPlayerDTO{ID: p.ID, Name: p.Name})
	}
	return out
}

func mapRoleRevealSummary(role shared.Role, confirmed bool) *RoleRevealSummaryDTO {
	roleCopy := role
	return &RoleRevealSummaryDTO{
		Role:      &roleCopy,
		Confirmed: confirmed,
	}
}

func mapDayResultSummary(night *NightResolution) *DayResultSummaryDTO {
	if night == nil {
		return nil
	}
	return &DayResultSummaryDTO{
		DayNumber:        night.RoundNumber,
		KilledPlayerID:   night.KilledPlayerID,
		NobodyDied:       night.KilledPlayerID == nil,
		SavedByDoctor:    night.SavedByDoctor,
		AttackedPlayerID: night.AttackedPlayerID,
		DoctorTargetID:   night.DoctorTargetPlayerID,
	}
}

func mapVoteResultSummary(vote *VoteResolution) *VoteResultSummaryDTO {
	if vote == nil {
		return nil
	}
	return &VoteResultSummaryDTO{
		DayNumber:          vote.DayNumber,
		EliminatedPlayerID: vote.EliminatedPlayerID,
		Tie:                vote.Tie,
	}
}

func mapGameEndSummary(winner shared.WinnerType, dayNumber int, survivors []player.Player) *GameEndSummaryDTO {
	if winner == shared.WinnerTypeNone {
		return nil
	}
	return &GameEndSummaryDTO{
		Winner:         winner,
		EndedDayNumber: dayNumber,
		Survivors:      mapPlayersToSummary(survivors),
	}
}
