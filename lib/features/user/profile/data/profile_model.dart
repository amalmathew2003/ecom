class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;

  ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',

      // ✅ THIS LINE FIXES THE CRASH
      phone: json['phone']?.toString() ?? '',
    );
  }

  ProfileModel copyWith({
    String? phone,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      phone: phone ?? this.phone,
    );
  }
}
