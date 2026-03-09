package room

import "github.com/Daveeeu/alszikavaros/backend/internal/modules/player"

func mapRoomStateDTO(room *Room, players []player.Player) *RoomStateDTO {
	dtoPlayers := make([]PlayerDTO, 0, len(players))
	var host *PlayerDTO
	for _, p := range players {
		item := mapPlayerDTO(p)
		if item.IsHost {
			copyItem := item
			host = &copyItem
		}
		dtoPlayers = append(dtoPlayers, item)
	}

	hostID := ""
	if room.HostPlayerID != nil {
		hostID = *room.HostPlayerID
	}

	return &RoomStateDTO{
		ID:            room.ID,
		Code:          room.Code,
		Status:        string(room.Status),
		HostPlayerID:  hostID,
		CurrentGameID: room.CurrentGameID,
		CreatedAt:     room.CreatedAt,
		UpdatedAt:     room.UpdatedAt,
		Players:       dtoPlayers,
		Host:          host,
	}
}

func mapPlayerDTO(p player.Player) PlayerDTO {
	return PlayerDTO{
		ID:          p.ID,
		Name:        p.Name,
		IsHost:      p.IsHost,
		IsAlive:     p.IsAlive,
		IsConnected: p.IsConnected,
		JoinedAt:    p.JoinedAt,
	}
}
