#!/bin/bash

# Telegram Request Sniffer - Run Script
# This script builds and runs the server

set -e

echo "Starting Telegram Request Sniffer..."

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed. Please install Go 1.21 or higher."
    exit 1
fi

# Download dependencies if needed
if [ ! -f "go.sum" ]; then
    echo "Downloading dependencies..."
    go mod download
    go mod tidy
fi

# Build and run
echo "Building and starting server..."
go run cmd/server/main.go
