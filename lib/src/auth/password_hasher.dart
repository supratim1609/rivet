import 'package:bcrypt/bcrypt.dart';

/// Utility class for secure password hashing and verification
class PasswordHasher {
  /// Number of salt rounds for bcrypt (higher = more secure but slower)
  static const int _saltRounds = 12;

  /// Hash a plaintext password using bcrypt
  /// 
  /// [password] - The plaintext password to hash
  /// 
  /// Returns the bcrypt hash string
  static String hash(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: _saltRounds));
  }

  /// Verify a plaintext password against a bcrypt hash
  /// 
  /// [password] - The plaintext password to verify
  /// [hash] - The bcrypt hash to compare against
  /// 
  /// Returns true if the password matches the hash, false otherwise
  /// Uses constant-time comparison to prevent timing attacks
  static bool verify(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } catch (e) {
      // Invalid hash format
      return false;
    }
  }

  /// Generate a random salt (useful for testing)
  /// 
  /// Returns a bcrypt salt string
  static String generateSalt() {
    return BCrypt.gensalt(logRounds: _saltRounds);
  }
}
