class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final DateTime? createdAt;
  final String? collegeName;
  final String? graduationYear;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.createdAt,
    this.collegeName,
    this.graduationYear,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      collegeName: json['college_name'],
      graduationYear: json['graduation_year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
      'college_name': collegeName,
      'graduation_year': graduationYear,
    };
  }
}
