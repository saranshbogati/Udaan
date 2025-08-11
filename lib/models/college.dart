class College {
  final int id;
  final String name;
  final String? description;
  final String location;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String type; // 'college', 'high_school'
  final List<String> programs;
  final List<String> images;
  final double? averageRating;
  final int reviewCount;
  final DateTime? establishedYear;
  final String? affiliatedUniversity;

  College({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    this.address,
    this.phone,
    this.email,
    this.website,
    required this.type,
    required this.programs,
    required this.images,
    this.averageRating,
    required this.reviewCount,
    this.establishedYear,
    this.affiliatedUniversity,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      type: json['type'],
      programs: List<String>.from(json['programs'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      averageRating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      establishedYear: json['established_year'] != null
          ? DateTime.parse(json['established_year'])
          : null,
      affiliatedUniversity: json['affiliated_university'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'type': type,
      'programs': programs,
      'images': images,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'established_year': establishedYear?.toIso8601String(),
      'affiliated_university': affiliatedUniversity,
    };
  }
}
