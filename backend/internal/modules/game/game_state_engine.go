package game

import (
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type GameStateEngine struct {
	repo       *Repository
	transition *PhaseTransitionService
}

func NewGameStateEngine(repo *Repository) *GameStateEngine {
	return &GameStateEngine{
		repo:       repo,
		transition: NewPhaseTransitionService(repo),
	}
}

func (e *GameStateEngine) CanPlayerAct(gameID, playerID string) (bool, error) {
	g, err := e.repo.FindByID(gameID)
	if err != nil {
		return false, err
	}

	p, err := e.repo.FindPlayerByID(playerID)
	if err != nil {
		return false, err
	}

	roleRow, err := e.repo.FindRole(gameID, playerID)
	if err != nil {
		return false, err
	}

	hasSubmittedAction := false
	if g.Phase == shared.GamePhaseNightKiller || g.Phase == shared.GamePhaseNightDoctor {
		hasSubmittedAction, err = e.repo.HasNightActionSubmitted(gameID, playerID, g.DayNumber)
		if err != nil {
			return false, err
		}
	}

	return CanPlayerActInPhase(g.Phase, roleRow.Role, p.IsAlive, hasSubmittedAction), nil
}

func (e *GameStateEngine) CanPlayerVote(gameID, playerID string) (bool, error) {
	g, err := e.repo.FindByID(gameID)
	if err != nil {
		return false, err
	}

	p, err := e.repo.FindPlayerByID(playerID)
	if err != nil {
		return false, err
	}

	hasVoted, err := e.repo.HasVoted(gameID, playerID, g.DayNumber)
	if err != nil {
		return false, err
	}

	return CanPlayerVote(g.Phase, p.IsAlive, hasVoted), nil
}

func (e *GameStateEngine) IsPhaseComplete(gameID string) (bool, error) {
	return e.transition.IsPhaseComplete(gameID)
}

func (e *GameStateEngine) NextPhase(current shared.GamePhase) shared.GamePhase {
	return NextPhase(current)
}

func (e *GameStateEngine) AdvanceIfComplete(gameID string) (*PhaseProgressResult, error) {
	return e.transition.AdvanceIfComplete(gameID)
}

func (e *GameStateEngine) ForceProgress(gameID string) (*PhaseProgressResult, error) {
	return e.transition.ForceProgress(gameID)
}

func (e *GameStateEngine) ConfirmRoleReveal(gameID, playerID string) error {
	return e.transition.ConfirmRoleReveal(gameID, playerID)
}
