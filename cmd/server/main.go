package main

import (
	"flag"
	"log"
	"os"

	"github.com/moradi-morteza/telegram-request-sniffer/internal/config"
	"github.com/moradi-morteza/telegram-request-sniffer/internal/server"
)

func main() {
	// Parse command-line flags
	portFlag := flag.Int("port", 0, "Port to run the server on (overrides PORT env var)")
	help := flag.Bool("help", false, "Show help message")
	flag.Parse()

	if *help {
		flag.PrintDefaults()
		os.Exit(0)
	}

	// Load configuration
	cfg := config.Load()

	// Override port if command-line flag was provided
	if *portFlag != 0 {
		cfg.Port = *portFlag
	}

	// Create and start server
	srv := server.New(cfg)

	if err := srv.Start(); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
