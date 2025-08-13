import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/college.dart';
import '../models/review.dart';

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

  static String? globalAuthToken;

  String? _authToken;

  ApiService() {
    // Initialize from global token if available
    _authToken = globalAuthToken;
  }

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    globalAuthToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    globalAuthToken = null;
  }

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final tokenToUse = _authToken ?? globalAuthToken;
    if (tokenToUse != null) {
      headers['Authorization'] = 'Bearer $tokenToUse';
    }

    return headers;
  }

  // Generic error handling
  ApiResult<T> _handleError<T>(dynamic error) {
    print('API Error: $error');
    if (error is SocketException) {
      return ApiResult<T>.error('No internet connection');
    } else if (error is HttpException) {
      return ApiResult<T>.error('Server error');
    } else {
      return ApiResult<T>.error('Something went wrong');
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
      final response = await http.get(uri, headers: _headers);

      final result = _handleResponse(response);
      if (result.isSuccess) {
        return ApiResult<CollegeListResponse>.success(
          CollegeListResponse.fromJson(result.data!),
        );
      } else {
        return ApiResult<CollegeListResponse>.error(result.error!);
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

      final result = _handleResponse(response);
      if (result.isSuccess) {
        return ApiResult<College>.success(College.fromJson(result.data!));
      } else {
        return ApiResult<College>.error(result.error!);
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

      final result = _handleResponse(response);
      if (result.isSuccess) {
        return ApiResult<College>.success(College.fromJson(result.data!));
      } else {
        return ApiResult<College>.error(result.error!);
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

      final result = _handleResponse(response);
      if (result.isSuccess) {
        return ApiResult<ReviewListResponse>.success(
          ReviewListResponse.fromJson(result.data!),
        );
      } else {
        return ApiResult<ReviewListResponse>.error(result.error!);
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

      final result = _handleResponse(response);
      if (result.isSuccess) {
        return ApiResult<Review>.success(Review.fromJson(result.data!));
      } else {
        return ApiResult<Review>.error(result.error!);
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

      final result = _handleResponse(response);
      if (result.isSuccess) {
        return ApiResult<ReviewLikeResponse>.success(
          ReviewLikeResponse.fromJson(result.data!),
        );
      } else {
        return ApiResult<ReviewLikeResponse>.error(result.error!);
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

  ApiResult._({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  factory ApiResult.error(String error) {
    return ApiResult._(error: error, isSuccess: false);
  }
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
