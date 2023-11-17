# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-11-17

### Added
- High-performance WebSocket server using Gorilla WebSocket
- Concurrent message broadcasting with Go channels and goroutines
- Graceful shutdown with proper context handling
- Health checks in Docker configuration
- Makefile for easy build automation
- Cross-platform build scripts (run.bat for Windows, run.sh for Unix)
- Comprehensive architecture documentation
- Single binary deployment support

### Changed
- Improved server performance and reduced memory footprint
- Enhanced error handling and logging
- Better configuration management with type-safe config
- Updated Docker configuration with multi-stage builds
- Smaller Docker image size (~15MB)
- More efficient WebSocket connection management

### Performance
- Reduced memory usage from ~45MB to ~8MB baseline
- Faster startup time (~50ms vs ~500ms)
- Higher WebSocket throughput capability
- Better concurrent connection handling

## [1.0.0] - 2023-01-16

### Added
- Initial public release
- Real-time WebSocket-based monitoring of Telegram TLRPC traffic
- Web dashboard with Vue.js for visualizing API calls
- Request/Response correlation using tokens
- Interactive JSON viewer with collapsible trees
- Message filtering by type (REQUEST/RESPONSE/ERROR/SERVER)
- Export/Import functionality for saving and loading sessions
- Client ID filtering for multi-device support
- Android integration via TelegramRequestSniffer.java class
- Docker and Docker Compose support
- Environment variable configuration via .env files
- Comprehensive documentation (README, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT)
- MIT License
- Error handling and input validation
- Message size limits to prevent DoS attacks

### Security
- Added comprehensive security warnings and disclaimers
- Implemented message size validation (1MB limit)
- Added legal and ethical use guidelines
- Non-root Docker user for better container security
- Improved WebSocket connection state validation

### Documentation
- Complete README.md with clear research purpose
- Added SECURITY.md with legal disclaimers and best practices
- Added CONTRIBUTING.md for contributor guidelines
- Added CODE_OF_CONDUCT.md for community standards
- Added ARCHITECTURE.md for technical documentation

---

## Release Notes

### v2.0.0 - Performance and Architecture Improvements

Major update focusing on performance, reliability, and maintainability.

**Key Improvements:**
- Built with Go for better performance and lower resource usage
- Single binary deployment - no dependencies required
- Concurrent architecture with goroutines for better scalability
- Smaller Docker images and faster builds
- Improved error handling and logging

**Breaking Changes:**
- None - API remains fully compatible

**Getting Started:**
```bash
# Clone and setup
git clone https://github.com/moradi-morteza/telegram-request-sniffer.git
cd telegram-request-sniffer

# Install dependencies
go mod download

# Run
go run cmd/server/main.go
# or
make run
```

### v1.0.0 - Initial Open Source Release

First public release of Telegram Request Sniffer.

**What is Telegram Request Sniffer?**

A development and research tool for monitoring Telegram API (TLRPC) traffic in real-time. Designed for developers working with Telegram's open-source Android application who need to debug custom modifications and understand the internal API.

**Key Features:**
- Real-time visualization of Telegram API calls
- Request/Response correlation
- Export/Import for session analysis
- Docker support for easy deployment
- Comprehensive security and legal documentation

**Important Notes:**
- This tool is for **authorized research and development only**
- Requires modifying the Telegram Android source code (which is open source under GPLv3)
- Should only be used in isolated, controlled environments
- Users are responsible for compliance with all applicable laws

---

For older versions (pre-release), please see the git history.
