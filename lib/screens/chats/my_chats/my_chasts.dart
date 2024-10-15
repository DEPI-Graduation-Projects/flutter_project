import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/Components/constants.dart';
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

  TextEditingController userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final AppCubit cubb = AppCubit.get(context);
    cubb.getMyChats(userId: Constants.userAccount.userId);
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
        backgroundColor: Colors.blueGrey.shade900,
        floatingActionButton: FloatingActionButton(
            backgroundColor: Constants.appPrimaryColor,
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => DialogBox(
                      controller1: addUserChatController,
                      controller2: messageController,
                      onSave: () async {
                        if (await InternetConnectionChecker().hasConnection) {
                          await cubb.getUserData2(addUserChatController.text);

                          // Check if user3 is fetched
                          if (cubb.user3 != null) {
                            String name = cubb.user3!.name;
                            print('my name is $name');

                            await cubb.createChat(
                                usersNames: [
                                  Constants.userAccount.name,
                                  cubb.user3!.name,
                                ],
                                userId: Constants.userAccount.userId,
                                receiverId: addUserChatController.text,
                                message: messageController.text);
                          } else {
                            print("User data not found");
                          }
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
              // cubb.getUserData(AppCubit.userId, true);
              // cubb.getMyChats(userId: AppCubit.userId);
            }),
        body: RefreshIndicator(
          onRefresh: () {
            cubb.getMyChats(userId: Constants.userAccount.userId);
            return Future(() => null);
          },
          child: state is GetChatsLoadingState
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    DefaultTextField(
                      type: TextInputType.name,
                      label: "search",
                      controller: userNameController,
                      onChanged: (value) {
                        cubb.filterList(value);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return ChatItem(
                            index: index,
                            chat: cubb.filteredChats[index],
                          );
                        },
                        itemCount: cubb.filteredChats.length,
                      ),
                    ),
                  ],
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

    String userName = chat.usersNames
        .firstWhere(((name) => name != Constants.userAccount.name));
    String userId =
        chat.usersIds.firstWhere((id) => id != Constants.userAccount.userId);

    return Dismissible(
      key: Key(chat.chatId),
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
                        // print('my userId is ${cubb.userAccount!.userId}');
                        // print('your userId is $userId');
                        // print('chatId is ${chat.chatId}');
                        // ScaffoldMessenger.of(context)
                        //     .hideCurrentSnackBar(); // Dismiss the SnackBar
                        cubb.delete = false;
                        cubb.getMyChats(userId: Constants.userAccount.userId);
                        print('chatId is ${chat.chatId}');
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
              print("iam deleting ");
              cubb.deleteChat(chatId: chat.chatId); // Delete chat from Firebase
            } else {
              print("not deleting");
              cubb.delete = true;
            }
          } else {
            //true
            debugPrint(" No connection");
          }
        });
        print("index is $index");
        cubb.tempDelete(index); // Remove the item from the list
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
          if (Constants.userAccount.chatWallpapers.containsKey(chat.chatId)) {
            cubb.currentWallpaper =
                Constants.userAccount.chatWallpapers[chat.chatId];
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
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
          color: Constants.appThirColor,
          child: ListTile(
            leading: const CircleAvatar(
              radius: 30,
              child: Icon(
                Icons.person,
                size: 40,
              ),
            ),
            title: Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat.lastMessage,
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis, fontSize: 15),
            ),
            trailing: Text(AppCubit.formatTime(chat.lastMessageTime)),
          ),
        ),
      ),
    );
  }
}
