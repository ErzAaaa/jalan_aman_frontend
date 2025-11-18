class UserModel {
  final String username;
  final String role; // admin atau petugas
  final String? token; // untuk API authorization
  final String? namaLengkap; // nama lengkap user (opsional)

  UserModel({
    required this.username,
    required this.role,
    required this.token,
    this.namaLengkap,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      role: json['role'],
      token: json['token'],
      namaLengkap: json['namaLengkap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'token': token,
      'namaLengkap': namaLengkap,
    };
  }
}
