package room

import (
	"testing"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func TestLeaveRoom_TransfersHostToNextConnectedPlayer(t *testing.T) {
	db, err := gorm.Open(sqlite.Open("file:room_leave_test?mode=memory&cache=shared"), &gorm.Config{})
	if err != nil {
		t.Fatalf("failed to open sqlite db: %v", err)
	}
	if err := db.AutoMigrate(&Room{}, &player.Player{}); err != nil {
		t.Fatalf("failed to migrate sqlite db: %v", err)
	}

	hostID := "player-host"
	nextHostID := "player-next"
	roomID := "room-1"
	roomCode := "ABCD12"

	roomRow := &Room{
		ID:           roomID,
		Code:         roomCode,
		Status:       shared.RoomStatusLobby,
		HostPlayerID: &hostID,
	}
	if err := db.Create(roomRow).Error; err != nil {
		t.Fatalf("failed to create room: %v", err)
	}
	if err := db.Create(&player.Player{
		ID:          hostID,
		RoomID:      roomID,
		Name:        "Host",
		IsHost:      true,
		IsAlive:     true,
		IsConnected: true,
	}).Error; err != nil {
		t.Fatalf("failed to create host player: %v", err)
	}
	if err := db.Create(&player.Player{
		ID:          nextHostID,
		RoomID:      roomID,
		Name:        "Next",
		IsHost:      false,
		IsAlive:     true,
		IsConnected: true,
	}).Error; err != nil {
		t.Fatalf("failed to create next player: %v", err)
	}

	svc := NewService(NewRepository(db), nil, nil)
	state, err := svc.LeaveRoom(roomCode, hostID)
	if err != nil {
		t.Fatalf("leave room failed: %v", err)
	}
	if state.HostPlayerID != nextHostID {
		t.Fatalf("expected host to transfer to %s, got %s", nextHostID, state.HostPlayerID)
	}

	var oldHost player.Player
	if err := db.First(&oldHost, "id = ?", hostID).Error; err != nil {
		t.Fatalf("failed to load old host: %v", err)
	}
	if oldHost.IsConnected {
		t.Fatal("expected old host to be disconnected")
	}
	if oldHost.IsHost {
		t.Fatal("expected old host to lose host flag")
	}

	var newHost player.Player
	if err := db.First(&newHost, "id = ?", nextHostID).Error; err != nil {
		t.Fatalf("failed to load new host: %v", err)
	}
	if !newHost.IsHost {
		t.Fatal("expected next connected player to become host")
	}
}
