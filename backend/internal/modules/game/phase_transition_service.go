package game

import (
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
)

type PhaseTransitionService struct {
	repo          *Repository
	nightResolver *NightResolutionService
	voteResolver  *VoteResolutionService
	winChecker    *WinConditionService
}

func NewPhaseTransitionService(repo *Repository) *PhaseTransitionService {
	return &PhaseTransitionService{
		repo:          repo,
		nightResolver: NewNightResolutionService(repo, NewRandomKillerTargetTieBreaker()),
		voteResolver:  NewVoteResolutionService(repo),
		winChecker:    NewWinConditionService(repo),
	}
}

func (s *PhaseTransitionService) ConfirmRoleReveal(gameID string, playerID string) error {
	return s.repo.Transaction(func(tx *gorm.DB) error {
		g, err := s.repo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			return err
		}
		if g.Phase != shared.GamePhaseRoleReveal {
			return ErrInvalidPhaseTransition
		}

		exists, err := s.repo.HasRoleRevealConfirmation(tx, gameID, playerID)
		if err != nil {
			return err
		}
		if exists {
			return nil
		}

		return s.repo.AddPhaseLog(tx, gameID, g.Phase, g.DayNumber, "role_reveal.confirmed", map[string]any{"playerId": playerID})
	})
}

func (s *PhaseTransitionService) IsPhaseComplete(gameID string) (bool, error) {
	var complete bool
	err := s.repo.Transaction(func(tx *gorm.DB) error {
		g, err := s.repo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			return err
		}
		complete, err = s.isPhaseCompleteInTx(tx, g)
		return err
	})
	if err != nil {
		return false, err
	}
	return complete, nil
}

func (s *PhaseTransitionService) ForceProgress(gameID string) (*PhaseProgressResult, error) {
	return s.advance(gameID, true)
}

func (s *PhaseTransitionService) AdvanceIfComplete(gameID string) (*PhaseProgressResult, error) {
	return s.advance(gameID, false)
}

func (s *PhaseTransitionService) StartDiscussion(gameID, requesterPlayerID string) (*PhaseProgressResult, error) {
	return s.manualTransition(gameID, requesterPlayerID, shared.GamePhaseDayReveal, shared.GamePhaseDiscussion)
}

func (s *PhaseTransitionService) StartVoting(gameID, requesterPlayerID string) (*PhaseProgressResult, error) {
	return s.manualTransition(gameID, requesterPlayerID, shared.GamePhaseDiscussion, shared.GamePhaseVoting)
}

