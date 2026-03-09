package vote

import "errors"

var (
	ErrUnauthorized       = errors.New("unauthorized")
	ErrGameNotFound       = errors.New("game not found")
	ErrPlayerNotInGame    = errors.New("player is not part of this game")
	ErrInvalidPhase       = errors.New("current phase does not accept votes")
	ErrPlayerDead         = errors.New("dead players cannot vote")
	ErrDuplicateVote      = errors.New("vote already submitted for this day")
	ErrInvalidTarget      = errors.New("invalid target")
	ErrTargetNotAlive     = errors.New("target must be alive")
	ErrSelfVoteNotAllowed = errors.New("cannot vote for yourself")
)
