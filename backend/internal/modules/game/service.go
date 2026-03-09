package game

import (
	"strings"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

type Service struct {
	repo       *Repository
	transition *PhaseTransitionService
}

func NewService(repo *Repository) *Service {
	return &Service{
		repo:       repo,
		transition: NewPhaseTransitionService(repo),
	}
}

func (s *Service) GetState(gameID, requesterPlayerID string) (*FilteredGameStateResponse, error) {
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}

	g, err := s.repo.FindByID(gameID)
	if err != nil {
		return nil, err
	}

	requestPlayer, err := s.repo.FindPlayerByID(requesterPlayerID)
	if err != nil {
		return nil, err
	}
	if requestPlayer.RoomID != g.RoomID {
		return nil, ErrPlayerNotInGame
	}

	roleRow, err := s.repo.FindRole(g.ID, requestPlayer.ID)
	if err != nil {
		return nil, err
	}

	playersInRoom, err := s.repo.ListPlayersByRoomID(g.RoomID)
	if err != nil {
		return nil, err
	}
	alivePlayers, err := s.repo.ListAlivePlayers(g.RoomID)
	if err != nil {
		return nil, err
	}

	hasVoted, err := s.repo.HasVoted(g.ID, requestPlayer.ID, g.DayNumber)
	if err != nil {
		return nil, err
	}
	hasActed, err := s.computeHasActed(g, requestPlayer.ID)
	if err != nil {
		return nil, err
	}

	canAct, targets, err := s.computeActionAndTargets(g, requestPlayer.ID, requestPlayer.IsAlive, roleRow.Role, alivePlayers, hasVoted)
	if err != nil {
		return nil, err
	}

	var latestNightResult *NightResolution
	if shouldExposeNightResult(g.Phase) {
		parsed, err := parseNightResult(g.LatestNightResult)
		if err != nil {
			return nil, err
		}
		latestNightResult = parsed
	}
	var latestVoteResult *VoteResolution
	if shouldExposeVoteResult(g.Phase) {
		parsed, err := parseVoteResult(g.LatestVoteResult)
		if err != nil {
			return nil, err
		}
		latestVoteResult = parsed
	}

	role := roleRow.Role
	var roleReveal *RoleRevealSummaryDTO
	if g.Phase == shared.GamePhaseRoleReveal {
		roleReveal = mapRoleRevealSummary(role, hasActed)
	}
	dayResult := mapDayResultSummary(latestNightResult)
	voteResult := mapVoteResultSummary(latestVoteResult)
	gameEnd := mapGameEndSummary(g.Winner, g.DayNumber, alivePlayers)

	return &FilteredGameStateResponse{
		GameID:       g.ID,
		RoomID:       g.RoomID,
		Phase:        g.Phase,
		DayNumber:    g.DayNumber,
		Winner:       g.Winner,
		Players:      mapPlayersToSummary(playersInRoom),
		AlivePlayers: mapPlayersToSummary(alivePlayers),
		CurrentPlayer: CurrentPlayerGameStateDTO{
			PlayerID:         requestPlayer.ID,
			Role:             &role,
			IsAlive:          requestPlayer.IsAlive,
			CanAct:           canAct,
			HasActed:         hasActed,
			HasVoted:         hasVoted,
			AvailableTargets: targets,
		},
		RoleReveal: roleReveal,
		DayResult:  dayResult,
		VoteResult: voteResult,
		GameEnd:    gameEnd,
	}, nil
}

func (s *Service) ConfirmRoleReveal(gameID, requesterPlayerID string) (*RoleRevealConfirmResponse, error) {
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}

	g, err := s.repo.FindByID(gameID)
	if err != nil {
		return nil, err
	}

	requestPlayer, err := s.repo.FindPlayerByID(requesterPlayerID)
	if err != nil {
		return nil, err
	}
	if requestPlayer.RoomID != g.RoomID {
		return nil, ErrPlayerNotInGame
	}

	if _, err := s.repo.FindRole(g.ID, requestPlayer.ID); err != nil {
		return nil, err
	}

	if err := s.transition.ConfirmRoleReveal(gameID, requesterPlayerID); err != nil {
		return nil, err
	}

	progress, err := s.transition.AdvanceIfComplete(gameID)
	if err != nil {
		return nil, err
	}

	latest, err := s.repo.FindByID(gameID)
	if err != nil {
		return nil, err
	}

	return &RoleRevealConfirmResponse{
		GameID:       latest.ID,
		Phase:        latest.Phase,
		Transitioned: progress != nil,
	}, nil
}

