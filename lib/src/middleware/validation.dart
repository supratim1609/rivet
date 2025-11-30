import 'dart:async';
import '../http/request.dart';
import '../utils/exception.dart';
import 'middleware.dart';

// Validation rules
abstract class ValidationRule {
  String validate(dynamic value);
}

class RequiredRule extends ValidationRule {
  @override
  String validate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'This field is required';
    }
    return '';
  }
}

class EmailRule extends ValidationRule {
  @override
  String validate(dynamic value) {
    if (value == null) return '';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.toString())) {
      return 'Invalid email format';
    }
    return '';
  }
}

class MinLengthRule extends ValidationRule {
  final int min;
  MinLengthRule(this.min);

  @override
  String validate(dynamic value) {
    if (value == null) return '';
    if (value.toString().length < min) {
      return 'Minimum length is $min characters';
    }
    return '';
  }
}

class MaxLengthRule extends ValidationRule {
  final int max;
  MaxLengthRule(this.max);

  @override
  String validate(dynamic value) {
    if (value == null) return '';
    if (value.toString().length > max) {
      return 'Maximum length is $max characters';
    }
    return '';
  }
}

class Validator {
  final Map<String, List<ValidationRule>> rules = {};

  void field(String name, List<ValidationRule> fieldRules) {
    rules[name] = fieldRules;
  }

  Map<String, String> validate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    rules.forEach((field, fieldRules) {
      final value = data[field];
      for (final rule in fieldRules) {
        final error = rule.validate(value);
        if (error.isNotEmpty) {
          errors[field] = error;
          break; // Stop at first error for this field
        }
      }
    });

    return errors;
  }
}

// Middleware for validation
MiddlewareHandler validate(Validator validator) {
  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    // Parse body if not already parsed
    if (req.formFields.isEmpty) {
      await req.parseBody();
    }

    // Convert formFields to Map<String, dynamic>
    final data = <String, dynamic>{};
    req.formFields.forEach((key, value) {
      data[key] = value;
    });

    final errors = validator.validate(data);

    if (errors.isNotEmpty) {
      throw RivetException(
        'Validation failed',
        statusCode: 400,
        details: errors,
      );
    }

    return next();
  };
}

// Sanitization helpers
class Sanitizer {
  static String stripTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  static String escape(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  static String trim(String input) {
    return input.trim();
  }
}
