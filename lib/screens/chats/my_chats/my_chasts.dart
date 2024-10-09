import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/models/chat_model.dart';
import 'package:flutter_project/screens/chats/chat_screen/chat_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MyChasts extends StatefulWidget {
  MyChasts({required this.userId, super.key});
  String userId;

  @override
  State<MyChasts> createState() => _MyChastsState();
}

class _MyChastsState extends State<MyChasts> {
  // List chats = [
  TextEditingController addUserChatController = TextEditingController();

  TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final AppCubit cubb = AppCubit.get(context);
    cubb.getUserData(widget.userId, true);
    cubb.getMyChats(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final AppCubit cubb = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is CreateChatLoadingState) {
          Navigator.pop(context);

          LoadingAlert.showLoadingDialogUntilState(
              context: context, cubit: cubb, targetState: state);
        } else if (state is CreateChatFailState) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Chat creation failed")));
        } else if (state is CreateChatSuccessState) {
          Navigator.pop(context);
          addUserChatController.clear();
          messageController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Chat creation Success")));
        }
      },
      builder: (context, state) => Scaffold(
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => DialogBox(
                      controller1: addUserChatController,
                      controller2: messageController,
                      onSave: () async {
                        if (await InternetConnectionChecker().hasConnection) {
                          cubb.createChat(
                              userId: AppCubit.userId,
                              receiverId: addUserChatController.text,
                              message: messageController.text);
                        } else {
                          debugPrint("No Connection");
                        }
                      },
                      onCancel: () {
                        addUserChatController.clear();
                        messageController.clear();
                        Navigator.pop(context);
                      }));
              debugPrint('Add');
              print(widget.userId);
              // cubb.getUserData(AppCubit.userId, true);
              // cubb.getMyChats(userId: AppCubit.userId);
            }),
        body: RefreshIndicator(
          onRefresh: () {
            print(widget.userId);
            cubb.getUserData(AppCubit.userId, true);
            cubb.getMyChats(userId: AppCubit.userId);
            return Future(() => null);
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ChatItem(
                index: index,
                chat: cubb.chats[index],
              );
            },
            itemCount: cubb.chats.length,
          ),
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final ChatModel chat;
  final int index;
  const ChatItem({required this.chat, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    AppCubit cubb = AppCubit.get(context);
    String userId = chat.usersIds.firstWhere((id) => id != AppCubit.userId);
    return Dismissible(
      key: Key(chat.usersIds[1]),
      onDismissed: (direction) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Text('${chat.usersIds[1]} dismissed'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        cubb.getMyChats(userId: AppCubit.userId);
                        ScaffoldMessenger.of(context)
                            .hideCurrentSnackBar(); // Dismiss the SnackBar
                        cubb.delete =
                            false; // Mark that delete has been canceled
                        print('Hager After Undo ${cubb.delete}');
                      },
                      child: const Text("Undo"),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 5), // SnackBar duration
              ),
            )
            .closed
            .then((reason) async {
          if (await InternetConnectionChecker().hasConnection) {
            if (cubb.delete) {
              cubb.deleteChat(chatId: chat.chatId); // Delete chat from Firebase
            } else {
              cubb.delete = true; // Reset the cancel flag
            }
          } else {
            //true
            debugPrint(" No connection");
          }

          print('Hager cancle deletion default value is ${cubb.delete}');

          cubb.tempDelete(index); // Remove the item from the list
        });
      },
      background: Container(
        color: Colors.red, // Color shown when swiped
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(Icons.delete, color: Colors.white)),
      ),
      direction: DismissDirection.endToStart,
      child: GestureDetector(
        onTap: () {
          cubb.currentWallpaper =
              "https://th.bing.com/th/id/OIF.csGcQuy19CVl9ZrjLxBflw?rs=1&pid=ImgDetMain";
          if (cubb.currentUser2!.chatWallpapers.containsKey(chat.chatId)) {
            cubb.currentWallpaper =
                cubb.currentUser2!.chatWallpapers[chat.chatId];
          }

          cubb.getUserData(userId, false).then((value) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    cubb: cubb,
                    chat: chat,
                  ),
                ));
          });
        },
        child: Card(
          child: ListTile(
            leading: const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
            title: Text(
              userId,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat.lastMessage,
              style: const TextStyle(
                  color: Colors.grey,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}