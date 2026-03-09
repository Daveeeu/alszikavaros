package room

import (
	"errors"
	"strings"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/game"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/gorm"
)

const (
	maxLobbyPlayers = 6
	roomCodeLength  = 6
)

type Service struct {
	repo        *Repository
	gameStarter *game.StartService
	gameRepo    *game.Repository
}

func NewService(repo *Repository, gameStarter *game.StartService, gameRepo *game.Repository) *Service {
	return &Service{repo: repo, gameStarter: gameStarter, gameRepo: gameRepo}
}

func (s *Service) CreateRoom(playerName string) (*RoomAuthResponse, error) {
	name := strings.TrimSpace(playerName)
	if name == "" {
		return nil, ErrInvalidPlayerName
	}

	sessionToken, err := generateSessionToken()
	if err != nil {
		return nil, ErrTokenGeneration
	}

	var createdRoom *Room
	var createdPlayerID string
	err = s.repo.Transaction(func(tx *gorm.DB) error {
		roomCode, err := s.generateUniqueRoomCode(tx)
		if err != nil {
			return err
		}

		room := &Room{
			ID:     generateID("room"),
			Code:   roomCode,
			Status: shared.RoomStatusLobby,
		}
		if err := s.repo.CreateRoom(tx, room); err != nil {
			return err
		}

		hostPlayer := &player.Player{
			ID:           generateID("player"),
			RoomID:       room.ID,
			Name:         name,
			IsHost:       true,
			IsAlive:      true,
			IsConnected:  true,
			SessionToken: &sessionToken,
		}
		if err := s.repo.CreatePlayer(tx, hostPlayer); err != nil {
			return err
		}

		room.HostPlayerID = &hostPlayer.ID
		if err := s.repo.UpdateRoom(tx, room); err != nil {
			return err
		}
		createdRoom = room
		createdPlayerID = hostPlayer.ID
		return nil
	})
	if err != nil {
		return nil, err
	}

	state, err := s.buildRoomState(createdRoom)
	if err != nil {
		return nil, err
	}

	return &RoomAuthResponse{
		Room:         *state,
		PlayerID:     createdPlayerID,
		SessionToken: sessionToken,
	}, nil
}

func (s *Service) JoinRoom(playerName, roomCode string) (*RoomAuthResponse, error) {
	name := strings.TrimSpace(playerName)
	code := strings.ToUpper(strings.TrimSpace(roomCode))
	if name == "" {
		return nil, ErrInvalidPlayerName
	}
	if len(code) < 4 {
		return nil, ErrInvalidRoomCode
	}

	sessionToken, err := generateSessionToken()
	if err != nil {
		return nil, ErrTokenGeneration
	}

	var joinedRoom *Room
	var joinedPlayerID string
	err = s.repo.Transaction(func(tx *gorm.DB) error {
		room, err := s.repo.FindRoomByCodeForUpdate(tx, code)
		if err != nil {
			return err
		}
		if room.Status != shared.RoomStatusLobby {
			return ErrRoomNotJoinable
		}

		count, err := s.repo.ConnectedPlayerCount(tx, room.ID)
		if err != nil {
			return err
		}
		if count >= maxLobbyPlayers {
			return ErrRoomFull
		}

		newPlayer := &player.Player{
			ID:           generateID("player"),
			RoomID:       room.ID,
			Name:         name,
			IsHost:       false,
			IsAlive:      true,
			IsConnected:  true,
			SessionToken: &sessionToken,
		}
		if err := s.repo.CreatePlayer(tx, newPlayer); err != nil {
			return err
		}
		joinedRoom = room
		joinedPlayerID = newPlayer.ID
		return nil
	})
	if err != nil {
		return nil, err
	}

	state, err := s.buildRoomState(joinedRoom)
	if err != nil {
		return nil, err
	}

	return &RoomAuthResponse{
		Room:         *state,
		PlayerID:     joinedPlayerID,
		SessionToken: sessionToken,
	}, nil
}

