import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/models/chat_model.dart';
import 'package:flutter_project/screens/chats/chat_screen/chat_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MyChasts extends StatefulWidget {
  const MyChasts({super.key});

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
    cubb.getMyChats(userId: "22010237");
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
                              userId: "22010237",
                              receiverId: addUserChatController.text,
                              message: messageController.text);
                        } else {
                          debugPrint("No Connection");
                        }
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      }));
              debugPrint('Add');
            }),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return ChatItem(
              state: state,
              index: index,
              chat: cubb.chats[index],
            );
          },
          itemCount: cubb.chats.length,
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final ChatModel chat;
  final int index;
  final state;
  const ChatItem(
      {required this.chat,
      required this.index,
      required this.state,
      super.key});

  @override
  Widget build(BuildContext context) {
    AppCubit cubb = AppCubit.get(context);
    return Dismissible(
      key: Key(chat.usersIds[1]),
      onDismissed: (direction) {
        // Show the SnackBar and allow undo action
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Text('${chat.usersIds[1]} dismissed'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Restore the chat when Undo is pressed
                        cubb.getMyChats(
                            userId:
                                "22010237"); // Fetch chats again or restore from temporary storage
                        ScaffoldMessenger.of(context)
                            .hideCurrentSnackBar(); // Dismiss the SnackBar
                        cubb.cancleDeletion =
                            true; // Mark that deletion has been canceled
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
          // After the SnackBar disappears, delete the chat unless it was restored
          if (await InternetConnectionChecker().hasConnection) {
            if (!cubb.cancleDeletion) {
              cubb.deleteChat(chatId: chat.chatId); // Delete chat from Firebase
            } else {
              cubb.cancleDeletion = false; // Reset the cancel flag
            }
          } else {
            debugPrint("No connection");
          }

          // Now that the SnackBar is closed, safely remove the item from the list
          cubb.tempDelete(index); // Remove the item from the list
        });
      },
      background: Container(
        color: Colors.red, // Color shown when swiped
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(Icons.delete, color: Colors.white)),
      ),
      direction: DismissDirection.endToStart,
      child: GestureDetector(
        onTap: () {
          String userId = chat.usersIds.firstWhere((id) => id != "22010237");
          cubb.getUserData(userId).then((value) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(cubb: cubb, chat: chat),
                ));
          });
        },
        child: Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.black,
              radius: 30,
            ),
            title: Text(
              chat.usersIds[1],
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
