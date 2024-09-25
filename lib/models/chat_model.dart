class ChatModel {
  final String chatId;
  final List<dynamic> usersIds;
  final String lastMessage;

  ChatModel(
      {required this.chatId,
      required this.usersIds,
      required this.lastMessage});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
        chatId: json['chatId'],
        usersIds: json['usersIds'],
        lastMessage: json['lastMessage']);
  }

  Map<String, dynamic> toMap() {
    return {'chatId': chatId, 'usersIds': usersIds, 'lastMessage': lastMessage};
  }
}
