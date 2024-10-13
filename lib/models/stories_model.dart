
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStory {
  final String id;
  final String userId;
  final String imgURL;
  final DateTime timeStamp;
  final List<String> seenBy;

  UserStory({required this.id, required this.userId, required this.timeStamp, required this.imgURL, required this.seenBy});

  factory UserStory.fromMap(Map<String, dynamic> data, String documentId) {
    return UserStory(
      id: documentId,
      userId: data['userId'] ?? '',
      imgURL: data['imgURL'] ?? '',
      timeStamp: _parseTimestamp(data['timeStamp']),
      seenBy: List<String>.from(data['seenBy'] ?? [])
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else {
      print("Unexpected timestamp type: ${timestamp.runtimeType}");
      return DateTime.now();
    }
  }

  bool isSeenBy(String userId) {
    return seenBy.contains(userId);
  }

}

