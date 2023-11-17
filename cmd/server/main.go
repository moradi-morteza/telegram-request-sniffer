package main

import (
	"log"

	"github.com/moradi-morteza/telegram-request-sniffer/internal/config"
	"github.com/moradi-morteza/telegram-request-sniffer/internal/server"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Create and start server
	srv := server.New(cfg)

	if err := srv.Start(); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
