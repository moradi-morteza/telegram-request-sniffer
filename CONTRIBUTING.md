# Contributing to Telegram Request Sniffer

Thanks for your interest in helping improve Telegram Request Sniffer! This guide explains how you can contribute and what we expect.

## Code of Conduct

By contributing, you agree to follow our [Code of Conduct](CODE_OF_CONDUCT.md). It keeps the community safe and respectful, so please take a moment to read it.

## How You Can Contribute

### Reporting Bugs

Before opening a new bug report, check the existing issues. When reporting a bug, include:

* A clear and descriptive title
* Exact steps to reproduce the issue
* What you expected vs. what actually happened
* Screenshots or logs (if they help)
* Details about your environment:

  * Node.js version
  * Operating system
  * Browser (for frontend issues)
  * Android version (for integration issues)

### Suggesting Improvements

Have an idea for a new feature or enhancement? Great. When creating an enhancement issue:

* Use a clear title
* Describe the idea in detail
* Explain why it would be useful
* Mention similar features in other tools, if any

### Pull Requests

To contribute code:

1. Fork the repository and create a branch from `master`
2. Make your changes following the project’s coding style
3. Test everything carefully
4. Update documentation if necessary
5. Write clear commit messages
6. Open a pull request

#### Pull Request Tips

* Keep PRs focused on a single change
* Write readable commit messages
* Reference related issues
* Make sure tests pass (when tests are available)
* Update README.md if needed
* Follow the existing style and structure of the codebase

## Development Setup

### Requirements

* Node.js 20+
* Git
* A text editor or IDE of your choice

### Getting Started

```bash
git clone https://github.com/YOUR_USERNAME/telegram-request-sniffer.git
cd telegram-request-sniffer
npm install
cp .env.example .env
npm run dev
```

### Project Structure

```
telegram-request-sniffer/
├── android/           # Android integration
├── public/            # Frontend assets
├── docs/              # Documentation files
├── server.js          # Server entry point
├── package.json       # Dependencies and metadata
└── Dockerfile         # Docker setup
```

## Coding Standards

### JavaScript Guidelines

* Use 4 spaces for indentation
* Use `const` for constants and `let` for variables
* Choose clear and meaningful names
* Add comments where needed
* Keep functions focused and readable

### Example

```javascript
// Good
const MAX_MESSAGE_SIZE = 1024 * 1024;

function validateMessage(message) {
    if (message.length > MAX_MESSAGE_SIZE) {
        throw new Error('Message too large');
    }
    return true;
}

// Not recommended
const m = 1048576;
function v(msg) {
    if (msg.length > m) throw new Error('too big');
    return true;
}
```

### Commit Messages

Use simple, descriptive commit messages.

Format:

```
<type>: <short description>

<body (optional)>

<footer (optional)>
```

**Types:**
`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples:**

```
feat: add message size validation

Added a limit to prevent large messages from causing crashes.
Maximum message size is now 1MB.

Closes #42
```

```
fix: handle WebSocket disconnections properly

Resolved a memory leak caused by unclosed WebSocket connections.
```

## Testing

There’s no automated testing yet. If you want to help by adding tests, that would be amazing!

### Manual Testing Checklist

Before submitting a PR, verify:

* [ ] Server starts without errors
* [ ] WebSocket connects successfully
* [ ] Messages appear in the dashboard
* [ ] Filters work correctly
* [ ] Import/Export works
* [ ] Docker build completes
* [ ] No browser console errors

## Documentation

Good documentation helps everyone. Please:

* Update README.md for any changed behavior
* Add inline comments where needed
* Update ARCHITECTURE.md for major changes
* Add JSDoc when applicable

### Example JSDoc

```javascript
/**
 * Validates incoming WebSocket messages
 * @param {string} message
 * @param {number} maxSize
 * @returns {boolean}
 * @throws {Error} If message exceeds maxSize
 */
function validateMessage(message, maxSize) {
    // ...
}
```

## Security Guidelines

* Never commit sensitive data
* Double-check changes for security risks
* Report vulnerabilities privately (see SECURITY.md)
* Be aware of common issues like XSS or injection attacks

## License

By contributing, you agree that your work will be licensed under the MIT License.
