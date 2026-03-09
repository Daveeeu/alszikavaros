package game

import (
	"errors"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

func mapServiceError(err error) *shared.APIError {
	switch {
	case err == nil:
		return nil
	case errors.Is(err, ErrUnauthorized):
		return shared.Unauthorized(err.Error())
	case errors.Is(err, ErrPlayerNotInGame), errors.Is(err, ErrHostRequired):
		return shared.Forbidden(err.Error())
	case errors.Is(err, ErrGameNotFound):
		return shared.NotFound(err.Error())
	case errors.Is(err, ErrInvalidPhaseTransition):
		return shared.InvalidPhase(err.Error())
	default:
		return shared.Internal("internal server error")
	}
}
