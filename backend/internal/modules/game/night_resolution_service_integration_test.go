package game

import (
	"fmt"
	"strings"
	"testing"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type testNightAction struct {
	ID             string      `gorm:"primaryKey;size:64"`
	GameID         string      `gorm:"index;size:64;not null"`
	PlayerID       string      `gorm:"index;size:64;not null"`
	Role           shared.Role `gorm:"type:varchar(20);not null"`
	TargetPlayerID string      `gorm:"index;size:64;not null"`
	RoundNumber    int         `gorm:"not null"`
}

func (testNightAction) TableName() string { return "night_actions" }

func newNightResolutionDB(t *testing.T) *gorm.DB {
	t.Helper()

	dbName := fmt.Sprintf("file:%s?mode=memory&cache=shared", strings.ReplaceAll(t.Name(), "/", "_"))
	db, err := gorm.Open(sqlite.Open(dbName), &gorm.Config{})
	if err != nil {
		t.Fatalf("failed to open sqlite db: %v", err)
	}
	if err := db.AutoMigrate(&testRoom{}, &testPlayer{}, &Game{}, &PhaseLog{}, &testNightAction{}); err != nil {
		t.Fatalf("failed to migrate sqlite db: %v", err)
	}
	return db
}

func seedNightResolutionGame(t *testing.T, db *gorm.DB, doctorTarget string) string {
	t.Helper()

	roomID := "room-n1"
	gameID := "game-n1"

	if err := db.Create(&testRoom{ID: roomID, Code: "NGAME1", Status: shared.RoomStatusInGame}).Error; err != nil {
		t.Fatalf("failed to create room: %v", err)
	}
	players := []testPlayer{
		{ID: "k1", RoomID: roomID, Name: "K1", IsAlive: true, IsConnected: true},
		{ID: "k2", RoomID: roomID, Name: "K2", IsAlive: true, IsConnected: true},
		{ID: "d1", RoomID: roomID, Name: "D1", IsAlive: true, IsConnected: true},
		{ID: "v1", RoomID: roomID, Name: "V1", IsAlive: true, IsConnected: true},
	}
	for _, p := range players {
		row := p
		if err := db.Create(&row).Error; err != nil {
			t.Fatalf("failed to create player %s: %v", p.ID, err)
		}
	}
	if err := db.Create(&Game{
		ID:        gameID,
		RoomID:    roomID,
		Phase:     shared.GamePhaseNightResolve,
		DayNumber: 1,
		Winner:    shared.WinnerTypeNone,
	}).Error; err != nil {
		t.Fatalf("failed to create game: %v", err)
	}

	actions := []testNightAction{
		{ID: "a1", GameID: gameID, PlayerID: "k1", Role: shared.RoleKiller, TargetPlayerID: "v1", RoundNumber: 1},
		{ID: "a2", GameID: gameID, PlayerID: "k2", Role: shared.RoleKiller, TargetPlayerID: "v1", RoundNumber: 1},
		{ID: "a3", GameID: gameID, PlayerID: "d1", Role: shared.RoleDoctor, TargetPlayerID: doctorTarget, RoundNumber: 1},
	}
	for _, a := range actions {
		row := a
		if err := db.Create(&row).Error; err != nil {
			t.Fatalf("failed to create action %s: %v", a.ID, err)
		}
	}

	return gameID
}

func TestNightResolutionService_ResolveNight_KillsWhenNotSaved(t *testing.T) {
	db := newNightResolutionDB(t)
	gameID := seedNightResolutionGame(t, db, "k1")
	svc := NewNightResolutionService(NewRepository(db), fixedTieBreaker{})

	result, err := svc.ResolveNight(gameID)
	if err != nil {
		t.Fatalf("resolve night failed: %v", err)
	}
	if result == nil || result.KilledPlayerID == nil || *result.KilledPlayerID != "v1" {
		t.Fatalf("expected v1 to die, got %#v", result)
	}
	if result.SavedByDoctor {
		t.Fatal("expected not saved by doctor")
	}
}

func TestNightResolutionService_ResolveNight_DoctorSavesTarget(t *testing.T) {
	db := newNightResolutionDB(t)
	gameID := seedNightResolutionGame(t, db, "v1")
	svc := NewNightResolutionService(NewRepository(db), fixedTieBreaker{})

	result, err := svc.ResolveNight(gameID)
	if err != nil {
		t.Fatalf("resolve night failed: %v", err)
	}
	if result == nil {
		t.Fatal("expected non-nil result")
	}
	if !result.SavedByDoctor {
		t.Fatal("expected doctor save")
	}
	if result.KilledPlayerID != nil {
		t.Fatalf("expected nobody killed, got %#v", result.KilledPlayerID)
	}
}
