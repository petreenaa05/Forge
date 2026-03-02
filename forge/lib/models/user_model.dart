class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String role; // 'freelancer' | 'client'
  final double rating;
  final int totalRatings;
  final bool verified;
  final bool available;
  final List<String> skills; // category names
  final String location;
  final String bio;
  final int experience; // years
  final String? photoUrl;
  final int completedJobs;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.verified = false,
    this.available = true,
    this.skills = const [],
    this.location = '',
    this.bio = '',
    this.experience = 0,
    this.photoUrl,
    this.completedJobs = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'client',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: (map['totalRatings'] ?? 0) as int,
      verified: map['verified'] ?? false,
      available: map['available'] ?? true,
      skills: List<String>.from(map['skills'] ?? []),
      location: map['location'] ?? '',
      bio: map['bio'] ?? '',
      experience: (map['experience'] ?? 0) as int,
      photoUrl: map['photoUrl'],
      completedJobs: (map['completedJobs'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'rating': rating,
      'totalRatings': totalRatings,
      'verified': verified,
      'available': available,
      'skills': skills,
      'location': location,
      'bio': bio,
      'experience': experience,
      'photoUrl': photoUrl,
      'completedJobs': completedJobs,
    };
  }

  UserModel copyWith({
    String? name,
    String? role,
    double? rating,
    int? totalRatings,
    bool? verified,
    bool? available,
    List<String>? skills,
    String? location,
    String? bio,
    int? experience,
    String? photoUrl,
    int? completedJobs,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      verified: verified ?? this.verified,
      available: available ?? this.available,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      photoUrl: photoUrl ?? this.photoUrl,
      completedJobs: completedJobs ?? this.completedJobs,
    );
  }
}
