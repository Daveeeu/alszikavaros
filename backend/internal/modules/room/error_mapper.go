package room

import (
	"errors"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
)

func mapServiceError(err error) *shared.APIError {
	switch {
	case err == nil:
		return nil
	case errors.Is(err, ErrInvalidPlayerName), errors.Is(err, ErrInvalidRoomCode):
		return shared.InvalidRequest(err.Error(), nil)
	case errors.Is(err, ErrUnauthorized):
		return shared.Unauthorized(err.Error())
	case errors.Is(err, ErrPlayerNotInRoom), errors.Is(err, ErrOnlyHostCanStart):
		return shared.Forbidden(err.Error())
	case errors.Is(err, ErrRoomNotFound):
		return shared.NotFound(err.Error())
	case errors.Is(err, ErrRoomNotJoinable), errors.Is(err, ErrRoomFull), errors.Is(err, ErrRoomNotInLobby), errors.Is(err, ErrMinimumPlayers), errors.Is(err, ErrNoActiveGame), errors.Is(err, ErrGameNotEnded):
		return shared.Conflict(err.Error())
	default:
		return shared.Internal("internal server error")
	}
}
