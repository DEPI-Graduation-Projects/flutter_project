class UserModel {
  final String name;
  final String userId;
  final bool status;
  final Map<String, dynamic> chatWallpapers;
  final String? profilePhoto;
  final List<dynamic> friends;
  final String email;
  final String password;
  final List<String> mutedUsers;

  UserModel(this.profilePhoto,
      {required this.friends,
      required this.name,
      required this.status,
      required this.userId,
      required this.chatWallpapers,
      required this.email,
      required this.password,
      List<String>? mutedUsers,
      }) : mutedUsers = mutedUsers ?? [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(json['profilePhoto'],
        friends: json['friends'],
        name: json['name'],
        status: json['status'],
        userId: json['userId'],
        chatWallpapers: json['chatWallpapers'] != null
            ? Map<String, dynamic>.from(json['chatWallpapers'])
            : {},
        email: json['email'],
        password: json['password'],
      mutedUsers: List<String>.from(json['mutedUsers'] ?? []),);
  }

  Map<String, dynamic> toMap() {
    return {
      'friends': friends,
      'name': name,
      'userId': userId,
      'status': status,
      'chatWallpapers': chatWallpapers,
      'profilePhoto': profilePhoto,
      'email': email,
      'password': password,
      'mutedUsers': mutedUsers,
    };
  }
}
