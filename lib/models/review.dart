class Review {
  final int id;
  final int collegeId;
  final int userId;
  final String userName;
  final String? userProfileImage;
  final double rating;
  final String title;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? program; // Which program they studied
  final String? graduationYear;
  final Map<String, double>? categoryRatings; // academics, facilities, etc.
  final bool isVerified;
  final int likesCount;
  final bool isLikedByCurrentUser;

  Review({
    required this.id,
    required this.collegeId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.rating,
    required this.title,
    required this.content,
    required this.images,
    required this.createdAt,
    this.updatedAt,
    this.program,
    this.graduationYear,
    this.categoryRatings,
    required this.isVerified,
    required this.likesCount,
    required this.isLikedByCurrentUser,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      collegeId: json['college_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userProfileImage: json['user_profile_image'],
      rating: json['rating'].toDouble(),
      title: json['title'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      program: json['program'],
      graduationYear: json['graduation_year'],
      categoryRatings: json['category_ratings'] != null
          ? Map<String, double>.from(json['category_ratings'])
          : null,
      isVerified: json['is_verified'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      isLikedByCurrentUser: json['is_liked_by_current_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'college_id': collegeId,
      'user_id': userId,
      'user_name': userName,
      'user_profile_image': userProfileImage,
      'rating': rating,
      'title': title,
      'content': content,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'program': program,
      'graduation_year': graduationYear,
      'category_ratings': categoryRatings,
      'is_verified': isVerified,
      'likes_count': likesCount,
      'is_liked_by_current_user': isLikedByCurrentUser,
    };
  }
}
