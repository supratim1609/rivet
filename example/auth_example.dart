import 'dart:io';
import 'package:rivet/rivet.dart';

/// Comprehensive Auth System Example
/// 
/// Demonstrates:
/// - User registration with password hashing
/// - Login with JWT generation
/// - Protected routes with @Auth() decorator
/// - Role-based authorization
/// - OAuth login (Google + GitHub)
/// - Token refresh endpoint
/// 
/// ⚠️  SECURITY WARNING:
/// This example uses environment variables for secrets.
/// NEVER hardcode secrets in production code!
/// 
/// Setup:
/// 1. Copy .env.example to .env
/// 2. Fill in your actual OAuth credentials
/// 3. Run: dart run example/auth_example.dart

void main() async {
  // Load environment variables
  final jwtSecret = Platform.environment['JWT_SECRET'] ?? 
      'dev-secret-key-CHANGE-IN-PRODUCTION';
  
  if (jwtSecret == 'dev-secret-key-CHANGE-IN-PRODUCTION') {
    print('⚠️  WARNING: Using default JWT secret!');
    print('   Set JWT_SECRET environment variable for production.');
    print('');
  }

  // Initialize JWT service
  final jwt = JwtService(
    secret: jwtSecret,
    defaultExpiry: Duration(hours: 1),
  );

  // Initialize server with JWT service for @Auth() decorator support
  final app = RivetServer(jwtService: jwt);

  // Initialize OAuth providers (only if credentials are set)
  GoogleOAuthProvider? googleOAuth;
  GitHubOAuthProvider? githubOAuth;

  final googleClientId = Platform.environment['GOOGLE_CLIENT_ID'];
  final googleClientSecret = Platform.environment['GOOGLE_CLIENT_SECRET'];
  
  if (googleClientId != null && googleClientSecret != null) {
    googleOAuth = GoogleOAuthProvider(
      clientId: googleClientId,
      clientSecret: googleClientSecret,
    );
  } else {
    print('ℹ️  Google OAuth not configured (set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET)');
  }

  final githubClientId = Platform.environment['GITHUB_CLIENT_ID'];
  final githubClientSecret = Platform.environment['GITHUB_CLIENT_SECRET'];
  
  if (githubClientId != null && githubClientSecret != null) {
    githubOAuth = GitHubOAuthProvider(
      clientId: githubClientId,
      clientSecret: githubClientSecret,
    );
  } else {
    print('ℹ️  GitHub OAuth not configured (set GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET)');
  }

  // ============================================================================
  // PUBLIC ROUTES (No Authentication Required)
  // ============================================================================

  app.get('/', (req) {
    return RivetResponse.json({
      'message': 'Rivet Auth System Example',
      'endpoints': {
        'public': ['GET /', 'POST /auth/register', 'POST /auth/login'],
        'protected': ['GET /profile', 'GET /admin/users'],
        'oauth': ['GET /auth/google', 'GET /auth/github'],
      },
    });
  });

  // ============================================================================
  // AUTHENTICATION ROUTES
  // ============================================================================

  /// Register a new user
  app.post('/auth/register', (req) async {
    final body = req.jsonBody ?? {};
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final name = body['name'] as String?;

    if (email == null || password == null) {
      return RivetResponse.badRequest('Email and password are required');
    }

    // Hash password
    final passwordHash = PasswordHasher.hash(password);

    // In production, save to database
    // For demo, we'll just return success
    print('User registered: $email (hash: ${passwordHash.substring(0, 20)}...)');

    return RivetResponse.json({
      'message': 'User registered successfully',
      'user': {
        'email': email,
        'name': name,
      },
    });
  });

  /// Login with email and password
  app.post('/auth/login', (req) async {
    final body = req.jsonBody ?? {};
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return RivetResponse.badRequest('Email and password are required');
    }

    // In production, fetch user from database
    // For demo, we'll simulate a user
    final storedPasswordHash = PasswordHasher.hash('password123');
    
    // Verify password
    if (!PasswordHasher.verify(password, storedPasswordHash)) {
      return RivetResponse.unauthorized('Invalid credentials');
    }

    // Generate JWT token
    final token = jwt.sign({
      'userId': 1,
      'email': email,
      'roles': ['user'], // Add 'admin' for admin users
    });

    return RivetResponse.json({
      'message': 'Login successful',
      'token': token,
      'user': {
        'id': 1,
        'email': email,
        'roles': ['user'],
      },
    });
  });

  /// Refresh JWT token
  app.post('/auth/refresh', (req) async {
    final body = req.jsonBody ?? {};
    final oldToken = body['token'] as String?;

    if (oldToken == null) {
      return RivetResponse.badRequest('Token is required');
    }

    try {
      final newToken = jwt.refresh(oldToken);
      return RivetResponse.json({
        'message': 'Token refreshed successfully',
        'token': newToken,
      });
    } catch (e) {
      return RivetResponse.unauthorized('Invalid or expired token');
    }
  });

  // ============================================================================
  // OAUTH ROUTES
  // ============================================================================

  /// Redirect to Google OAuth
  app.get('/auth/google', (req) {
    if (googleOAuth == null) {
      return RivetResponse.json({
        'error': 'Google OAuth not configured',
        'message': 'Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET environment variables',
      }, statusCode: 503);
    }
    
    final authUrl = googleOAuth.getAuthorizationUrl(
      Platform.environment['GOOGLE_REDIRECT_URI'] ?? 'http://localhost:3000/auth/google/callback',
      ['email', 'profile'],
      state: 'random-state-string', // Use a random state for CSRF protection
    );
    return RivetResponse.redirect(authUrl);
  });

  /// Google OAuth callback
  app.get('/auth/google/callback', (req) async {
    if (googleOAuth == null) {
      return RivetResponse.json({
        'error': 'Google OAuth not configured',
      }, statusCode: 503);
    }
    
    final code = req.query['code'];
    final state = req.query['state'];

    if (code == null) {
      return RivetResponse.badRequest('Missing authorization code');
    }

    // Verify state parameter in production
    if (state != 'random-state-string') {
      return RivetResponse.badRequest('Invalid state parameter');
    }

    try {
      // Exchange code for token
      final oauthToken = await googleOAuth.exchangeCode(
        code,
        Platform.environment['GOOGLE_REDIRECT_URI'] ?? 'http://localhost:3000/auth/google/callback',
      );

      // Get user info
      final oauthUser = await googleOAuth.getUserInfo(oauthToken.accessToken);

      // In production, create or update user in database
      print('Google user: ${oauthUser.email}');

      // Generate JWT
      final token = jwt.sign({
        'userId': oauthUser.id,
        'email': oauthUser.email,
        'name': oauthUser.name,
        'roles': ['user'],
        'provider': 'google',
      });

      return RivetResponse.json({
        'message': 'Google login successful',
        'token': token,
        'user': {
          'id': oauthUser.id,
          'email': oauthUser.email,
          'name': oauthUser.name,
          'avatar': oauthUser.avatarUrl,
        },
      });
    } catch (e) {
      return RivetResponse.json({
        'error': 'OAuth failed: $e',
      }, statusCode: 500);
    }
  });

  /// Redirect to GitHub OAuth
  app.get('/auth/github', (req) {
    if (githubOAuth == null) {
      return RivetResponse.json({
        'error': 'GitHub OAuth not configured',
        'message': 'Set GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET environment variables',
      }, statusCode: 503);
    }
    
    final authUrl = githubOAuth.getAuthorizationUrl(
      Platform.environment['GITHUB_REDIRECT_URI'] ?? 'http://localhost:3000/auth/github/callback',
      ['user:email'],
      state: 'random-state-string',
    );
    return RivetResponse.redirect(authUrl);
  });

  /// GitHub OAuth callback
  app.get('/auth/github/callback', (req) async {
    if (githubOAuth == null) {
      return RivetResponse.json({
        'error': 'GitHub OAuth not configured',
      }, statusCode: 503);
    }
    
    final code = req.query['code'];
    final state = req.query['state'];

    if (code == null) {
      return RivetResponse.badRequest('Missing authorization code');
    }

    if (state != 'random-state-string') {
      return RivetResponse.badRequest('Invalid state parameter');
    }

    try {
      final oauthToken = await githubOAuth.exchangeCode(
        code,
        Platform.environment['GITHUB_REDIRECT_URI'] ?? 'http://localhost:3000/auth/github/callback',
      );

      final oauthUser = await githubOAuth.getUserInfo(oauthToken.accessToken);

      print('GitHub user: ${oauthUser.email}');

      final token = jwt.sign({
        'userId': oauthUser.id,
        'email': oauthUser.email,
        'name': oauthUser.name,
        'roles': ['user'],
        'provider': 'github',
      });

      return RivetResponse.json({
        'message': 'GitHub login successful',
        'token': token,
        'user': {
          'id': oauthUser.id,
          'email': oauthUser.email,
          'name': oauthUser.name,
          'avatar': oauthUser.avatarUrl,
        },
      });
    } catch (e) {
      return RivetResponse.json({
        'error': 'OAuth failed: $e',
      }, statusCode: 500);
    }
  });

  // ============================================================================
  // PROTECTED ROUTES (Using @Auth() Decorator with Controller)
  // ============================================================================

  // Register controller with @Auth() decorators
  app.registerController(UserController());

  // ============================================================================
  // START SERVER
  // ============================================================================

  await app.listen(port: 3000);
  print('🚀 Auth example server running on http://localhost:3000');
  print('');
  print('Try these commands:');
  print('');
  print('# Register a user');
  print('curl -X POST http://localhost:3000/auth/register \\');
  print('  -H "Content-Type: application/json" \\');
  print('  -d \'{"email":"test@example.com","password":"password123","name":"Test User"}\'');
  print('');
  print('# Login');
  print('curl -X POST http://localhost:3000/auth/login \\');
  print('  -H "Content-Type: application/json" \\');
  print('  -d \'{"email":"test@example.com","password":"password123"}\'');
  print('');
  print('# Access protected route (use token from login)');
  print('curl http://localhost:3000/api/profile \\');
  print('  -H "Authorization: Bearer YOUR_TOKEN_HERE"');
  print('');
  print('# Access admin route (will fail without admin role)');
  print('curl http://localhost:3000/api/admin/dashboard \\');
  print('  -H "Authorization: Bearer YOUR_TOKEN_HERE"');
}

