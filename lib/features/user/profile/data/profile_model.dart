class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role;

  ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}
