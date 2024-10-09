class UserModel {
  final String name;
  final String userId;
  final bool status;
  final Map<String, dynamic> chatWallpapers;
  final String? profilePhoto;

  UserModel(
    this.profilePhoto, {
    required this.name,
    required this.status,
    required this.userId,
    required this.chatWallpapers,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      json['profilePhoto'],
      name: json['name'],
      status: json['status'],
      userId: json['userId'],
      chatWallpapers: Map<String, dynamic>.from(json['chatWallpapers']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'status': status,
      'chatWallpapers': chatWallpapers,
      'profilePhoto': profilePhoto,
    };
  }
}