func (s *Service) GetRoomState(roomCode string) (*RoomStateDTO, error) {
	code := strings.ToUpper(strings.TrimSpace(roomCode))
	if len(code) < 4 {
		return nil, ErrInvalidRoomCode
	}

	room, err := s.repo.FindRoomByCode(code)
	if err != nil {
		return nil, err
	}

	return s.buildRoomState(room)
}

func (s *Service) LeaveRoom(roomCode, requesterPlayerID string) (*RoomStateDTO, error) {
	code := strings.ToUpper(strings.TrimSpace(roomCode))
	if len(code) < 4 {
		return nil, ErrInvalidRoomCode
	}
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}

	var affectedRoom *Room
	err := s.repo.Transaction(func(tx *gorm.DB) error {
		room, err := s.repo.FindRoomByCodeForUpdate(tx, code)
		if err != nil {
			return err
		}

		requestPlayer, err := s.repo.FindPlayerByIDForUpdate(tx, requesterPlayerID)
		if err != nil {
			return err
		}
		if requestPlayer.RoomID != room.ID {
			return ErrPlayerNotInRoom
		}
		wasHost := requestPlayer.IsHost

		if requestPlayer.IsConnected {
			requestPlayer.IsConnected = false
			if wasHost {
				requestPlayer.IsHost = false
			}
			if err := s.repo.UpdatePlayer(tx, requestPlayer); err != nil {
				return err
			}
		}

		if wasHost {
			players, err := s.repo.ListPlayersByRoomIDForUpdate(tx, room.ID)
			if err != nil {
				return err
			}

			var nextHost *player.Player
			for i := range players {
				candidate := &players[i]
				if candidate.ID == requestPlayer.ID {
					continue
				}
				if candidate.IsConnected {
					nextHost = candidate
					break
				}
			}

			if nextHost != nil {
				nextHost.IsHost = true
				if err := s.repo.UpdatePlayer(tx, nextHost); err != nil {
					return err
				}
				room.HostPlayerID = &nextHost.ID
			} else {
				room.HostPlayerID = nil
			}
		}

		if err := s.repo.UpdateRoom(tx, room); err != nil {
			return err
		}
		affectedRoom = room
		return nil
	})
	if err != nil {
		return nil, err
	}

	return s.buildRoomState(affectedRoom)
}

func (s *Service) StartGame(roomCode, requesterPlayerID string) (*game.StartGameResponse, error) {
	code := strings.ToUpper(strings.TrimSpace(roomCode))
	if len(code) < 4 {
		return nil, ErrInvalidRoomCode
	}
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}

	var response *game.StartGameResponse
	err := s.repo.Transaction(func(tx *gorm.DB) error {
		room, err := s.repo.FindRoomByCodeForUpdate(tx, code)
		if err != nil {
			return err
		}
		if room.Status != shared.RoomStatusLobby {
			return ErrRoomNotInLobby
		}

		requestPlayer, err := s.repo.FindPlayerByIDForUpdate(tx, requesterPlayerID)
		if err != nil {
			return err
		}
		if requestPlayer.RoomID != room.ID {
			return ErrPlayerNotInRoom
		}
		if !requestPlayer.IsHost {
			return ErrOnlyHostCanStart
		}

		connectedPlayers, err := s.repo.ListConnectedPlayersByRoomIDForUpdate(tx, room.ID)
		if err != nil {
			return err
		}
		if len(connectedPlayers) < 6 {
			return ErrMinimumPlayers
		}

		playerIDs := make([]string, 0, len(connectedPlayers))
		for _, p := range connectedPlayers {
			playerIDs = append(playerIDs, p.ID)
		}

		createdGame, err := s.gameStarter.StartInTx(tx, game.StartGameInput{
			RoomID:               room.ID,
			ParticipantPlayerIDs: playerIDs,
		})
		if err != nil {
			return err
		}

		if err := s.repo.MarkAllPlayersAlive(tx, room.ID); err != nil {
			return err
		}

		room.Status = shared.RoomStatusInGame
		room.CurrentGameID = &createdGame.ID
		if err := s.repo.UpdateRoom(tx, room); err != nil {
			return err
		}

		response = &game.StartGameResponse{
			GameID: createdGame.ID,
			Phase:  createdGame.Phase,
		}
		return nil
	})
	if err != nil {
		return nil, err
	}

	return response, nil
}

