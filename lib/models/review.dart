class Review {
  final int id;
  final int collegeId;
  final int userId;
  final String userName;
  final double rating;
  final String title;
  final String content;
  final String? program;
  final String? graduationYear;
  final List<String> images;
  final bool isVerified;
  final int likesCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.collegeId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.title,
    required this.content,
    this.program,
    this.graduationYear,
    this.images = const [],
    this.isVerified = false,
    this.likesCount = 0,
    this.isLikedByCurrentUser = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      collegeId: json['college_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      title: json['title'],
      content: json['content'],
      program: json['program'],
      graduationYear: json['graduation_year'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      isVerified: json['is_verified'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      isLikedByCurrentUser: json['is_liked_by_current_user'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'college_id': collegeId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'title': title,
      'content': content,
      'program': program,
      'graduation_year': graduationYear,
      'images': images,
      'is_verified': isVerified,
      'likes_count': likesCount,
      'is_liked_by_current_user': isLikedByCurrentUser,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // For creating a new review (without ID and metadata)
  Map<String, dynamic> toCreateJson() {
    return {
      'college_id': collegeId,
      'rating': rating,
      'title': title,
      'content': content,
      'program': program,
      'graduation_year': graduationYear,
      'images': images,
    };
  }

  Review copyWith({
    int? id,
    int? collegeId,
    int? userId,
    String? userName,
    double? rating,
    String? title,
    String? content,
    String? program,
    String? graduationYear,
    List<String>? images,
    bool? isVerified,
    int? likesCount,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      collegeId: collegeId ?? this.collegeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      program: program ?? this.program,
      graduationYear: graduationYear ?? this.graduationYear,
      images: images ?? this.images,
      isVerified: isVerified ?? this.isVerified,
      likesCount: likesCount ?? this.likesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get ratingText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Average';
    if (rating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  bool get hasImages => images.isNotEmpty;
  bool get hasProgram => program != null && program!.isNotEmpty;
  bool get hasGraduationYear =>
      graduationYear != null && graduationYear!.isNotEmpty;
}
