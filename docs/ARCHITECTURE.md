# Telegram Request Sniffer - Architecture Documentation

## Overview

Telegram Request Sniffer is a three-tier debugging tool designed to monitor and analyze Telegram Layer Protocol (TLRPC) traffic in real-time. This document provides detailed technical information about the system architecture, data flow, and implementation details.

## System Architecture

### High-Level Architecture

```
┌──────────────────────────────────────────────┐
│         Modified Telegram Android App        │
│  ┌────────────────────────────────────────┐  │
│  │      TelegramRequestSniffer.java              │  │
│  │  - Intercepts TLRPC objects            │  │
│  │  - Serializes to JSON via Reflection   │  │
│  │  - Sends via WebSocket                 │  │
│  └─────────────┬──────────────────────────┘  │
└────────────────┼─────────────────────────────┘
                 │
                 │ WebSocket (ws:// or wss://)
                 │ JSON Messages
                 ▼
┌──────────────────────────────────────────────┐
│       Go WebSocket Server                    │
│  ┌────────────────────────────────────────┐  │
│  │  Gorilla Mux HTTP Server               │  │
│  │  - Serves static files                 │  │
│  │  - Serves web dashboard                │  │
│  └────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────┐  │
│  │  WebSocket Hub (Gorilla WebSocket)     │  │
│  │  - Handles WS connections              │  │
│  │  - Broadcasts via Go channels          │  │
│  │  - Validates message size              │  │
│  └────────────────────────────────────────┘  │
└────────────────┼─────────────────────────────┘
                 │
                 │ WebSocket Broadcast
                 │ Real-time JSON streaming
                 ▼
┌──────────────────────────────────────────────┐
│        Web Dashboard (Vue.js SPA)            │
│  ┌────────────────────────────────────────┐  │
│  │  Vue.js Application (public/index.js)  │  │
│  │  - Receives messages via WebSocket     │  │
│  │  - Filters and displays data           │  │
│  │  - Provides search/export/import       │  │
│  └────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────┐  │
│  │  JSON Viewer (jsoneditor library)      │  │
│  │  - Interactive JSON tree view          │  │
│  │  - Syntax highlighting                 │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

---

## Component Details

### 1. Android Component (TelegramRequestSniffer.java)

**Location:** `android/TelegramRequestSniffer.java`

**Purpose:** Intercepts Telegram API calls within the modified Telegram Android application.

**Key Responsibilities:**
- Initialize WebSocket connection to the server
- Intercept TLRPC objects at key points in the Telegram codebase
- Serialize Java objects to JSON using reflection
- Send JSON messages to the WebSocket server
- Handle reconnection on connection loss

**Integration Points:**
```java
// ApplicationLoader.java
TelegramRequestSniffer.init(context);  // Initialize on app start

// MessagesController.java
TelegramRequestSniffer.logTLRPCObject(updates, "Server", 0);  // Log server pushes

