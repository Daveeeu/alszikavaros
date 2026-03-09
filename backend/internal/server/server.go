package server

import (
	"net/http"
	"time"

	"github.com/Daveeeu/alszikavaros/backend/internal/config"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/ws"
	"gorm.io/gorm"
)

func New(cfg *config.Config, db *gorm.DB) *http.Server {
	wsHub := ws.NewHub()
	handler := newRouter(cfg, db, wsHub)

	return &http.Server{
		Addr:              ":" + cfg.AppPort,
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
}
