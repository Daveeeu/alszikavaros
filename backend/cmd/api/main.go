package main

import (
	"log"

	"github.com/Daveeeu/alszikavaros/backend/internal/config"
	"github.com/Daveeeu/alszikavaros/backend/internal/server"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	if err := server.Run(cfg); err != nil {
		log.Fatalf("application stopped with error: %v", err)
	}
}
