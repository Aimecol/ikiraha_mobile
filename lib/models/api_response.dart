// API Response Models for Ikiraha Mobile Backend Integration

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;
  final String? timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'timestamp': timestamp,
    };
  }
}

class User {
  final int id;
  final String uuid;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? profileImage;
  final String roleName;
  final bool isActive;
  final bool isVerified;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final String? lastLoginAt;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.uuid,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.profileImage,
    required this.roleName,
    required this.isActive,
    required this.isVerified,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      profileImage: json['profile_image'],
      roleName: json['role_name'] ?? 'customer',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      emailVerifiedAt: json['email_verified_at'],
      phoneVerifiedAt: json['phone_verified_at'],
      lastLoginAt: json['last_login_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'profile_image': profileImage,
      'role_name': roleName,
      'is_active': isActive,
      'is_verified': isVerified,
      'email_verified_at': emailVerifiedAt,
      'phone_verified_at': phoneVerifiedAt,
      'last_login_at': lastLoginAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fullName => '$firstName $lastName';
}

class AuthData {
  final User user;
  final String token;
  final int expiresIn;

  AuthData({
    required this.user,
    required this.token,
    required this.expiresIn,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user']),
      token: json['token'] ?? '',
      expiresIn: json['expires_in'] ?? 86400,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'expires_in': expiresIn,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    };
  }
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String? dateOfBirth;
  final String? gender;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.dateOfBirth,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
    if (gender != null) data['gender'] = gender;
    return data;
  }
}

// Exception classes for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() {
    return 'ApiException: $message';
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  @override
  String toString() {
    return 'AuthenticationException: $message';
  }
}
