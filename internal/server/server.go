package server

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"github.com/moradi-morteza/telegram-request-sniffer/internal/config"
	"github.com/moradi-morteza/telegram-request-sniffer/internal/handlers"
	"github.com/rs/cors"
)

// Server represents the application server
type Server struct {
	config     *config.Config
	httpServer *http.Server
	hub        *handlers.Hub
}

// New creates a new Server instance
func New(cfg *config.Config) *Server {
	return &Server{
		config: cfg,
		hub:    handlers.NewHub(),
	}
}

// Start starts the server
func (s *Server) Start() error {
	// Start the WebSocket hub
	go s.hub.Run()

	// Setup router
	router := s.setupRouter()

	// Configure CORS
	c := cors.New(cors.Options{
		AllowedOrigins:   []string{s.config.CORSOrigin},
		AllowCredentials: true,
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"*"},
	})

	handler := c.Handler(router)

	// Create HTTP server
	s.httpServer = &http.Server{
		Addr:         fmt.Sprintf(":%d", s.config.Port),
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Channel to listen for errors
	serverErrors := make(chan error, 1)

	// Start the server in a goroutine
	go func() {
		log.Printf("Telegram Request Sniffer Server running on http://localhost:%d", s.config.Port)
		log.Printf("Environment: %s", s.config.Env)
		serverErrors <- s.httpServer.ListenAndServe()
	}()

	// Handle shutdown signals
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM, syscall.SIGINT)

	select {
	case err := <-serverErrors:
		return fmt.Errorf("server error: %w", err)

	case sig := <-shutdown:
		log.Printf("%v signal received: shutting down", sig)

		// Create a context with timeout for shutdown
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// Attempt graceful shutdown
		if err := s.httpServer.Shutdown(ctx); err != nil {
			log.Printf("Could not gracefully shutdown the server: %v", err)
			return s.httpServer.Close()
		}

		log.Println("Server stopped gracefully")
	}

	return nil
}

// setupRouter configures the HTTP router
func (s *Server) setupRouter() *mux.Router {
	router := mux.NewRouter()

	// Get the current working directory
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	publicDir := filepath.Join(cwd, "public")

	// Add logging middleware
	router.Use(handlers.LoggingMiddleware)

	// WebSocket endpoint (must be before other routes)
	router.HandleFunc("/ws", s.hub.HandleWebSocket)

	// Define specific routes
	router.HandleFunc("/", handlers.ServeIndex(publicDir)).Methods("GET")
	router.HandleFunc("/client", handlers.ServeClient(publicDir)).Methods("GET")

	// Serve static files from public directory (catch-all, must be last)
	staticHandler := http.FileServer(http.Dir(publicDir))
	router.PathPrefix("/").Handler(staticHandler).Methods("GET")

	return router
}
