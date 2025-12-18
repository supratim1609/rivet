import 'dart:convert';
import 'package:http/http.dart' as http;

/// OAuth token response
class OAuthToken {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final String? scope;

  OAuthToken({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.scope,
  });

  factory OAuthToken.fromJson(Map<String, dynamic> json) {
    return OAuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
      scope: json['scope'] as String?,
    );
  }
}

/// OAuth user information
class OAuthUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final Map<String, dynamic> rawData;

  OAuthUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.rawData,
  });
}

/// Abstract OAuth provider interface
abstract class OAuthProvider {
  /// Get the OAuth authorization URL
  /// 
  /// [redirectUri] - The callback URL after authorization
  /// [scopes] - List of permission scopes to request
  /// [state] - Optional state parameter for CSRF protection
  /// 
  /// Returns the authorization URL to redirect the user to
  String getAuthorizationUrl(
    String redirectUri,
    List<String> scopes, {
    String? state,
  });

  /// Exchange authorization code for access token
  /// 
  /// [code] - The authorization code from the callback
  /// [redirectUri] - The same redirect URI used in authorization
  /// 
  /// Returns the OAuth token
  Future<OAuthToken> exchangeCode(String code, String redirectUri);

  /// Get user information using the access token
  /// 
  /// [accessToken] - The OAuth access token
  /// 
  /// Returns the user information
  Future<OAuthUser> getUserInfo(String accessToken);
}

/// Google OAuth 2.0 provider
class GoogleOAuthProvider extends OAuthProvider {
  final String clientId;
  final String clientSecret;

  static const String _authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _tokenUrl = 'https://oauth2.googleapis.com/token';
  static const String _userInfoUrl = 'https://www.googleapis.com/oauth2/v2/userinfo';

  GoogleOAuthProvider({
    required this.clientId,
    required this.clientSecret,
  });

  @override
  String getAuthorizationUrl(
    String redirectUri,
    List<String> scopes, {
    String? state,
  }) {
    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes.join(' '),
      if (state != null) 'state': state,
      'access_type': 'offline',
      'prompt': 'consent',
    };

    final uri = Uri.parse(_authUrl).replace(queryParameters: params);
    return uri.toString();
  }

  @override
  Future<OAuthToken> exchangeCode(String code, String redirectUri) async {
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to exchange code: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthToken.fromJson(json);
  }

  @override
  Future<OAuthUser> getUserInfo(String accessToken) async {
    final response = await http.get(
      Uri.parse(_userInfoUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user info: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['picture'] as String?,
      rawData: json,
    );
  }
}

/// GitHub OAuth provider
class GitHubOAuthProvider extends OAuthProvider {
  final String clientId;
  final String clientSecret;

  static const String _authUrl = 'https://github.com/login/oauth/authorize';
  static const String _tokenUrl = 'https://github.com/login/oauth/access_token';
  static const String _userInfoUrl = 'https://api.github.com/user';

  GitHubOAuthProvider({
    required this.clientId,
    required this.clientSecret,
  });

  @override
  String getAuthorizationUrl(
    String redirectUri,
    List<String> scopes, {
    String? state,
  }) {
    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      if (state != null) 'state': state,
    };

    final uri = Uri.parse(_authUrl).replace(queryParameters: params);
    return uri.toString();
  }

  @override
  Future<OAuthToken> exchangeCode(String code, String redirectUri) async {
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to exchange code: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthToken.fromJson(json);
  }

  @override
  Future<OAuthUser> getUserInfo(String accessToken) async {
    final response = await http.get(
      Uri.parse(_userInfoUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user info: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    
    // GitHub doesn't always provide email in the user endpoint
    // You may need to fetch it separately from /user/emails
    return OAuthUser(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      rawData: json,
    );
  }
}