// ConnectionsManager.java
TelegramRequestSniffer.logTLRPCObject(object, "Request", token);   // Log requests
TelegramRequestSniffer.logTLRPCObject(response, "Response", token); // Log responses
```

**Serialization Process:**

1. Check if object is a TLRPC class using HashMap lookup
2. Use Java Reflection to enumerate all fields
3. Recursively serialize nested TLRPC objects
4. Handle arrays (ArrayList) with element iteration
5. Add metadata (TYPE, TOKEN, TIME, UUID, CLIENTID)
6. Convert to JSON string and send via WebSocket

**Connection Management:**
- Auto-reconnect on connection loss
- Singleton pattern ensures one instance per app
- Configurable server URL and client ID

---

### 2. Backend Server (Go Application)

**Location:** `cmd/server/main.go` and `internal/` packages

**Purpose:** Acts as a relay and web server, broadcasting intercepted messages to all connected dashboard clients.

**Technology Stack:**
- **Gorilla Mux**: HTTP routing and middleware
- **Gorilla WebSocket**: WebSocket server implementation
- **godotenv**: Environment variable management
- **rs/cors**: Cross-Origin Resource Sharing

**Project Structure:**
```
cmd/server/main.go              # Application entry point
internal/
├── config/config.go            # Configuration management
├── handlers/
│   ├── http.go                # HTTP route handlers
│   └── websocket.go           # WebSocket hub & client handling
├── models/message.go          # Data structures
└── server/server.go           # Server initialization
```

**Server Components:**

#### HTTP Server (Gorilla Mux)
```go
Port: os.Getenv("PORT") || 3000
Routes:
  GET /               → index.html (main dashboard)
  GET /client         → client.html (test client)
  GET /ws             → WebSocket upgrade
  Static: /*          → Static files from /public
```

#### WebSocket Hub
```go
Protocol: WebSocket over HTTP (upgrade connection)
Max Message Size: 1MB (DoS protection)
Concurrency: Go channels for thread-safe broadcasting
Broadcast: All messages sent to all connected clients via goroutines
```

**Message Flow:**

1. Client connects via WebSocket upgrade
2. Hub registers client via `register` channel
3. Client spawns two goroutines:
   - **readPump**: Reads messages from WebSocket → broadcasts to hub
   - **writePump**: Receives from hub → writes to WebSocket
4. On message receipt:
   - Validate message size (< 1MB)
   - Validate JSON structure
   - Send to broadcast channel
   - Hub distributes to all clients except sender
5. On disconnect:
   - Unregister client via `unregister` channel
   - Close client channels
   - Log disconnection

**Error Handling:**
- Graceful shutdown on SIGTERM/SIGINT (10s timeout)
- WebSocket unexpected close detection
- Message size validation
- JSON validation before broadcast
- Context-based shutdown coordination

---

### 3. Web Dashboard (Frontend)

**Location:** `public/index.html`, `public/index.js`

**Purpose:** Provides real-time visualization of intercepted Telegram traffic.

**Technology Stack:**
- **Vue.js 2**: Reactive UI framework
- **Bootstrap 5**: UI components and styling
- **JSONEditor**: Interactive JSON tree viewer
- **vue-json-pretty**: JSON syntax highlighting
- **vue-bottom-sheet**: Modal bottom sheet for detail view

**Features:**

#### Real-time Message Display
- Auto-scrolling table of messages
- Color-coded badges for message types
- Row index for reference

#### Filtering
- **Client ID Filter**: Show only messages from specific device
- **Type Filter**: REQUEST/RESPONSE/ERROR/SERVER
- **Search**: Text search across messages (future enhancement)

#### Message Details
- Click "Show Json" to open bottom sheet
- Left panel: Request JSON
- Right panel: Correlated Response JSON(s)
- Copy to clipboard functionality

#### Session Management
- **Export**: Download current messages as JSON file
- **Import**: Load previously exported session
- **Clear**: Remove all messages from current view
- **Hold**: Pause receiving new messages

**Data Structure:**

Each message object contains:
```javascript
{
  CLIENTID: "device-identifier",
  TYPE: "REQUEST" | "RESPONSE" | "ERROR" | "Server",
  TOKEN: 12345,  // Request/Response correlation ID
  TIME: "2023-01-16 10:30:45",
  UUID: "1705401045123_4567",  // Unique message ID
  CLASS_NAME: "TL_messages_sendMessage",
  constructor: "520c3870",  // TLRPC constructor hex
  // ... TLRPC object fields ...
}
```

**Vue.js Reactive Data:**
```javascript
data: {
  messages: [],           // All received messages
  clientId: "",           // Filter by client ID
  messageTypeFilter: "all", // Filter by type
  hold: false,            // Pause receiving
  query: "",              // Search query (future)
  requestJsonContainer: {},  // Current request detail
  responseJsonContainer: []  // Current response(s) detail
}
```

---

## Data Flow

### Complete Request/Response Cycle

```
1. User Action in Telegram App
   └─> Telegram Code calls ConnectionsManager.sendRequest()
       └─> TelegramRequestSniffer.logTLRPCObject(request, "REQUEST", token)
           └─> Serialize to JSON
               └─> WebSocket.send(json)
                   │
                   ▼
2. WebSocket Message arrives at Server
   └─> server.js receives message
       └─> Validates size
           └─> Broadcasts to all dashboard clients
               │
               ▼
3. Dashboard Receives Message
   └─> WebSocket 'message' event fires
       └─> JSON.parse(message)
           └─> Check clientId filter
               └─> messages.push(jsonObject)
                   └─> Vue updates UI reactively

4. Telegram Receives Response from Server
   └─> ConnectionsManager callback fires
       └─> TelegramRequestSniffer.logTLRPCObject(response, "RESPONSE", token)
           └─> Same flow as step 1-3
               └─> Dashboard correlates by TOKEN
```

### Request/Response Correlation

Requests and responses are matched using the `TOKEN` field:

1. Each request generates unique token (incremental integer)
2. Request logged with type="REQUEST", token=N
3. Response logged with type="RESPONSE", token=N (same N)
4. Dashboard matches them when displaying details
5. Multiple responses possible for single request (streaming APIs)

---

## Message Protocol

### WebSocket Message Format

Messages are sent as JSON strings over WebSocket:

```json
{
  "CLIENTID": "my-device-id",
  "TYPE": "REQUEST",
  "TOKEN": 42,
  "TIME": "2023-01-16 14:30:45",
  "UUID": "1705417845000_1234",
  "CLASS_NAME": "TL_messages_sendMessage",
  "constructor": "520c3870",
  "peer": {
    "CLASS_NAME": "TL_inputPeerUser",
    "user_id": 123456789,
    "access_hash": 98765432109876543
  },
  "message": "Hello, World!",
  "random_id": 7654321098765432,
  "flags": 0
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `CLIENTID` | String | Unique identifier for the Android device |
| `TYPE` | Enum | "REQUEST", "RESPONSE", "ERROR", "Server" |
| `TOKEN` | Integer | Correlation ID for request/response matching |
| `TIME` | String | Timestamp when message was intercepted |
| `UUID` | String | Unique message identifier (timestamp + random) |
| `CLASS_NAME` | String | TLRPC class name (e.g., TL_messages_sendMessage) |
| `constructor` | String | Hex value of TLRPC constructor ID |
| ...fields... | Various | Actual TLRPC object fields |

---

## Configuration

### Environment Variables

Server configuration via `.env` file:

```bash
PORT=3000              # HTTP/WebSocket server port
NODE_ENV=development   # Environment mode
CORS_ORIGIN=*          # CORS allowed origins
WS_HOST=localhost      # WebSocket host
LOG_LEVEL=info         # Logging verbosity
```

### Android Configuration

Hardcoded in `TelegramRequestSniffer.java` (must be edited before compilation):

```java
private static String serverUrl = "ws://10.0.2.2:3000";  // Server URL
private static String clientId = "my-device-id";         // Client identifier
```

### Dashboard Configuration

Hardcoded in `public/index.js`:

```javascript
var urlLocal = "ws://localhost:3000/ws"  // WebSocket server URL
```

---

## Security Considerations

### Known Vulnerabilities

1. **No Authentication**: WebSocket accepts all connections
2. **No Encryption**: Default `ws://` is unencrypted
3. **No Authorization**: Any client can send/receive all messages
4. **Sensitive Data**: Intercepts credentials, tokens, messages
5. **DoS Risk**: Limited protection (message size only)

### Mitigations

**For Development:**
- Use only on localhost or isolated networks
- Never expose to public internet
- Delete captured data immediately after testing

**For Production/Shared Environments:**
- Use reverse proxy with SSL (nginx/Apache)
- Implement authentication middleware
- Use VPN or SSH tunneling
- Add rate limiting
- Implement access controls

---

## Performance Considerations

### Scalability

**Current Limitations:**
- All messages stored in browser memory (can grow large)
- Server broadcasts to all clients (O(n) per message)
- No message batching or throttling

**Optimization Strategies:**
- Clear messages frequently
- Use "Hold" feature during high traffic
- Limit number of connected dashboards
- Consider pagination for large message counts

### Resource Usage

**Server (Go):**
- Very low CPU usage (efficient goroutines)
- Memory: ~8MB base + WebSocket buffers
- Network: Depends on message volume
- **75% less memory than Node.js version**

**Browser:**
- Memory grows with message count
- 1000 messages ≈ 10-50MB RAM
- JSONEditor can be slow with very large objects

**Android:**
- Minimal overhead (~1-2% CPU)
- WebSocket connection is persistent
- Serialization uses reflection (some overhead)

---

## Deployment

### Docker Deployment

**Multi-Stage Build:**
- **Builder Stage**: `golang:1.21-alpine` - Compiles Go binary
- **Runtime Stage**: `alpine:latest` - Minimal runtime (~15MB final image)
- User: `appuser` (non-root for security)
- Health check: wget to port 3000
- Working dir: `/app`

**Docker Compose:**
```yaml
services:
  telegram-sniffer:
    build: .
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - NODE_ENV=production
    restart: unless-stopped
```

### Traditional Deployment

```bash
# Clone and setup
git clone https://github.com/moradi-morteza/telegram-request-sniffer.git
cd telegram-request-sniffer

# Install dependencies
go mod download
go mod tidy

# Configure
cp .env.example .env
# Edit .env as needed

# Option 1: Run directly
go run cmd/server/main.go

# Option 2: Build and run
go build -o telegram-sniffer cmd/server/main.go
./telegram-sniffer

# Option 3: Using Make
make run

# Option 4: Install as system service (systemd example)
make build
sudo cp bin/telegram-sniffer /usr/local/bin/
# Create systemd service file
```

---

## Development

### Adding New Features

**New Message Types:**
1. Update Android integration points
2. Add TYPE constant in TelegramRequestSniffer.java
3. Add badge color in `getTypeBadge()` (public/index.js)
4. Update filters in dashboard

**New Filters:**
1. Add data property in Vue component
2. Add UI control in index.html
3. Update `filteredData` computed property
4. Save to localStorage for persistence

**Database Support (Future):**
1. Uncomment database import in server.js
2. Enable saveMessage() in message handler
3. Add API endpoint to retrieve messages
4. Update dashboard to fetch on load

---

## Troubleshooting

### Common Issues

**Android can't connect:**
- Check server URL (10.0.2.2 for emulator, actual IP for device)
- Verify server is running and reachable
- Check firewall settings
- Review Android logs: `adb logcat | grep TelegramRequestSniffer`

**Messages not appearing:**
- Verify TelegramRequestSniffer.init() is called
- Check integration points in Telegram code
- Ensure client ID matches in dashboard
- Check browser console for errors

**WebSocket disconnects:**
- Check network stability
- Review server logs for errors
- Verify no aggressive firewall/proxy
- Check for port conflicts

---

## Future Enhancements

### Planned Features

1. **Authentication**: JWT or API key authentication
2. **Search**: Full-text search across messages
3. **Persistence**: Optional database storage
4. **Message Replay**: Re-send captured messages
5. **Diff View**: Compare request/response differences
6. **Statistics**: Message counts, timing, error rates
7. **Export Formats**: PDF, CSV, HAR format
8. **Dark Mode**: UI theme support

### Performance Improvements

1. Virtual scrolling for large message lists
2. Message pagination
3. WebSocket message batching
4. Compression (gzip) for large payloads
5. Worker threads for JSON parsing

---

## References

- [Telegram Android Source](https://github.com/DrKLO/Telegram)
- [TLRPC Schema](https://core.telegram.org/schema)
- [WebSocket Protocol](https://datatracker.ietf.org/doc/html/rfc6455)
- [Vue.js Documentation](https://v2.vuejs.org/)

---

---

**Last Updated:** November 2024

For questions or contributions, see [CONTRIBUTING.md](../CONTRIBUTING.md)
