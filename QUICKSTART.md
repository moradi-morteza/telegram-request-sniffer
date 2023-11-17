# Telegram Request Sniffer - Quick Start Guide

## Prerequisites

- **Go 1.21 or higher** - [Download](https://golang.org/dl/)
- **Git** (optional, for cloning)

## Installation

### Step 1: Clone or Download

```bash
git clone https://github.com/moradi-morteza/telegram-request-sniffer.git
cd telegram-request-sniffer
```

### Step 2: Download Dependencies

```bash
go mod download
go mod tidy
```

Or use Make:
```bash
make deps
```

## Running the Server

### Option 1: Quick Run (Development)

```bash
go run cmd/server/main.go
```

### Option 2: Using Make

```bash
make run
```

### Option 3: Windows Batch File

```cmd
run.bat
```

### Option 4: Linux/Mac Shell Script

```bash
chmod +x run.sh
./run.sh
```

### Option 5: Build Binary First

```bash
# Build
go build -o telegram-sniffer cmd/server/main.go

# Run
./telegram-sniffer
```

## Accessing the Dashboard

Once the server is running, open your browser to:

```
http://localhost:3000
```

## Configuration

Create a `.env` file (optional, defaults work fine):

```env
PORT=3000
NODE_ENV=development
CORS_ORIGIN=*
```

## Available Make Commands

```bash
make help        # Show all available commands
make deps        # Download dependencies
make build       # Build the binary
make run         # Build and run
make dev         # Run in development mode
make test        # Run tests
make clean       # Clean build artifacts
make fmt         # Format code
```

## Docker Deployment

### Using Docker Compose

```bash
docker-compose up -d
```

### Using Docker Directly

```bash
# Build
docker build -t telegram-sniffer .

# Run
docker run -p 3000:3000 telegram-sniffer
```

## Troubleshooting

### "go: command not found"
Install Go from https://golang.org/dl/

### "Port 3000 already in use"
Change the port in `.env`:
```env
PORT=3001
```

### Build errors
```bash
make clean
go mod tidy
make build
```

## Next Steps

1. **Configure Android Client**: See [README.md](README.md#android-integration)
2. **Read Full Documentation**: See [README.md](README.md)

## Quick Reference

| Command | Description |
|---------|-------------|
| `make run` | Build and run |
| `make dev` | Development mode |
| `make build` | Build binary |
| `make clean` | Clean artifacts |
| `make test` | Run tests |
| `docker-compose up` | Run with Docker |

## Support

- **Documentation**: [README.md](README.md)
- **Issues**: [GitHub Issues](https://github.com/moradi-morteza/telegram-request-sniffer/issues)

---

**Ready to monitor Telegram API traffic!** 🚀
