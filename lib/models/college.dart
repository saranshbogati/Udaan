class College {
  final int id;
  final String name;
  final String location;
  final String? city;
  final String? state;
  final String country;
  final String? website;
  final String? phone;
  final String? email;
  final int? establishedYear;
  final String? collegeType;
  final String? affiliation;
  final String? description;
  final String? logoUrl;
  final List<String> images;
  final List<String> programs;
  final List<String> facilities;
  final double averageRating;
  final int totalReviews;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  College({
    required this.id,
    required this.name,
    required this.location,
    this.city,
    this.state,
    this.country = 'Nepal',
    this.website,
    this.phone,
    this.email,
    this.establishedYear,
    this.collegeType,
    this.affiliation,
    this.description,
    this.logoUrl,
    this.images = const [],
    this.programs = const [],
    this.facilities = const [],
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      city: json['city'],
      state: json['state'],
      country: json['country'] ?? 'Nepal',
      website: json['website'],
      phone: json['phone'],
      email: json['email'],
      establishedYear: json['established_year'],
      collegeType: json['college_type'],
      affiliation: json['affiliation'],
      description: json['description'],
      logoUrl: json['logo_url'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      programs:
          json['programs'] != null ? List<String>.from(json['programs']) : [],
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : [],
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      metadata: json['metadata'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
      'website': website,
      'phone': phone,
      'email': email,
      'established_year': establishedYear,
      'college_type': collegeType,
      'affiliation': affiliation,
      'description': description,
      'logo_url': logoUrl,
      'images': images,
      'programs': programs,
      'facilities': facilities,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  College copyWith({
    int? id,
    String? name,
    String? location,
    String? city,
    String? state,
    String? country,
    String? website,
    String? phone,
    String? email,
    int? establishedYear,
    String? collegeType,
    String? affiliation,
    String? description,
    String? logoUrl,
    List<String>? images,
    List<String>? programs,
    List<String>? facilities,
    double? averageRating,
    int? totalReviews,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return College(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      establishedYear: establishedYear ?? this.establishedYear,
      collegeType: collegeType ?? this.collegeType,
      affiliation: affiliation ?? this.affiliation,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      images: images ?? this.images,
      programs: programs ?? this.programs,
      facilities: facilities ?? this.facilities,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getters
  String get fullLocation {
    final parts = <String>[];
    if (location.isNotEmpty) parts.add(location);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    return parts.join(', ');
  }

  bool get hasWebsite => website != null && website!.isNotEmpty;
  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
}
