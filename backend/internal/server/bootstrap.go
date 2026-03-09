package server

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/config"
	"github.com/Daveeeu/alszikavaros/backend/internal/database"
	"gorm.io/gorm"
)

type App struct {
	Server *http.Server
	DB     *gorm.DB
}

func Bootstrap(cfg *config.Config) (*App, error) {
	db, err := database.New(cfg.DatabaseURL, database.Options{
		MaxOpenConns:    cfg.DBMaxOpenConns,
		MaxIdleConns:    cfg.DBMaxIdleConns,
		ConnMaxLifetime: time.Duration(cfg.DBConnMaxLifetime) * time.Minute,
	})
	if err != nil {
		return nil, fmt.Errorf("connect database: %w", err)
	}

	if err := database.RunMigrations(db); err != nil {
		return nil, fmt.Errorf("run migrations: %w", err)
	}

	srv := New(cfg, db)
	return &App{Server: srv, DB: db}, nil
}

func Run(cfg *config.Config) error {
	app, err := Bootstrap(cfg)
	if err != nil {
		return err
	}

	go func() {
		log.Printf("API listening on :%s (%s)", cfg.AppPort, cfg.AppEnv)
		if err := app.Server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Printf("server error: %v", err)
		}
	}()

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	<-ctx.Done()

	log.Println("shutdown signal received")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := app.Server.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("http shutdown: %w", err)
	}

	sqlDB, err := app.DB.DB()
	if err == nil {
		if closeErr := sqlDB.Close(); closeErr != nil {
			log.Printf("database close failed: %v", closeErr)
		}
	}

	return nil
}
