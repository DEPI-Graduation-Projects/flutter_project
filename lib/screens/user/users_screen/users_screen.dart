import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/models/user_model.dart';
import 'package:flutter_project/screens/chats/chat_screen/chat_screen.dart';

import '../../../models/chat_model.dart';

class UsersScreen extends StatefulWidget {
  UsersScreen({required this.message, required this.cubb, super.key});
  AppCubit cubb;
  String message;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String? selectedUserId;

  TextEditingController searchUserController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, right: 20, left: 20),
                child: DefaultTextField(
                    replyOn: false,
                    type: TextInputType.text,
                    label: 'Search user',
                    controller: searchUserController),
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: userItem(
                            cubb: widget.cubb, user: widget.cubb.users[index]));
                  },
                  itemCount: widget.cubb.users.length,
                ),
              ),
              const Spacer(),
              selectedUserId != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.amber.shade700, width: 2),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextButton.icon(
                          onPressed: () {
                            ChatModel? currentChat;
                            bool exists = false;
                            String chatId = "";
                            for (var chat in widget.cubb.chats) {
                              if (chat.usersIds.contains(selectedUserId)) {
                                exists = true;
                                currentChat = chat;
                                chatId = chat.chatId;
                              }
                            }
                            exists
                                ? widget.cubb
                                    .addMessage(
                                        replyMessageId: "",
                                        message: widget.message,
                                        userId: AppCubit.userId,
                                        chatId: chatId,
                                        type: false)
                                    .then((value) {
                                    widget.cubb.currentWallpaper =
                                        "https://th.bing.com/th/id/OIF.csGcQuy19CVl9ZrjLxBflw?rs=1&pid=ImgDetMain";
                                    if (widget.cubb.userAccount!.chatWallpapers
                                        .containsKey(currentChat!.chatId)) {
                                      widget.cubb.currentWallpaper = widget
                                          .cubb
                                          .userAccount!
                                          .chatWallpapers[currentChat.chatId];
                                      print(
                                          'chat current wallpaper ${widget.cubb.currentWallpaper}');
                                    }
                                    String userId = currentChat.usersIds
                                        .firstWhere((id) =>
                                            id !=
                                            widget.cubb.userAccount!.userId);
                                    widget.cubb
                                        .getUserData(userId, false)
                                        .then((value) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              cubb: widget.cubb,
                                              chat: currentChat!,
                                            ),
                                          ));
                                    });
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  })
                                : widget.cubb.createChat(
                                    usersNames: [
                                        'Mahmoud Wahba ',
                                        widget.cubb.users
                                            .firstWhere((user) =>
                                                user.userId == selectedUserId)
                                            .name
                                      ],
                                    userId: "22010237",
                                    receiverId: selectedUserId!,
                                    message: widget.message);
                          },
                          label: const Text(
                            "Send",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.send, color: Colors.amber.shade600),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget userItem({
    required UserModel user,
    required AppCubit cubb,
  }) {
    return GestureDetector(
      onTap: () {
        chooseUser(user.userId);
      },
      child: Card(
        color: selectedUserId == user.userId
            ? Colors.amber.shade900
            : Colors.white,
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(user.name),
          subtitle: Text(user.userId),
        ),
      ),
    );
  }

  void chooseUser(userId) {
    setState(() {
      selectedUserId =
          selectedUserId == userId ? null : selectedUserId = userId;
    });
  }
}
