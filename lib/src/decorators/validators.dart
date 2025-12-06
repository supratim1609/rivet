/// Validators for request validation
library;

import '../http/request.dart';

/// Base validator interface
abstract class Validator {
  String? validate(RivetRequest req);
}

/// Validator implementation for Required
class RequiredValidator implements Validator {
  final String field;
  final String? message;

  const RequiredValidator(this.field, {this.message});

  @override
  String? validate(RivetRequest req) {
    final value = req.jsonBody?[field];
    if (value == null || value.toString().trim().isEmpty) {
      return message ?? '$field is required';
    }
    return null;
  }
}

/// Validator implementation for Email
class EmailValidator implements Validator {
  final String field;
  final String? message;

  const EmailValidator(this.field, {this.message});

  @override
  String? validate(RivetRequest req) {
    final value = req.jsonBody?[field];
    if (value == null) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.toString())) {
      return message ?? '$field must be a valid email';
    }
    return null;
  }
}

/// Validator implementation for MinLength
class MinLengthValidator implements Validator {
  final String field;
  final int length;
  final String? message;

  const MinLengthValidator(this.field, this.length, {this.message});

  @override
  String? validate(RivetRequest req) {
    final value = req.jsonBody?[field];
    if (value == null) return null;

    if (value.toString().length < length) {
      return message ?? '$field must be at least $length characters';
    }
    return null;
  }
}

/// Validator implementation for MaxLength
class MaxLengthValidator implements Validator {
  final String field;
  final int length;
  final String? message;

  const MaxLengthValidator(this.field, this.length, {this.message});

  @override
  String? validate(RivetRequest req) {
    final value = req.jsonBody?[field];
    if (value == null) return null;

    if (value.toString().length > length) {
      return message ?? '$field must be at most $length characters';
    }
    return null;
  }
}

/// Validator implementation for Min
class MinValidator implements Validator {
  final String field;
  final num value;
  final String? message;

  const MinValidator(this.field, this.value, {this.message});

  @override
  String? validate(RivetRequest req) {
    final fieldValue = req.jsonBody?[field];
    if (fieldValue == null) return null;

    final numValue = num.tryParse(fieldValue.toString());
    if (numValue == null) {
      return '$field must be a number';
    }

    if (numValue < value) {
      return message ?? '$field must be at least $value';
    }
    return null;
  }
}

/// Validator implementation for Max
class MaxValidator implements Validator {
  final String field;
  final num value;
  final String? message;

  const MaxValidator(this.field, this.value, {this.message});

  @override
  String? validate(RivetRequest req) {
    final fieldValue = req.jsonBody?[field];
    if (fieldValue == null) return null;

    final numValue = num.tryParse(fieldValue.toString());
    if (numValue == null) {
      return '$field must be a number';
    }

    if (numValue > value) {
      return message ?? '$field must be at most $value';
    }
    return null;
  }
}
