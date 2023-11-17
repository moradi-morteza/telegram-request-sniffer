@echo off
REM Telegram Request Sniffer - Run Script for Windows
REM This script builds and runs the server

echo Starting Telegram Request Sniffer...

REM Check if Go is installed
where go >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Go is not installed. Please install Go 1.21 or higher.
    echo Download from: https://golang.org/
    pause
    exit /b 1
)

REM Check if go.mod exists
if not exist "go.mod" (
    echo Error: go.mod not found. Are you in the correct directory?
    pause
    exit /b 1
)

REM Download dependencies if go.sum doesn't exist
if not exist "go.sum" (
    echo Downloading dependencies...
    go mod download
    go mod tidy
)

REM Build and run
echo Building and starting server...
go run cmd/server/main.go

pause