// ============================================================================
// CONTROLLER WITH @Auth() DECORATORS
// ============================================================================

@RivetController()
class UserController {
  /// Get user profile (requires authentication)
  @Get('/api/profile')
  @Auth()
  Future<RivetResponse> getProfile(RivetRequest req) async {
    final user = req.user!;
    return RivetResponse.json({
      'message': 'Your profile (from controller)',
      'user': user,
    });
  }

  /// Get all users (requires admin role)
  @Get('/api/admin/users')
  @Auth(roles: ['admin'])
  Future<RivetResponse> getUsers(RivetRequest req) async {
    return RivetResponse.json({
      'message': 'All users (admin only)',
      'users': [
        {'id': 1, 'email': 'user1@example.com', 'roles': ['user']},
        {'id': 2, 'email': 'admin@example.com', 'roles': ['admin']},
      ],
    });
  }

  /// Get admin dashboard (requires admin role)
  @Get('/api/admin/dashboard')
  @Auth(roles: ['admin'])
  Future<RivetResponse> getAdminDashboard(RivetRequest req) async {
    final user = req.user!;
    return RivetResponse.json({
      'message': 'Admin dashboard',
      'admin': user,
      'stats': {
        'totalUsers': 42,
        'activeUsers': 38,
        'newToday': 5,
      },
    });
  }

  /// Optional auth route (validates token if present, but doesn't require it)
  @Get('/api/public-with-optional-auth')
  @Auth(optional: true)
  Future<RivetResponse> getPublicWithOptionalAuth(RivetRequest req) async {
    if (req.user != null) {
      return RivetResponse.json({
        'message': 'Hello, authenticated user!',
        'user': req.user,
      });
    } else {
      return RivetResponse.json({
        'message': 'Hello, anonymous user!',
      });
    }
  }
}
