package game

import (
	"errors"
	"fmt"
	"strings"
	"testing"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func newPhaseTransitionTestDB(t *testing.T) *gorm.DB {
	t.Helper()

	dbName := fmt.Sprintf("file:%s?mode=memory&cache=shared", strings.ReplaceAll(t.Name(), "/", "_"))
	db, err := gorm.Open(sqlite.Open(dbName), &gorm.Config{})
	if err != nil {
		t.Fatalf("failed to open sqlite db: %v", err)
	}
	if err := db.AutoMigrate(&testRoom{}, &testPlayer{}, &Game{}, &PhaseLog{}); err != nil {
		t.Fatalf("failed to migrate sqlite db: %v", err)
	}
	return db
}

func seedPhaseTransitionBase(t *testing.T, db *gorm.DB, phase shared.GamePhase) (gameID, hostID, nonHostID string) {
	t.Helper()

	hostID = "host-1"
	nonHostID = "player-2"
	roomID := "room-1"
	gameID = "game-1"

	if err := db.Create(&testRoom{
		ID:           roomID,
		Code:         "ROOM01",
		Status:       shared.RoomStatusInGame,
		HostPlayerID: &hostID,
	}).Error; err != nil {
		t.Fatalf("failed to seed room: %v", err)
	}
	if err := db.Create(&testPlayer{
		ID:          hostID,
		RoomID:      roomID,
		Name:        "Host",
		IsHost:      true,
		IsAlive:     true,
		IsConnected: true,
	}).Error; err != nil {
		t.Fatalf("failed to seed host player: %v", err)
	}
	if err := db.Create(&testPlayer{
		ID:          nonHostID,
		RoomID:      roomID,
		Name:        "Guest",
		IsHost:      false,
		IsAlive:     true,
		IsConnected: true,
	}).Error; err != nil {
		t.Fatalf("failed to seed non-host player: %v", err)
	}
	if err := db.Create(&Game{
		ID:        gameID,
		RoomID:    roomID,
		Phase:     phase,
		DayNumber: 1,
		Winner:    shared.WinnerTypeNone,
	}).Error; err != nil {
		t.Fatalf("failed to seed game: %v", err)
	}

	return gameID, hostID, nonHostID
}

func TestPhaseTransitionService_StartDiscussion_HostOnly(t *testing.T) {
	db := newPhaseTransitionTestDB(t)
	gameID, hostID, nonHostID := seedPhaseTransitionBase(t, db, shared.GamePhaseDayReveal)
	svc := NewPhaseTransitionService(NewRepository(db))

	if _, err := svc.StartDiscussion(gameID, nonHostID); !errors.Is(err, ErrHostRequired) {
		t.Fatalf("expected ErrHostRequired for non-host, got %v", err)
	}

	result, err := svc.StartDiscussion(gameID, hostID)
	if err != nil {
		t.Fatalf("host StartDiscussion failed: %v", err)
	}
	if result == nil || result.ToPhase != shared.GamePhaseDiscussion {
		t.Fatalf("expected transition to discussion, got %#v", result)
	}
}

func TestPhaseTransitionService_StartVoting_RequiresDiscussionPhase(t *testing.T) {
	db := newPhaseTransitionTestDB(t)
	gameID, hostID, _ := seedPhaseTransitionBase(t, db, shared.GamePhaseDayReveal)
	svc := NewPhaseTransitionService(NewRepository(db))

	if _, err := svc.StartVoting(gameID, hostID); !errors.Is(err, ErrInvalidPhaseTransition) {
		t.Fatalf("expected ErrInvalidPhaseTransition, got %v", err)
	}

	if _, err := svc.StartDiscussion(gameID, hostID); err != nil {
		t.Fatalf("StartDiscussion failed: %v", err)
	}
	voteRes, err := svc.StartVoting(gameID, hostID)
	if err != nil {
		t.Fatalf("StartVoting failed: %v", err)
	}
	if voteRes == nil || voteRes.ToPhase != shared.GamePhaseVoting {
		t.Fatalf("expected voting phase, got %#v", voteRes)
	}
}
