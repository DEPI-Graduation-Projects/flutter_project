class MessageModel {
  String id;
  String? message;
  final String senderId;
  final String time;
  String? imagaeUrl;
  bool type;
  bool isSelected = false;
  final bool isSeen;
  final String replyMessage;
  final String replyMessageId;
  MessageModel(
      {this.replyMessage = "",
      required this.message,
      required this.id,
      required this.time,
      required this.imagaeUrl,
      required this.type,
      required this.senderId,
      required this.isSeen,
      this.replyMessageId = ""});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      replyMessage: json['replyMessage'] ?? "",
      senderId: json['senderId'],
      message: json['message'],
      id: json['id'],
      time: json['time'],
      imagaeUrl: json['imagaeUrl'],
      type: json['type'],
      isSeen: json['isSeen'],
      replyMessageId: json['replyMessageId'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'replyMessage': replyMessage,
      'message': message,
      'id': id,
      'senderId': senderId,
      'time': time,
      'imagaeUrl': imagaeUrl,
      'type': type,
      'isSeen': isSeen,
      'replyMessageId': replyMessageId
    };
  }
}
