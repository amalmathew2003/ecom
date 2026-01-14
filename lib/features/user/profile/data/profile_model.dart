class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final String address;

  ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.address,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role'] ?? 'user',
      address: json['address'] ?? '',
    );
  }

  ProfileModel copyWith({
    String? phone,
    String? address,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone ?? this.phone,
      role: role,
      address: address ?? this.address,
    );
  }
}
