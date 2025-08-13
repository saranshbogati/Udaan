class SavedCollege {
  final int id;
  final int userId;
  final int collegeId;
  final String collegeName;
  final String? collegeLocation;
  final String? collegeLogoUrl;
  final double collegeAverageRating;
  final int collegeTotalReviews;
  final DateTime savedAt;

  SavedCollege({
    required this.id,
    required this.userId,
    required this.collegeId,
    required this.collegeName,
    this.collegeLocation,
    this.collegeLogoUrl,
    required this.collegeAverageRating,
    required this.collegeTotalReviews,
    required this.savedAt,
  });

  factory SavedCollege.fromJson(Map<String, dynamic> json) {
    return SavedCollege(
      id: json['id'],
      userId: json['user_id'],
      collegeId: json['college_id'],
      collegeName: json['college_name'],
      collegeLocation: json['college_location'],
      collegeLogoUrl: json['college_logo_url'],
      collegeAverageRating: (json['college_average_rating'] ?? 0.0).toDouble(),
      collegeTotalReviews: json['college_total_reviews'] ?? 0,
      savedAt: json['saved_at'] != null
          ? DateTime.parse(json['saved_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'college_id': collegeId,
      'college_name': collegeName,
      'college_location': collegeLocation,
      'college_logo_url': collegeLogoUrl,
      'college_average_rating': collegeAverageRating,
      'college_total_reviews': collegeTotalReviews,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  // Helper method for display
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(savedAt);

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
    if (collegeAverageRating >= 4.5) return 'Excellent';
    if (collegeAverageRating >= 4.0) return 'Very Good';
    if (collegeAverageRating >= 3.5) return 'Good';
    if (collegeAverageRating >= 3.0) return 'Average';
    if (collegeAverageRating >= 2.0) return 'Below Average';
    return 'Poor';
  }
}

class SavedCollegeListResponse {
  final List<SavedCollege> savedColleges;
  final int total;
  final int page;
  final int pages;

  SavedCollegeListResponse({
    required this.savedColleges,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory SavedCollegeListResponse.fromJson(Map<String, dynamic> json) {
    return SavedCollegeListResponse(
      savedColleges: (json['saved_colleges'] as List)
          .map((savedCollegeJson) => SavedCollege.fromJson(savedCollegeJson))
          .toList(),
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saved_colleges': savedColleges.map((savedCollege) => savedCollege.toJson()).toList(),
      'total': total,
      'page': page,
      'pages': pages,
    };
  }
}