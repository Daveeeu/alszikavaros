package game

import (
	"fmt"
	"strings"
	"testing"

	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type testVote struct {
	ID             string `gorm:"primaryKey;size:64"`
	GameID         string `gorm:"index;size:64;not null"`
	VoterPlayerID  string `gorm:"index;size:64;not null"`
	TargetPlayerID string `gorm:"index;size:64;not null"`
	DayNumber      int    `gorm:"not null"`
}

func (testVote) TableName() string { return "votes" }

func newVoteResolutionDB(t *testing.T) *gorm.DB {
	t.Helper()

	dbName := fmt.Sprintf("file:%s?mode=memory&cache=shared", strings.ReplaceAll(t.Name(), "/", "_"))
	db, err := gorm.Open(sqlite.Open(dbName), &gorm.Config{})
	if err != nil {
		t.Fatalf("failed to open sqlite db: %v", err)
	}
	if err := db.AutoMigrate(&testRoom{}, &testPlayer{}, &Game{}, &PlayerRole{}, &PhaseLog{}, &testVote{}); err != nil {
		t.Fatalf("failed to migrate sqlite db: %v", err)
	}
	return db
}

func seedVoteResolutionGame(t *testing.T, db *gorm.DB) string {
	t.Helper()

	roomID := "room-v1"
	gameID := "game-v1"
	if err := db.Create(&testRoom{ID: roomID, Code: "VGAME1", Status: shared.RoomStatusInGame}).Error; err != nil {
		t.Fatalf("failed to create room: %v", err)
	}

	players := []testPlayer{
		{ID: "k1", RoomID: roomID, Name: "K1", IsAlive: true, IsConnected: true},
		{ID: "v1", RoomID: roomID, Name: "V1", IsAlive: true, IsConnected: true},
		{ID: "v2", RoomID: roomID, Name: "V2", IsAlive: true, IsConnected: true},
	}
	for _, p := range players {
		row := p
		if err := db.Create(&row).Error; err != nil {
			t.Fatalf("failed to create player %s: %v", p.ID, err)
		}
	}

	roles := []PlayerRole{
		{ID: "r1", GameID: gameID, PlayerID: "k1", Role: shared.RoleKiller},
		{ID: "r2", GameID: gameID, PlayerID: "v1", Role: shared.RoleVillager},
		{ID: "r3", GameID: gameID, PlayerID: "v2", Role: shared.RoleVillager},
	}
	for _, r := range roles {
		row := r
		if err := db.Create(&row).Error; err != nil {
			t.Fatalf("failed to create role %s: %v", r.ID, err)
		}
	}

	if err := db.Create(&Game{
		ID:        gameID,
		RoomID:    roomID,
		Phase:     shared.GamePhaseVoting,
		DayNumber: 1,
		Winner:    shared.WinnerTypeNone,
	}).Error; err != nil {
		t.Fatalf("failed to create game: %v", err)
	}

	return gameID
}

func TestVoteResolutionService_ResolveVotes_EliminationCanEndGame(t *testing.T) {
	db := newVoteResolutionDB(t)
	gameID := seedVoteResolutionGame(t, db)

	votes := []testVote{
		{ID: "v1", GameID: gameID, VoterPlayerID: "k1", TargetPlayerID: "v1", DayNumber: 1},
		{ID: "v2", GameID: gameID, VoterPlayerID: "v1", TargetPlayerID: "k1", DayNumber: 1},
		{ID: "v3", GameID: gameID, VoterPlayerID: "v2", TargetPlayerID: "v1", DayNumber: 1},
	}
	for _, v := range votes {
		row := v
		if err := db.Create(&row).Error; err != nil {
			t.Fatalf("failed to create vote %s: %v", v.ID, err)
		}
	}

	svc := NewVoteResolutionService(NewRepository(db))
	outcome, err := svc.ResolveVotes(gameID)
	if err != nil {
		t.Fatalf("resolve votes failed: %v", err)
	}
	if outcome == nil || outcome.Result == nil {
		t.Fatal("expected non-nil vote outcome")
	}
	if outcome.Result.Tie {
		t.Fatal("expected no tie in this setup")
	}
	if outcome.Result.EliminatedPlayerID == nil || *outcome.Result.EliminatedPlayerID != "v1" {
		t.Fatalf("expected v1 eliminated, got %#v", outcome.Result.EliminatedPlayerID)
	}
	if outcome.Winner != shared.WinnerTypeKillers {
		t.Fatalf("expected killers winner after elimination, got %s", outcome.Winner)
	}
}
