class ChatModel {
  final String chatId;
  final List<dynamic> usersIds;
  final String lastMessage;
  final List<dynamic> usersNames;
  final String lastMessageTime;
  ChatModel(
      {required this.lastMessageTime,
      required this.usersNames,
      required this.chatId,
      required this.usersIds,
      required this.lastMessage});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
        lastMessageTime: json['lastMessageTime'],
        usersNames: json['usersNames'],
        chatId: json['chatId'],
        usersIds: json['usersIds'],
        lastMessage: json['lastMessage']);
  }

  Map<String, dynamic> toMap() {
    return {
      'lastMessageTime': lastMessageTime,
      'usersNames': usersNames,
      'chatId': chatId,
      'usersIds': usersIds,
      'lastMessage': lastMessage,
    };
  }
}
