package action

import "errors"

var (
	ErrUnauthorized         = errors.New("unauthorized")
	ErrGameNotFound         = errors.New("game not found")
	ErrPlayerNotInGame      = errors.New("player is not part of this game")
	ErrPlayerDead           = errors.New("dead players cannot act")
	ErrInvalidPhase         = errors.New("current phase does not accept night actions")
	ErrRoleCannotAct        = errors.New("player role cannot act in this phase")
	ErrDuplicateSubmission  = errors.New("night action already submitted")
	ErrInvalidTarget        = errors.New("invalid target")
	ErrTargetNotAlive       = errors.New("target must be alive")
	ErrSelfTargetNotAllowed = errors.New("self target is not allowed")
)
