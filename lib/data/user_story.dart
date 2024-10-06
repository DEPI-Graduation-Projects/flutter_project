
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStory {
  final String id;
  final String userId;
  final String imgURL;
  final DateTime timeStamp;

  UserStory({required this.id, required this.userId, required this.timeStamp, required this.imgURL});

  factory UserStory.fromMap(Map<String, dynamic> data, String documentId) {
    return UserStory(
      id: documentId,
      userId: data['userId'] ?? '',
      imgURL: data['imgURL'] ?? '',
      timeStamp: (data['timeStamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }}

