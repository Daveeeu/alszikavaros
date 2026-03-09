package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
)

type Config struct {
	AppEnv             string
	AppPort            string
	DatabaseURL        string
	WSAllowedOrigins   []string
	CORSAllowedOrigins []string
	SessionSecret      string

	DBMaxOpenConns    int
	DBMaxIdleConns    int
	DBConnMaxLifetime int
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	cfg := &Config{
		AppEnv:             getenvFirst([]string{"APP_ENV", "ENV"}, "development"),
		AppPort:            getenvFirst([]string{"APP_PORT", "PORT"}, "8080"),
		DatabaseURL:        os.Getenv("DATABASE_URL"),
		WSAllowedOrigins:   getenvCSV([]string{"WS_ALLOWED_ORIGINS"}, "*"),
		CORSAllowedOrigins: getenvCSV([]string{"CORS_ALLOWED_ORIGINS", "ALLOWED_CORS"}, "*"),
		SessionSecret:      getenvFirst([]string{"JWT_SECRET", "SESSION_SECRET"}, ""),
		DBMaxOpenConns:     getenvInt("DB_MAX_OPEN_CONNS", 25),
		DBMaxIdleConns:     getenvInt("DB_MAX_IDLE_CONNS", 10),
		DBConnMaxLifetime:  getenvInt("DB_CONN_MAX_LIFETIME_MIN", 30),
	}

	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}

	return cfg, nil
}

func getenvFirst(keys []string, fallback string) string {
	for _, key := range keys {
		if v := strings.TrimSpace(os.Getenv(key)); v != "" {
			return v
		}
	}
	return fallback
}

func getenvCSV(keys []string, fallback string) []string {
	raw := getenvFirst(keys, fallback)
	parts := strings.Split(raw, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		v := strings.TrimSpace(p)
		if v != "" {
			out = append(out, v)
		}
	}
	if len(out) == 0 {
		return []string{"*"}
	}
	return out
}

func getenvInt(key string, fallback int) int {
	v := strings.TrimSpace(os.Getenv(key))
	if v == "" {
		return fallback
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return fallback
	}
	return n
}
