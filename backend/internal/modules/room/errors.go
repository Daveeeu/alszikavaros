package room

import "errors"

var (
	ErrInvalidPlayerName  = errors.New("invalid player name")
	ErrInvalidRoomCode    = errors.New("invalid room code")
	ErrRoomNotFound       = errors.New("room not found")
	ErrRoomNotJoinable    = errors.New("room is not joinable")
	ErrRoomNotInLobby     = errors.New("room is not in lobby state")
	ErrRoomFull           = errors.New("room is full")
	ErrOnlyHostCanStart   = errors.New("only host can start the game")
	ErrMinimumPlayers     = errors.New("minimum 6 connected players required")
	ErrUnauthorized       = errors.New("unauthorized")
	ErrPlayerNotInRoom    = errors.New("player not in room")
	ErrTokenGeneration    = errors.New("failed to generate session token")
	ErrRoomCodeGeneration = errors.New("failed to generate unique room code")
	ErrNoActiveGame       = errors.New("room has no active game")
	ErrGameNotEnded       = errors.New("restart allowed only after game ended")
)
