# Security Policy

## ⚠️ Important Disclaimers

### Legal and Ethical Use Only

**This tool is intended ONLY for authorized security research, development, and debugging purposes.**

- ✅ **Authorized Use Cases:**
  - Debugging your own Telegram client modifications during development
  - Security research in controlled environments
  - Educational purposes with proper authorization
  - Testing your own applications built on Telegram's API

- ❌ **Prohibited Use Cases:**
  - Monitoring other users without their explicit consent
  - Intercepting communications you are not authorized to access
  - Violating Telegram's Terms of Service
  - Any activity that violates local, national, or international laws

### Legal Considerations

**WARNING:** Unauthorized interception of communications may be illegal in your jurisdiction. This includes but is not limited to:

- Wiretapping laws
- Computer fraud and abuse laws
- Privacy and data protection regulations (GDPR, CCPA, etc.)
- Telecommunications regulations

**By using this software, you acknowledge that:**
1. You are solely responsible for ensuring your use complies with all applicable laws
2. The authors and contributors assume no liability for misuse
3. You will only use this tool in authorized testing environments
4. You understand the legal implications in your jurisdiction

### Privacy and Data Handling

This tool intercepts and displays sensitive information including:
- Authentication tokens
- Phone numbers
- Message content
- User identifiers
- API credentials

**Security Best Practices:**
1. **Never expose the WebSocket server to the public internet**
2. **Always use this tool in isolated, secure environments**
3. **Immediately delete captured data after testing**
4. **Never commit real data to version control**
5. **Use strong authentication if deploying in shared environments**
6. **Consider using WSS (WebSocket Secure) for production deployments**

## Security Risks

### Known Security Considerations

1. **No Authentication:** The WebSocket server has no built-in authentication. Anyone with network access can connect.
2. **No Encryption:** Local WebSocket connections use unencrypted `ws://` protocol by default.
3. **Data Exposure:** All intercepted traffic is visible in the web dashboard.
4. **No Rate Limiting:** Basic DoS protection through message size limits only.

### Recommended Mitigations

For production or shared environments:
- Implement authentication middleware
- Use reverse proxy with SSL/TLS (nginx, Apache)
- Enable firewall rules to restrict access
- Use VPN or SSH tunneling for remote access
- Implement proper access controls

## Reporting Security Vulnerabilities

If you discover a security vulnerability in this project, please report it responsibly:

1. **DO NOT** open a public GitHub issue
2. Email the maintainer directly (see package.json for contact)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

We will acknowledge receipt within 48 hours and provide a timeline for fixes.

## Telegram's Terms of Service

This tool requires modifying the Telegram Android application source code. Please note:

- Telegram is open source under GPLv3 for Android
- Modified versions should not be distributed without proper disclosure
- You must comply with Telegram's API Terms of Service
- API credentials (`api_id`, `api_hash`) are for your personal use only

## Data Retention

**Recommendation:** This tool should operate with **zero data retention** for security:

- Data is only held in memory and browser
- Clear browser data after each session
- No persistent database storage (removed in v1.0.0)
- Export functionality is for debugging only - exports should be deleted after use

## Compliance

Users are responsible for ensuring compliance with:
- Local and international laws
- Organizational security policies
- Industry regulations (HIPAA, PCI-DSS, etc. if applicable)
- Telegram's Terms of Service and Privacy Policy

## Updates and Patches

Security updates will be released as needed. Users should:
- Keep dependencies up to date (`npm audit` regularly)
- Monitor this repository for security advisories
- Subscribe to notifications for security-related releases

---

**Last Updated:** January 2023

**Remember:** With great power comes great responsibility. Use this tool ethically and legally.
