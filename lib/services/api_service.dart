import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/college.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/saved_college.dart';

class ApiService {
  // Change this to your backend URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }
  // static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  // static const String baseUrl = 'https://your-backend-url.com'; // For production

  String? _authToken;

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Generic error handling
  ApiResult<T> _handleError<T>(dynamic error) {
    print('API Error: $error');
    if (error is SocketException) {
      return ApiResult.error('Network error. Please check your connection.');
    } else if (error is FormatException) {
      return ApiResult.error('Invalid response format.');
    } else if (error is http.ClientException) {
      return ApiResult.error('Connection failed.');
    } else {
      return ApiResult.error('An unexpected error occurred: $error');
    }
  }

  // Generic HTTP response handler
  ApiResult<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResult<Map<String, dynamic>>.success(data);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Request failed';
        return ApiResult<Map<String, dynamic>>.error(errorMessage);
      }
    } catch (e) {
      return ApiResult<Map<String, dynamic>>.error('Failed to parse response');
    }
  }

  // Profile endpoints
  Future<ApiResult<UserStats>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(UserStats.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to get user stats');
      }
    } catch (e) {
      return _handleError<UserStats>(e);
    }
  }

  Future<ApiResult<User>> updateProfile({
    String? fullName,
    String? email,
    String? profilePicture,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['full_name'] = fullName;
      if (email != null) updateData['email'] = email;
      if (profilePicture != null) updateData['profile_picture'] = profilePicture;

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: _headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(User.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to update profile');
      }
    } catch (e) {
      return _handleError<User>(e);
    }
  }

  Future<ApiResult<ReviewListResponse>> getUserReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/reviews?page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(ReviewListResponse.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to get user reviews');
      }
    } catch (e) {
      return _handleError<ReviewListResponse>(e);
    }
  }

  Future<ApiResult<ReviewListResponse>> getLikedReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/liked-reviews?page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(ReviewListResponse.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to get liked reviews');
      }
    } catch (e) {
      return _handleError<ReviewListResponse>(e);
    }
  }

  Future<ApiResult<SavedCollegeListResponse>> getSavedColleges({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/saved-colleges?page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(SavedCollegeListResponse.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to get saved colleges');
      }
    } catch (e) {
      return _handleError<SavedCollegeListResponse>(e);
    }
  }

  // College bookmark endpoints
  Future<ApiResult<Map<String, dynamic>>> toggleCollegeBookmark(int collegeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/colleges/$collegeId/bookmark'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(data);
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to toggle bookmark');
      }
    } catch (e) {
      return _handleError<Map<String, dynamic>>(e);
    }
  }

  // Review CRUD endpoints
  Future<ApiResult<Review>> updateReview(int reviewId, Review review) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: _headers,
        body: json.encode(review.toUpdateJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(Review.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to update review');
      }
    } catch (e) {
      return _handleError<Review>(e);
    }
  }

  Future<ApiResult<String>> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(data['message'] ?? 'Review deleted successfully');
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to delete review');
      }
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  // COLLEGE ENDPOINTS

  // Get colleges with optional filters
  Future<ApiResult<CollegeListResponse>> getColleges({
    int page = 1,
    int limit = 10,
    String? search,
    String? city,
    String? state,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (state != null && state.isNotEmpty) {
        queryParams['state'] = state;
      }

      final uri =
          Uri.parse('$baseUrl/colleges').replace(queryParameters: queryParams);
      print('Making request to: $uri');

      final response = await http.get(uri, headers: _headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(CollegeListResponse.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to fetch colleges');
      }
    } catch (e) {
      return _handleError<CollegeListResponse>(e);
    }
  }

  // Get college by ID
  Future<ApiResult<College>> getCollege(int collegeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/colleges/$collegeId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(College.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'College not found');
      }
    } catch (e) {
      return _handleError<College>(e);
    }
  }

  // Create college (requires authentication)
  Future<ApiResult<College>> createCollege(College college) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/colleges'),
        headers: _headers,
        body: json.encode(college.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(College.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to create college');
      }
    } catch (e) {
      return _handleError<College>(e);
    }
  }

  // REVIEW ENDPOINTS

  // Get reviews for a college
  Future<ApiResult<ReviewListResponse>> getCollegeReviews(
    int collegeId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/colleges/$collegeId/reviews')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(ReviewListResponse.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to fetch reviews');
      }
    } catch (e) {
      return _handleError<ReviewListResponse>(e);
    }
  }

  // Create review (requires authentication)
  Future<ApiResult<Review>> createReview(Review review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: _headers,
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(Review.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to create review');
      }
    } catch (e) {
      return _handleError<Review>(e);
    }
  }

  // Like/unlike review (requires authentication)
  Future<ApiResult<ReviewLikeResponse>> toggleReviewLike(int reviewId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/$reviewId/like'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.success(ReviewLikeResponse.fromJson(data));
      } else {
        final error = json.decode(response.body);
        return ApiResult.error(error['detail'] ?? 'Failed to toggle like');
      }
    } catch (e) {
      return _handleError<ReviewLikeResponse>(e);
    }
  }

  // SEARCH ENDPOINTS

  // Search colleges and reviews
  Future<ApiResult<CollegeListResponse>> searchColleges(String query) async {
    return getColleges(search: query, limit: 20);
  }
}

// Generic API result wrapper
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResult.error(this.error)
      : data = null,
        isSuccess = false;
}

// Response models for lists
class CollegeListResponse {
  final List<College> colleges;
  final int total;
  final int page;
  final int pages;

  CollegeListResponse({
    required this.colleges,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory CollegeListResponse.fromJson(Map<String, dynamic> json) {
    return CollegeListResponse(
      colleges: (json['colleges'] as List)
          .map((college) => College.fromJson(college))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

class ReviewListResponse {
  final List<Review> reviews;
  final int total;
  final int page;
  final int pages;

  ReviewListResponse({
    required this.reviews,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) {
    return ReviewListResponse(
      reviews: (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

class ReviewLikeResponse {
  final bool liked;
  final int likesCount;

  ReviewLikeResponse({
    required this.liked,
    required this.likesCount,
  });

  factory ReviewLikeResponse.fromJson(Map<String, dynamic> json) {
    return ReviewLikeResponse(
      liked: json['liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
    );
  }
}
