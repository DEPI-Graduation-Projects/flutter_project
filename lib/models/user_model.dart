class UserModel {
  final String name;
  final String userId;
  final bool status;

  UserModel({required this.name, required this.status, required this.userId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        name: json['name'], status: json['status'], userId: json['userId']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'status': status,
    };
  }
}