func (s *Service) StartDiscussion(gameID, requesterPlayerID string) (*PhaseTransitionResponse, error) {
	return s.startManualPhase(gameID, requesterPlayerID, shared.GamePhaseDayReveal)
}

func (s *Service) StartVoting(gameID, requesterPlayerID string) (*PhaseTransitionResponse, error) {
	return s.startManualPhase(gameID, requesterPlayerID, shared.GamePhaseDiscussion)
}

func (s *Service) computeActionAndTargets(
	g *Game,
	currentPlayerID string,
	isAlive bool,
	role shared.Role,
	alivePlayers []player.Player,
	hasVoted bool,
) (bool, []TargetPlayerDTO, error) {
	if !isAlive {
		return false, []TargetPlayerDTO{}, nil
	}

	targets := make([]TargetPlayerDTO, 0)
	canAct := false

	switch g.Phase {
	case shared.GamePhaseNightKiller:
		submitted, err := s.repo.HasNightActionSubmitted(g.ID, currentPlayerID, g.DayNumber)
		if err != nil {
			return false, nil, err
		}
		if !CanPlayerActInPhase(g.Phase, role, isAlive, submitted) {
			return false, targets, nil
		}
		targets = mapTargets(alivePlayers, currentPlayerID, false)
		canAct = true
	case shared.GamePhaseNightDoctor:
		submitted, err := s.repo.HasNightActionSubmitted(g.ID, currentPlayerID, g.DayNumber)
		if err != nil {
			return false, nil, err
		}
		if !CanPlayerActInPhase(g.Phase, role, isAlive, submitted) {
			return false, targets, nil
		}
		targets = mapTargets(alivePlayers, currentPlayerID, true)
		canAct = true
	case shared.GamePhaseVoting:
		if !CanPlayerVote(g.Phase, isAlive, hasVoted) {
			return false, targets, nil
		}
		targets = mapTargets(alivePlayers, currentPlayerID, false)
		canAct = true
	}

	return canAct, targets, nil
}

func (s *Service) computeHasActed(g *Game, playerID string) (bool, error) {
	switch g.Phase {
	case shared.GamePhaseRoleReveal:
		return s.repo.HasRoleRevealConfirmationByPlayer(g.ID, playerID)
	case shared.GamePhaseNightKiller, shared.GamePhaseNightDoctor, shared.GamePhaseNightResolve:
		return s.repo.HasNightActionSubmitted(g.ID, playerID, g.DayNumber)
	default:
		return false, nil
	}
}

func shouldExposeNightResult(phase shared.GamePhase) bool {
	switch phase {
	case shared.GamePhaseDayReveal,
		shared.GamePhaseDiscussion,
		shared.GamePhaseVoting,
		shared.GamePhaseVoteResult,
		shared.GamePhaseEnded:
		return true
	default:
		return false
	}
}

func shouldExposeVoteResult(phase shared.GamePhase) bool {
	switch phase {
	case shared.GamePhaseVoteResult,
		shared.GamePhaseNightKiller,
		shared.GamePhaseNightDoctor,
		shared.GamePhaseNightResolve,
		shared.GamePhaseDayReveal,
		shared.GamePhaseDiscussion,
		shared.GamePhaseVoting,
		shared.GamePhaseEnded:
		return true
	default:
		return false
	}
}

func (s *Service) startManualPhase(gameID, requesterPlayerID string, expectedFrom shared.GamePhase) (*PhaseTransitionResponse, error) {
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}

	g, err := s.repo.FindByID(gameID)
	if err != nil {
		return nil, err
	}

	requestPlayer, err := s.repo.FindPlayerByID(requesterPlayerID)
	if err != nil {
		return nil, err
	}
	if requestPlayer.RoomID != g.RoomID {
		return nil, ErrPlayerNotInGame
	}

	var progress *PhaseProgressResult
	switch expectedFrom {
	case shared.GamePhaseDayReveal:
		progress, err = s.transition.StartDiscussion(gameID, requesterPlayerID)
	case shared.GamePhaseDiscussion:
		progress, err = s.transition.StartVoting(gameID, requesterPlayerID)
	default:
		return nil, ErrInvalidPhaseTransition
	}
	if err != nil {
		return nil, err
	}

	return &PhaseTransitionResponse{
		GameID:    g.ID,
		RoomID:    g.RoomID,
		FromPhase: progress.FromPhase,
		ToPhase:   progress.ToPhase,
		DayNumber: progress.DayNumber,
		Winner:    progress.Winner,
	}, nil
}
