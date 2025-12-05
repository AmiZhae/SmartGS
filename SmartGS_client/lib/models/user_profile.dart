class UserProfile {
  final String username;
  final String email;
  final String phone;

  UserProfile({
    required this.username,
    required this.email,
    required this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'phone': phone};
  }
}
