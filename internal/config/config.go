package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds the application configuration
type Config struct {
	Port       int
	Env        string
	CORSOrigin string
	WSHost     string
	LogLevel   string
}

// Load loads configuration from environment variables
func Load() *Config {
	// Load .env file if it exists
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	port, err := strconv.Atoi(getEnv("PORT", "3000"))
	if err != nil {
		port = 3000
	}

	return &Config{
		Port:       port,
		Env:        getEnv("NODE_ENV", "development"),
		CORSOrigin: getEnv("CORS_ORIGIN", "*"),
		WSHost:     getEnv("WS_HOST", "localhost"),
		LogLevel:   getEnv("LOG_LEVEL", "info"),
	}
}

// getEnv gets an environment variable with a default value
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
