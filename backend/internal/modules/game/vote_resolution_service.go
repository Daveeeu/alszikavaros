package game

import (
	"errors"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
)

type VoteResolutionOutcome struct {
	Result *VoteResolution
	Winner shared.WinnerType
}

type VoteResolutionService struct {
	repo       *Repository
	winChecker *WinConditionService
}

func NewVoteResolutionService(repo *Repository) *VoteResolutionService {
	return &VoteResolutionService{
		repo:       repo,
		winChecker: NewWinConditionService(repo),
	}
}

func (s *VoteResolutionService) ResolveVotes(gameID string) (*VoteResolutionOutcome, error) {
	var outcome *VoteResolutionOutcome
	var fromPhase shared.GamePhase

	err := s.repo.Transaction(func(tx *gorm.DB) error {
		g, err := s.repo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			return err
		}
		if g.Phase != shared.GamePhaseVoting {
			return ErrInvalidPhaseTransition
		}
		fromPhase = g.Phase

		resolved, err := s.ResolveVotesInTx(tx, g)
		if err != nil {
			return err
		}

		if resolved.Winner != shared.WinnerTypeNone {
			g.Winner = resolved.Winner
			g.Phase = shared.GamePhaseEnded
			now := nowUTC()
			g.EndedAt = &now
		} else {
			g.Phase = shared.GamePhaseNightKiller
			g.DayNumber++
		}

		if err := s.repo.UpdateGame(tx, g); err != nil {
			return err
		}
		if err := s.repo.AddPhaseLog(tx, g.ID, g.Phase, g.DayNumber, "phase.changed", map[string]any{
			"from": string(fromPhase),
			"to":   string(g.Phase),
		}); err != nil {
			return err
		}

		outcome = resolved
		return nil
	})
	if err != nil {
		if errors.Is(err, ErrGameNotFound) {
			return nil, ErrGameNotFound
		}
		return nil, err
	}
	return outcome, nil
}

func (s *VoteResolutionService) ResolveVotesInTx(tx *gorm.DB, g *Game) (*VoteResolutionOutcome, error) {
	votesRows, err := s.repo.ListVotesByDay(tx, g.ID, g.DayNumber)
	if err != nil {
		return nil, err
	}

	aliveRolesBefore, err := s.repo.ListAliveRoles(tx, g.ID, g.RoomID)
	if err != nil {
		return nil, err
	}

	aliveSet := make(map[string]struct{}, len(aliveRolesBefore))
	for _, role := range aliveRolesBefore {
		aliveSet[role.PlayerID] = struct{}{}
	}

	eliminatedID, tie, voteCounts := selectVoteOutcomeForAliveTargets(votesRows, aliveSet)
	if eliminatedID != nil {
		if err := s.repo.SetPlayerAlive(tx, *eliminatedID, false); err != nil {
			return nil, err
		}
	}

	result := &VoteResolution{
		DayNumber:          g.DayNumber,
		EliminatedPlayerID: eliminatedID,
		Tie:                tie,
		VoteCounts:         voteCounts,
		ResolvedAt:         time.Now(),
	}

	if err := s.repo.SetLatestVoteResult(tx, g.ID, result); err != nil {
		return nil, err
	}
	if err := s.repo.AddPhaseLog(tx, g.ID, g.Phase, g.DayNumber, "vote_result.computed", result); err != nil {
		return nil, err
	}

	winner, err := s.winChecker.CheckWinConditionInTx(tx, g)
	if err != nil {
		return nil, err
	}

	return &VoteResolutionOutcome{
		Result: result,
		Winner: winner,
	}, nil
}

func selectVoteOutcomeForAliveTargets(votesRows []VoteRow, aliveTargets map[string]struct{}) (*string, bool, map[string]int) {
	countByTarget := map[string]int{}
	for _, v := range votesRows {
		if _, ok := aliveTargets[v.TargetPlayerID]; !ok {
			continue
		}
		countByTarget[v.TargetPlayerID]++
	}
	if len(countByTarget) == 0 {
		return nil, false, countByTarget
	}

	maxVotes := 0
	leaders := make([]string, 0)
	for target, votesCount := range countByTarget {
		if votesCount > maxVotes {
			maxVotes = votesCount
			leaders = []string{target}
			continue
		}
		if votesCount == maxVotes {
			leaders = append(leaders, target)
		}
	}
	if len(leaders) == 0 {
		return nil, false, countByTarget
	}
	if len(leaders) > 1 {
		return nil, true, countByTarget
	}
	winner := leaders[0]
	return &winner, false, countByTarget
}
