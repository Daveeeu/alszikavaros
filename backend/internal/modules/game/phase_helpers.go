package game

import "github.com/Daveeeu/alszikavaros/backend/internal/shared"

func CanPlayerActInPhase(phase shared.GamePhase, role shared.Role, isAlive bool, hasSubmittedAction bool) bool {
	if !isAlive || hasSubmittedAction {
		return false
	}

	switch phase {
	case shared.GamePhaseNightKiller:
		return role == shared.RoleKiller
	case shared.GamePhaseNightDoctor:
		return role == shared.RoleDoctor
	default:
		return false
	}
}

func CanPlayerVote(phase shared.GamePhase, isAlive bool, hasVoted bool) bool {
	if !isAlive || hasVoted {
		return false
	}
	return phase == shared.GamePhaseVoting
}

func NextPhase(current shared.GamePhase) shared.GamePhase {
	switch current {
	case shared.GamePhaseRoleReveal:
		return shared.GamePhaseNightKiller
	case shared.GamePhaseNightKiller:
		return shared.GamePhaseNightDoctor
	case shared.GamePhaseNightDoctor:
		return shared.GamePhaseNightResolve
	case shared.GamePhaseNightResolve:
		return shared.GamePhaseDayReveal
	case shared.GamePhaseDayReveal:
		return shared.GamePhaseDiscussion
	case shared.GamePhaseDiscussion:
		return shared.GamePhaseVoting
	case shared.GamePhaseVoting:
		return shared.GamePhaseVoteResult
	case shared.GamePhaseVoteResult:
		return shared.GamePhaseNightKiller
	default:
		return shared.GamePhaseEnded
	}
}
