package game

import "errors"

var (
	ErrGameNotFound           = errors.New("game not found")
	ErrUnauthorized           = errors.New("unauthorized")
	ErrPlayerNotInGame        = errors.New("player is not part of this game")
	ErrInvalidPhaseTransition = errors.New("invalid phase transition")
	ErrHostRequired           = errors.New("host access required")
)
