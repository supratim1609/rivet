# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x.x   | :white_check_mark: |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of Rivet seriously. If you discover a security vulnerability, please follow these steps:

### 1. **DO NOT** Open a Public Issue

Please do not report security vulnerabilities through public GitHub issues.

### 2. Report Privately

Email security details to: **[your-email@example.com]**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### 3. Response Timeline

- **24 hours**: Initial response acknowledging receipt
- **72 hours**: Assessment and severity classification
- **7 days**: Fix development (for critical issues)
- **14 days**: Public disclosure (after fix is released)

## Security Best Practices

### For Users

#### 1. Environment Variables

**Never** hardcode secrets in your code:

```dart
// ❌ BAD
final jwt = JwtService(secret: 'my-secret-key');

// ✅ GOOD
final jwt = JwtService(secret: Platform.environment['JWT_SECRET']!);
```

#### 2. OAuth Credentials

Store OAuth credentials in environment variables:

```bash
# .env (never commit this!)
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GITHUB_CLIENT_ID=your-client-id
GITHUB_CLIENT_SECRET=your-client-secret
JWT_SECRET=your-super-secret-key
```

Load in code:
```dart
import 'dart:io';

final googleOAuth = GoogleOAuthProvider(
  clientId: Platform.environment['GOOGLE_CLIENT_ID']!,
  clientSecret: Platform.environment['GOOGLE_CLIENT_SECRET']!,
);
```

#### 3. Database Credentials

```bash
# .env
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
```

#### 4. HTTPS in Production

**Always** use HTTPS in production:

```dart
// Use a reverse proxy (nginx, Caddy) with SSL
// Or use Dart's secure server
final server = await HttpServer.bindSecure(
  InternetAddress.anyIPv4,
  443,
  context,
);
```

#### 5. Rate Limiting

Implement rate limiting for auth endpoints:

```dart
// Prevent brute force attacks
app.use(rateLimiter(
  maxRequests: 5,
  window: Duration(minutes: 15),
  endpoints: ['/auth/login', '/auth/register'],
));
```

### For Contributors

#### 1. Code Review

All security-related changes require:
- Two approvals
- Security team review
- Automated security scans

#### 2. Dependencies

- Keep dependencies updated
- Run `dart pub outdated` regularly
- Review dependency security advisories

#### 3. Testing

- Write security tests
- Test auth flows thoroughly
- Verify input validation

## Known Security Considerations

### 1. JWT Secret Management

- **Issue**: JWT secrets must be kept secure
- **Mitigation**: Use environment variables, rotate regularly
- **Best Practice**: Use at least 256-bit secrets

### 2. Password Hashing

- **Implementation**: Bcrypt with 12 salt rounds
- **Security**: Resistant to rainbow table attacks
- **Performance**: ~1 second per hash (intentional)

### 3. OAuth State Parameter

- **Issue**: CSRF attacks on OAuth flows
- **Mitigation**: Always use state parameter
- **Implementation**: Random, unique per request

### 4. CORS Configuration

- **Issue**: Unrestricted CORS allows any origin
- **Mitigation**: Whitelist specific origins
- **Example**:
  ```dart
  app.use(cors(
    allowedOrigins: ['https://yourdomain.com'],
    allowCredentials: true,
  ));
  ```

## Security Features

### ✅ Built-in Security

- **Password Hashing**: Bcrypt with configurable rounds
- **JWT**: HS256 signing with expiry
- **Input Validation**: Decorator-based validation
- **CORS**: Configurable middleware
- **Rate Limiting**: (Coming in v2.1)

### 🔄 Planned Security Features

- [ ] Built-in rate limiting
- [ ] CSRF protection
- [ ] Security headers middleware
- [ ] SQL injection prevention (ORM)
- [ ] XSS protection
- [ ] Request signing

## Vulnerability Disclosure

We follow responsible disclosure:

1. **Private Report**: Security researcher reports privately
2. **Acknowledgment**: We acknowledge within 24 hours
3. **Fix Development**: We develop and test fix
4. **Coordinated Release**: We release fix and advisory
5. **Public Disclosure**: Details published after fix is available
6. **Credit**: Researcher credited (if desired)

## Security Hall of Fame

We recognize security researchers who help keep Rivet secure:

- *Your name could be here!*

## Contact

- **Security Email**: [your-email@example.com]
- **PGP Key**: [Link to PGP key]
- **Response Time**: 24-48 hours

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Dart Security Best Practices](https://dart.dev/guides/security)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

**Last Updated**: December 2025  
**Version**: 2.0