func (s *PhaseTransitionService) advance(gameID string, force bool) (*PhaseProgressResult, error) {
	var out *PhaseProgressResult
	err := s.repo.Transaction(func(tx *gorm.DB) error {
		g, err := s.repo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			return err
		}

		if !force {
			complete, err := s.isPhaseCompleteInTx(tx, g)
			if err != nil {
				return err
			}
			if !complete {
				return nil
			}
		}

		from := g.Phase
		next, err := s.resolveNextPhaseInTx(tx, g, force)
		if err != nil {
			return err
		}

		g.Phase = next
		if from == shared.GamePhaseVoteResult && next == shared.GamePhaseNightKiller {
			g.DayNumber = g.DayNumber + 1
		}
		if next == shared.GamePhaseEnded && g.EndedAt == nil {
			now := nowUTC()
			g.EndedAt = &now
		}
		if err := s.repo.UpdateGame(tx, g); err != nil {
			return err
		}

		_ = s.repo.AddPhaseLog(tx, g.ID, g.Phase, g.DayNumber, "phase.changed", map[string]any{
			"from": string(from),
			"to":   string(next),
		})

		out = &PhaseProgressResult{
			FromPhase: from,
			ToPhase:   next,
			DayNumber: g.DayNumber,
			Winner:    g.Winner,
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (s *PhaseTransitionService) manualTransition(gameID, requesterPlayerID string, from, to shared.GamePhase) (*PhaseProgressResult, error) {
	var out *PhaseProgressResult
	err := s.repo.Transaction(func(tx *gorm.DB) error {
		g, err := s.repo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			return err
		}
		if g.Phase != from {
			return ErrInvalidPhaseTransition
		}

		isHost, err := s.repo.IsCurrentRoomHost(tx, g.RoomID, requesterPlayerID)
		if err != nil {
			return err
		}
		if !isHost {
			return ErrHostRequired
		}

		g.Phase = to
		if err := s.repo.UpdateGame(tx, g); err != nil {
			return err
		}
		if err := s.repo.AddPhaseLog(tx, g.ID, g.Phase, g.DayNumber, "phase.changed", map[string]any{
			"from": string(from),
			"to":   string(to),
		}); err != nil {
			return err
		}

		out = &PhaseProgressResult{
			FromPhase: from,
			ToPhase:   to,
			DayNumber: g.DayNumber,
			Winner:    g.Winner,
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (s *PhaseTransitionService) isPhaseCompleteInTx(tx *gorm.DB, g *Game) (bool, error) {
	switch g.Phase {
	case shared.GamePhaseRoleReveal:
		aliveCount, err := s.repo.CountAlivePlayers(tx, g.RoomID)
		if err != nil {
			return false, err
		}
		confirmedCount, err := s.repo.CountRoleRevealConfirmations(tx, g.ID)
		if err != nil {
			return false, err
		}
		return confirmedCount >= aliveCount, nil
	case shared.GamePhaseNightKiller:
		aliveKillers, err := s.repo.CountAlivePlayersByRole(tx, g.ID, g.RoomID, shared.RoleKiller)
		if err != nil {
			return false, err
		}
		actionsCount, err := s.repo.CountNightActionsByRoleAndRound(tx, g.ID, g.DayNumber, shared.RoleKiller)
		if err != nil {
			return false, err
		}
		return actionsCount >= aliveKillers, nil
	case shared.GamePhaseNightDoctor:
		aliveDoctors, err := s.repo.CountAlivePlayersByRole(tx, g.ID, g.RoomID, shared.RoleDoctor)
		if err != nil {
			return false, err
		}
		if aliveDoctors == 0 {
			return true, nil
		}
		actionsCount, err := s.repo.CountNightActionsByRoleAndRound(tx, g.ID, g.DayNumber, shared.RoleDoctor)
		if err != nil {
			return false, err
		}
		return actionsCount >= 1, nil
	case shared.GamePhaseNightResolve:
		return true, nil
	case shared.GamePhaseDayReveal:
		return true, nil
	case shared.GamePhaseDiscussion:
		return false, nil
	case shared.GamePhaseVoting:
		aliveCount, err := s.repo.CountAlivePlayers(tx, g.RoomID)
		if err != nil {
			return false, err
		}
		votesCount, err := s.repo.CountVotesByDay(tx, g.ID, g.DayNumber)
		if err != nil {
			return false, err
		}
		return votesCount >= aliveCount, nil
	case shared.GamePhaseVoteResult:
		return true, nil
	case shared.GamePhaseEnded:
		return false, nil
	default:
		return false, nil
	}
}

func (s *PhaseTransitionService) resolveNextPhaseInTx(tx *gorm.DB, g *Game, force bool) (shared.GamePhase, error) {
	if g.Phase == shared.GamePhaseDiscussion {
		if force {
			return shared.GamePhaseVoting, nil
		}
		return shared.GamePhaseDiscussion, nil
	}

	switch g.Phase {
	case shared.GamePhaseVoting:
		voteOutcome, err := s.voteResolver.ResolveVotesInTx(tx, g)
		if err != nil {
			return shared.GamePhaseEnded, err
		}
		if voteOutcome.Winner != shared.WinnerTypeNone {
			g.Winner = voteOutcome.Winner
		}
		return shared.GamePhaseVoteResult, nil
	case shared.GamePhaseNightResolve:
		_, err := s.nightResolver.ResolveNightInTx(tx, g)
		if err != nil {
			return shared.GamePhaseEnded, err
		}
		winner, err := s.winChecker.CheckWinConditionInTx(tx, g)
		if err != nil {
			return shared.GamePhaseEnded, err
		}
		if winner != shared.WinnerTypeNone {
			g.Winner = winner
			return shared.GamePhaseEnded, nil
		}
		return shared.GamePhaseDayReveal, nil
	case shared.GamePhaseVoteResult:
		winner, err := s.winChecker.CheckWinConditionInTx(tx, g)
		if err != nil {
			return shared.GamePhaseEnded, err
		}
		if winner != shared.WinnerTypeNone {
			g.Winner = winner
			return shared.GamePhaseEnded, nil
		}
		return shared.GamePhaseNightKiller, nil
	default:
		return NextPhase(g.Phase), nil
	}
}

func nowUTC() time.Time {
	return time.Now().UTC()
}
