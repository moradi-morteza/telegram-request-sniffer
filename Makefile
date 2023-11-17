.PHONY: build run clean test deps install dev

# Build the application
build:
	@echo "Building telegram-request-sniffer..."
	go build -o bin/telegram-sniffer.exe cmd/server/main.go

# Run the application
run: build
	@echo "Starting telegram-request-sniffer..."
	.\bin\telegram-sniffer.exe

# Development mode (with hot reload if you add air)
dev:
	@echo "Starting in development mode..."
	go run cmd/server/main.go

# Install dependencies
deps:
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy

# Install the application
install: build
	@echo "Installing telegram-request-sniffer..."
	go install cmd/server/main.go

# Run tests
test:
	@echo "Running tests..."
	go test -v ./...

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	go clean

# Format code
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Lint code (requires golangci-lint)
lint:
	@echo "Linting code..."
	golangci-lint run

# Run with race detector
race:
	@echo "Running with race detector..."
	go run -race cmd/server/main.go

# Show helpi m
help:
	@echo "Available targets:"
	@echo "  build    - Build the application"
	@echo "  run      - Build and run the application"
	@echo "  dev      - Run in development mode"
	@echo "  deps     - Download and tidy dependencies"
	@echo "  install  - Install the application"
	@echo "  test     - Run tests"
	@echo "  clean    - Clean build artifacts"
	@echo "  fmt      - Format code"
	@echo "  lint     - Lint code"
	@echo "  race     - Run with race detector"
	@echo "  help     - Show this help message"
