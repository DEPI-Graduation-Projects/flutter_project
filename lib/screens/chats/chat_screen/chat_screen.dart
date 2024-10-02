// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/models/chat_model.dart';
import 'package:flutter_project/models/message_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;
  final AppCubit cubb;
  const ChatScreen({
    required this.chat,
    required this.cubb,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController chatController = TextEditingController();
  int messagesIndex = -1;
  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd', 'en').format(dateTime);
  }

  String formatTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat(
      'hh:mm a',
    ).format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en', null).then((_) {
      // Your date formatting code will work fine now.
    });
    widget.cubb.getChat(userId: widget.cubb.userId, chatId: widget.chat.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is DeleteMessageSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Message Deleted Successfully")));
          Navigator.pop(context);
        }
        if (state is CopyTextSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Message Copied to ClipBoard")));
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 28,
                            // color: Components.setTextColor(cubb.isDarkMode),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              Positioned(
                                  right: 6,
                                  bottom: 8,
                                  child: widget.cubb.currentUser != null
                                      ? CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.amber,
                                          child: CircleAvatar(
                                            radius: 7,
                                            backgroundColor:
                                                widget.cubb.currentUser!.status
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        )
                                      : const SizedBox())
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        state is GetUserDataLoadingState
                            ? const Text(
                                "Loading...",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            : Column(
                                children: [
                                  Text(
                                    widget.cubb.currentUser != null
                                        ? widget.cubb.currentUser!.name
                                        : "Loading...",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(widget.cubb.currentUser != null
                                        ? widget.cubb.currentUser!.status
                                            ? "online"
                                            : "offline"
                                        : ""),
                                  )
                                ],
                              ),
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                widget.cubb
                                    .changeUserId(widget.cubb.isMe, context);
                                widget.cubb.isMe = !(widget.cubb.isMe);
                              });
                            },
                            child: const Text("Swap"))
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount:
                          _groupMessagesByDate(widget.cubb.messages).length,
                      itemBuilder: (context, index) {
                        final dateGroup =
                            _groupMessagesByDate(widget.cubb.messages)[index];
                        final messages =
                            dateGroup['messages'] as List<MessageModel>;
                        final date = dateGroup['date'] as String;

                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: Text(
                                  date,
                                ),
                              ),
                            ),
                            ...messages.map((message) {
                              return _buildMessage(
                                  message: message,
                                  context: context,
                                  isDarkMode: false,
                                  cubb: widget.cubb,
                                  chatId: widget.chat.chatId,
                                  isMe: message.senderId == "22010237");
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: bottomBar(widget.cubb, widget.cubb.userId, state))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget bottomBar(AppCubit cubb, userId, state) {
    return Row(
      children: [
        Expanded(
          child: state is PickImageState
              ? Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          FullScreenImageViewer.showFullImage2(
                              context, cubb.img);
                        },
                        child: SizedBox(
                          width: 55,
                          height: 55,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              cubb.img!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      TextButton(
                        onPressed: () {
                          cubb.swap();
                        },
                        child: const Text(
                          "cancle",
                        ),
                      )
                    ],
                  ),
                )
              : DefaultTextField(
                  height: 8,
                  type: TextInputType.text,
                  onChanged: (value) {},
                  label: "Enter a message",
                  controller: chatController,
                  errStr: "please Enter a message",
                  maxLines: 2,
                ),
        ),
        const SizedBox(width: 8),
        state is UploadChatImageLoadingState
            ? const CircularProgressIndicator()
            : IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  size: 32,
                ),
                onPressed: () async {
                  if (chatController.text.isNotEmpty || cubb.img != null) {
                    String imageUrl = "";
                    if (cubb.img != null) {
                      imageUrl = await cubb.uploadChatimage(file: cubb.img);
                    }
                    await cubb.addMessage(
                        chatId: widget.chat.chatId,
                        userId: userId,
                        type: imageUrl.isNotEmpty,
                        imagaeUrl: imageUrl,
                        message: chatController.text);
                  }
                  chatController.clear();
                  cubb.img = null;
                  cubb.changeSendIcon('');
                },
              ),
        IconButton(
          icon: const Icon(
            Icons.add_photo_alternate_rounded,
            size: 32.0,
          ),
          onPressed: () {
            cubb.pickChatImage(ImageSource.gallery);
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _groupMessagesByDate(List<MessageModel> messages) {
    Map<String, List<MessageModel>> groupedMessages = {};

    for (var message in messages) {
      String formattedDate = formatDate(message.time);
      if (groupedMessages.containsKey(formattedDate)) {
        groupedMessages[formattedDate]!.add(message);
      } else {
        groupedMessages[formattedDate] = [message];
      }
    }

    List<Map<String, dynamic>> groupedMessagesList =
        groupedMessages.entries.map((entry) {
      // Sort messages within each date group in descending order by time
      entry.value.sort(
          (a, b) => DateTime.parse(a.time).compareTo(DateTime.parse(b.time)));
      return {'date': entry.key, 'messages': entry.value};
    }).toList();

    // Sort the grouped messages in descending order by date
    groupedMessagesList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });
    print(groupedMessagesList);
    return groupedMessagesList;
  }

  // Widget _buildOtherMessage(
  //   MessageModel message,
  //   context,
  //   bool isDarkMode,
  // ) {
  //   String formattedTime = formatTime(message.time);

  //   return Align(
  //     alignment: AlignmentDirectional.centerStart,
  //     child: Padding(
  //       padding: const EdgeInsets.all(10.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             decoration: const BoxDecoration(
  //               borderRadius: BorderRadiusDirectional.only(
  //                 topStart: Radius.circular(16.0),
  //                 topEnd: Radius.circular(16.0),
  //                 bottomEnd: Radius.circular(16.0),
  //               ),
  //             ),
  //             child: message.type
  //                 ? Padding(
  //                     padding: const EdgeInsets.all(7.0),
  //                     child: InkWell(
  //                       onTap: () {
  //                         FullScreenImageViewer.showFullImage(
  //                             context, message.imagaeUrl);
  //                       },
  //                       child: ClipRRect(
  //                         borderRadius: const BorderRadiusDirectional.only(
  //                           topStart: Radius.circular(16.0),
  //                           topEnd: Radius.circular(16.0),
  //                           bottomEnd: Radius.circular(16.0),
  //                         ),
  //                         child: CachedNetworkImage(
  //                           imageUrl: message.imagaeUrl!,
  //                           height: 200,
  //                           width: 200,
  //                           fit: BoxFit.cover,
  //                           placeholder: (context, url) => const Center(
  //                               child: CircularProgressIndicator()),
  //                           errorWidget: (context, url, error) =>
  //                               const Icon(Icons.error),
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //                 : Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 8,
  //                       vertical: 8,
  //                     ),
  //                     child: Text(
  //                       message.message!,
  //                     ),
  //                   ),
  //           ),
  //           Text(
  //             formattedTime,
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMessage(
      {required MessageModel message,
      required context,
      required bool isDarkMode,
      required bool isMe,
      required chatId,
      required AppCubit cubb}) {
    String formattedTime = formatTime(message.time);

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  cubb.deleteChatMessage(
                                      chatId: chatId, messageId: message.id);
                                },
                                label: const Text("Delete"),
                                icon: const Icon(Icons.delete),
                              ),
                              !message.type
                                  ? TextButton.icon(
                                      onPressed: () {
                                        cubb.copyToClipboard(message.message!);
                                      },
                                      label: const Text("Copy"),
                                      icon: const Icon(Icons.copy),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ));
              },
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(16.0),
                    topEnd: Radius.circular(16.0),
                    bottomStart: Radius.circular(16.0),
                  ),
                ),
                child: message.type
                    ? Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: InkWell(
                          onTap: () => FullScreenImageViewer.showFullImage(
                              context, message.imagaeUrl),
                          child: ClipRRect(
                            borderRadius: const BorderRadiusDirectional.only(
                              topStart: Radius.circular(16.0),
                              topEnd: Radius.circular(16.0),
                              bottomStart: Radius.circular(16.0),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: message.imagaeUrl!,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Text(
                          message.message!,
                        ),
                      ),
              ),
            ),
            Text(
              formattedTime,
            ),
          ],
        ),
      ),
    );
  }
}
