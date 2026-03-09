package game

import (
	"errors"
	"math/rand"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
)

type KillerTargetTieBreaker interface {
	Choose(candidates []string) string
}

type RandomKillerTargetTieBreaker struct {
	rand *rand.Rand
}

func NewRandomKillerTargetTieBreaker() *RandomKillerTargetTieBreaker {
	return &RandomKillerTargetTieBreaker{rand: rand.New(rand.NewSource(time.Now().UnixNano()))}
}

func (b *RandomKillerTargetTieBreaker) Choose(candidates []string) string {
	if len(candidates) == 0 {
		return ""
	}
	return candidates[b.rand.Intn(len(candidates))]
}

type NightResolutionService struct {
	repo       *Repository
	tieBreaker KillerTargetTieBreaker
}

func NewNightResolutionService(repo *Repository, tieBreaker KillerTargetTieBreaker) *NightResolutionService {
	if tieBreaker == nil {
		tieBreaker = NewRandomKillerTargetTieBreaker()
	}
	return &NightResolutionService{repo: repo, tieBreaker: tieBreaker}
}

func (s *NightResolutionService) ResolveNight(gameID string) (*NightResolution, error) {
	var result *NightResolution
	err := s.repo.Transaction(func(tx *gorm.DB) error {
		g, err := s.repo.FindByIDForUpdate(tx, gameID)
		if err != nil {
			return err
		}
		if g.Phase != shared.GamePhaseNightResolve {
			return ErrInvalidPhaseTransition
		}

		resolved, err := s.ResolveNightInTx(tx, g)
		if err != nil {
			return err
		}

		g.Phase = shared.GamePhaseDayReveal
		if err := s.repo.UpdateGame(tx, g); err != nil {
			return err
		}

		result = resolved
		return nil
	})
	if err != nil {
		if errors.Is(err, ErrGameNotFound) {
			return nil, ErrGameNotFound
		}
		return nil, err
	}
	return result, nil
}

func (s *NightResolutionService) ResolveNightInTx(tx *gorm.DB, g *Game) (*NightResolution, error) {
	killerActions, err := s.repo.ListNightActionsByRoleAndRound(tx, g.ID, g.DayNumber, shared.RoleKiller)
	if err != nil {
		return nil, err
	}
	doctorActions, err := s.repo.ListNightActionsByRoleAndRound(tx, g.ID, g.DayNumber, shared.RoleDoctor)
	if err != nil {
		return nil, err
	}

	attackedPlayerID, tie, killerVotes := determineKillerTarget(killerActions, s.tieBreaker)
	var doctorTargetID *string
	if len(doctorActions) > 0 {
		t := doctorActions[0].TargetPlayerID
		doctorTargetID = &t
	}

	result := &NightResolution{
		RoundNumber:          g.DayNumber,
		AttackedPlayerID:     attackedPlayerID,
		DoctorTargetPlayerID: doctorTargetID,
		KilledPlayerID:       nil,
		SavedByDoctor:        false,
		WasKillerVoteTie:     tie,
		KillerVoteCounts:     killerVotes,
		ResolvedAt:           time.Now(),
	}

	if attackedPlayerID != nil {
		if doctorTargetID != nil && *doctorTargetID == *attackedPlayerID {
			result.SavedByDoctor = true
		} else {
			if err := s.repo.SetPlayerAlive(tx, *attackedPlayerID, false); err != nil {
				return nil, err
			}
			killed := *attackedPlayerID
			result.KilledPlayerID = &killed
		}
	}

	if err := s.repo.SetLatestNightResult(tx, g.ID, result); err != nil {
		return nil, err
	}
	if err := s.repo.AddPhaseLog(tx, g.ID, g.Phase, g.DayNumber, "night_resolve.result", result); err != nil {
		return nil, err
	}

	return result, nil
}

func determineKillerTarget(actions []NightActionRow, tieBreaker KillerTargetTieBreaker) (*string, bool, map[string]int) {
	if len(actions) == 0 {
		return nil, false, map[string]int{}
	}

	countByTarget := map[string]int{}
	for _, a := range actions {
		countByTarget[a.TargetPlayerID]++
	}

	maxVotes := 0
	leaders := make([]string, 0)
	for target, votes := range countByTarget {
		if votes > maxVotes {
			maxVotes = votes
			leaders = []string{target}
			continue
		}
		if votes == maxVotes {
			leaders = append(leaders, target)
		}
	}
	if len(leaders) == 0 {
		return nil, false, countByTarget
	}
	if len(leaders) == 1 {
		picked := leaders[0]
		return &picked, false, countByTarget
	}

	picked := tieBreaker.Choose(leaders)
	return &picked, true, countByTarget
}