func (s *Service) RestartRoom(roomCode, requesterPlayerID string) (*RestartRoomResponse, error) {
	code := strings.ToUpper(strings.TrimSpace(roomCode))
	if len(code) < 4 {
		return nil, ErrInvalidRoomCode
	}
	if strings.TrimSpace(requesterPlayerID) == "" {
		return nil, ErrUnauthorized
	}

	var response *RestartRoomResponse
	var updatedRoom *Room
	err := s.repo.Transaction(func(tx *gorm.DB) error {
		room, err := s.repo.FindRoomByCodeForUpdate(tx, code)
		if err != nil {
			return err
		}
		if room.CurrentGameID == nil || *room.CurrentGameID == "" {
			return ErrNoActiveGame
		}

		requestPlayer, err := s.repo.FindPlayerByIDForUpdate(tx, requesterPlayerID)
		if err != nil {
			return err
		}
		if requestPlayer.RoomID != room.ID {
			return ErrPlayerNotInRoom
		}
		if !requestPlayer.IsHost {
			return ErrOnlyHostCanStart
		}

		currentGame, err := s.gameRepo.FindByIDForUpdate(tx, *room.CurrentGameID)
		if err != nil {
			if errors.Is(err, game.ErrGameNotFound) {
				return ErrNoActiveGame
			}
			return err
		}
		if currentGame.Phase != shared.GamePhaseEnded {
			return ErrGameNotEnded
		}

		connectedPlayers, err := s.repo.ListConnectedPlayersByRoomIDForUpdate(tx, room.ID)
		if err != nil {
			return err
		}
		if len(connectedPlayers) < 6 {
			return ErrMinimumPlayers
		}

		playerIDs := make([]string, 0, len(connectedPlayers))
		for _, p := range connectedPlayers {
			playerIDs = append(playerIDs, p.ID)
		}

		createdGame, err := s.gameStarter.StartInTx(tx, game.StartGameInput{
			RoomID:               room.ID,
			ParticipantPlayerIDs: playerIDs,
		})
		if err != nil {
			return err
		}

		if err := s.repo.MarkAllPlayersAlive(tx, room.ID); err != nil {
			return err
		}

		room.Status = shared.RoomStatusInGame
		room.CurrentGameID = &createdGame.ID
		if err := s.repo.UpdateRoom(tx, room); err != nil {
			return err
		}
		updatedRoom = room

		response = &RestartRoomResponse{
			GameID: createdGame.ID,
			Phase:  createdGame.Phase,
		}
		return nil
	})
	if err != nil {
		return nil, err
	}

	state, err := s.buildRoomState(updatedRoom)
	if err != nil {
		return nil, err
	}
	response.Room = *state
	return response, nil
}

func (s *Service) generateUniqueRoomCode(tx *gorm.DB) (string, error) {
	for i := 0; i < 10; i++ {
		code, err := randomRoomCode(roomCodeLength)
		if err != nil {
			return "", err
		}
		exists, err := s.repo.RoomCodeExists(tx, code)
		if err != nil {
			return "", err
		}
		if !exists {
			return code, nil
		}
	}
	return "", ErrRoomCodeGeneration
}

func (s *Service) buildRoomState(room *Room) (*RoomStateDTO, error) {
	players, err := s.repo.ListPlayersByRoomID(room.ID)
	if err != nil {
		return nil, err
	}
	return mapRoomStateDTO(room, players), nil
}
