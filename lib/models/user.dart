class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final bool isActive;
  final bool isVerified;
  final String? profilePicture;
  final DateTime createdAt;

  // Legacy support for old 'name' field
  String get name => fullName ?? username;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.isActive = true,
    this.isVerified = false,
    this.profilePicture,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      profilePicture: json['profile_picture'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
      'is_verified': isVerified,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    bool? isActive,
    bool? isVerified,
    String? profilePicture,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
