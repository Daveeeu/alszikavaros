package database

import (
	"fmt"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/action"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/game"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/room"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/vote"
	"gorm.io/gorm"
)

func RunMigrations(db *gorm.DB) error {
	if err := db.AutoMigrate(
		&room.Room{},
		&player.Player{},
		&game.Game{},
		&game.PlayerRole{},
		&game.PhaseLog{},
		&action.NightAction{},
		&vote.Vote{},
	); err != nil {
		return err
	}

	if err := createIndexes(db); err != nil {
		return err
	}

	return createForeignKeys(db)
}

func createIndexes(db *gorm.DB) error {
	stmts := []string{
		"CREATE UNIQUE INDEX IF NOT EXISTS idx_rooms_code_unique ON rooms(code)",
		"CREATE INDEX IF NOT EXISTS idx_rooms_status ON rooms(status)",
		"CREATE INDEX IF NOT EXISTS idx_rooms_host_player_id ON rooms(host_player_id)",
		"CREATE INDEX IF NOT EXISTS idx_rooms_current_game_id ON rooms(current_game_id)",

		"CREATE INDEX IF NOT EXISTS idx_players_room_id ON players(room_id)",
		"CREATE UNIQUE INDEX IF NOT EXISTS idx_players_session_token_unique ON players(session_token)",
		"CREATE INDEX IF NOT EXISTS idx_players_room_alive ON players(room_id, is_alive)",

		"CREATE INDEX IF NOT EXISTS idx_games_room_id ON games(room_id)",
		"CREATE INDEX IF NOT EXISTS idx_games_phase ON games(phase)",

		"CREATE INDEX IF NOT EXISTS idx_player_roles_game_id ON player_roles(game_id)",
		"CREATE UNIQUE INDEX IF NOT EXISTS idx_player_roles_game_player_unique ON player_roles(game_id, player_id)",

		"CREATE INDEX IF NOT EXISTS idx_night_actions_game_round ON night_actions(game_id, round_number)",
		"CREATE UNIQUE INDEX IF NOT EXISTS idx_night_actions_unique_submission ON night_actions(game_id, player_id, round_number)",

		"CREATE INDEX IF NOT EXISTS idx_votes_game_day ON votes(game_id, day_number)",
		"CREATE UNIQUE INDEX IF NOT EXISTS idx_votes_unique_submission ON votes(game_id, day_number, voter_player_id)",
	}

	for _, stmt := range stmts {
		if err := db.Exec(stmt).Error; err != nil {
			return err
		}
	}
	return nil
}

func createForeignKeys(db *gorm.DB) error {
	constraints := []struct {
		name string
		sql  string
	}{
		{
			name: "fk_players_room_id",
			sql:  "ALTER TABLE players ADD CONSTRAINT fk_players_room_id FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_games_room_id",
			sql:  "ALTER TABLE games ADD CONSTRAINT fk_games_room_id FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_rooms_current_game_id",
			sql:  "ALTER TABLE rooms ADD CONSTRAINT fk_rooms_current_game_id FOREIGN KEY (current_game_id) REFERENCES games(id) ON UPDATE CASCADE ON DELETE SET NULL",
		},
		{
			name: "fk_rooms_host_player_id",
			sql:  "ALTER TABLE rooms ADD CONSTRAINT fk_rooms_host_player_id FOREIGN KEY (host_player_id) REFERENCES players(id) ON UPDATE CASCADE ON DELETE RESTRICT",
		},
		{
			name: "fk_player_roles_game_id",
			sql:  "ALTER TABLE player_roles ADD CONSTRAINT fk_player_roles_game_id FOREIGN KEY (game_id) REFERENCES games(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_player_roles_player_id",
			sql:  "ALTER TABLE player_roles ADD CONSTRAINT fk_player_roles_player_id FOREIGN KEY (player_id) REFERENCES players(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_night_actions_game_id",
			sql:  "ALTER TABLE night_actions ADD CONSTRAINT fk_night_actions_game_id FOREIGN KEY (game_id) REFERENCES games(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_night_actions_player_id",
			sql:  "ALTER TABLE night_actions ADD CONSTRAINT fk_night_actions_player_id FOREIGN KEY (player_id) REFERENCES players(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_night_actions_target_player_id",
			sql:  "ALTER TABLE night_actions ADD CONSTRAINT fk_night_actions_target_player_id FOREIGN KEY (target_player_id) REFERENCES players(id) ON UPDATE CASCADE ON DELETE RESTRICT",
		},
		{
			name: "fk_votes_game_id",
			sql:  "ALTER TABLE votes ADD CONSTRAINT fk_votes_game_id FOREIGN KEY (game_id) REFERENCES games(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_votes_voter_player_id",
			sql:  "ALTER TABLE votes ADD CONSTRAINT fk_votes_voter_player_id FOREIGN KEY (voter_player_id) REFERENCES players(id) ON UPDATE CASCADE ON DELETE CASCADE",
		},
		{
			name: "fk_votes_target_player_id",
			sql:  "ALTER TABLE votes ADD CONSTRAINT fk_votes_target_player_id FOREIGN KEY (target_player_id) REFERENCES players(id) ON UPDATE CASCADE ON DELETE RESTRICT",
		},
	}

	for _, c := range constraints {
		if err := ensureConstraint(db, c.name, c.sql); err != nil {
			return fmt.Errorf("constraint %s: %w", c.name, err)
		}
	}
	return nil
}

func ensureConstraint(db *gorm.DB, constraintName, alterSQL string) error {
	// Idempotent FK setup for PostgreSQL.
	stmt := fmt.Sprintf(`
DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM pg_constraint
		WHERE conname = '%s'
	) THEN
		%s;
	END IF;
END $$;
`, constraintName, alterSQL)
	return db.Exec(stmt).Error
}

func AutoMigrate(db *gorm.DB) error {
	return RunMigrations(db)
}
