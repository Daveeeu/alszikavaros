package action

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
	case errors.Is(err, ErrPlayerNotInGame), errors.Is(err, ErrRoleCannotAct):
		return shared.Forbidden(err.Error())
	case errors.Is(err, ErrGameNotFound):
		return shared.NotFound(err.Error())
	case errors.Is(err, ErrInvalidPhase):
		return shared.InvalidPhase(err.Error())
	case errors.Is(err, ErrDuplicateSubmission):
		return shared.Conflict(err.Error())
	case errors.Is(err, ErrPlayerDead), errors.Is(err, ErrInvalidTarget), errors.Is(err, ErrTargetNotAlive), errors.Is(err, ErrSelfTargetNotAllowed):
		return shared.InvalidAction(err.Error())
	default:
		return shared.Internal("internal server error")
	}
}
