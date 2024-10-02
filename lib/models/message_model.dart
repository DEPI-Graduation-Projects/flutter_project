class MessageModel {
  String id;
  String? message;
  final String senderId;
  final String time;
  String? imagaeUrl;
  bool type;
  MessageModel(
      {required this.message,
      required this.id,
      required this.time,
      required this.imagaeUrl,
      required this.type,
      required this.senderId});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'],
      message: json['message'],
      id: json['id'],
      time: json['time'],
      imagaeUrl: json['imagaeUrl'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'id': id,
      'senderId': senderId,
      'time': time,
      'imagaeUrl': imagaeUrl,
      'type': type,
    };
  }
}
