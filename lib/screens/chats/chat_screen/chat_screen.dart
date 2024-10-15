// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/Components/constants.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/models/chat_model.dart';
import 'package:flutter_project/models/message_model.dart';
import 'package:flutter_project/screens/user/users_screen/users_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  // StreamSubscription?
  // _messageSubscription; // Subscription to listen for new messages

  // bool isChatScreenActive = false;
  TextEditingController chatController = TextEditingController();
  List<String> messagesIds = [];

  late ScrollController _scrollController;
  List<String> dates = [];
  String date = "";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en', null).then((_) {});
    _scrollController = ScrollController();

    // isChatScreenActive = true;
    String userId = widget.chat.usersIds
        .firstWhere((id) => id != Constants.userAccount.userId);

    widget.cubb.listenForNewMessages(widget.chat.chatId, userId);

    widget.cubb.getChatMessages(
        userId: Constants.userAccount.userId, chatId: widget.chat.chatId);
  }

  String? highlightedMessageId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is UploadChatImageLoadingState) {
          LoadingAlert.showLoadingDialogUntilState(
              context: context, cubit: widget.cubb, targetState: state);
        } else if (state is UpdateChatWallpapperSuccessState) {
          Navigator.pop(context);
        }
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
        if (state is DeleteSelectedMessagesState) {
          setState(() {
            messagesIds.clear();
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Messages Deleted")));
        }
        if (state is UpdateChatWallpapperSuccessState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Wallpaper updated")));
          Navigator.pop(context);
        } else if (state is CancleReplyState) {
          widget.cubb.replyMessage = null;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image:
                      CachedNetworkImageProvider(widget.cubb.currentWallpaper),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Constants.appPrimaryColor,
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
                                          backgroundColor:
                                              Constants.appPrimaryColor,
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
                        messagesIds.isNotEmpty
                            ? Text('${messagesIds.length} selected ')
                            : const SizedBox(),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'swap') {
                              // setState(() {
                              //   widget.cubb
                              //       .changeUserId(widget.cubb.isMe, context);
                              //   widget.cubb.isMe = !(widget.cubb.isMe);
                              // });
                            } else if (value == 'delete') {
                              messagesIds.isNotEmpty
                                  ? widget.cubb.deleteSelectedMessages(
                                      messagesIds, widget.chat.chatId)
                                  : null;
                            } else {
                              final picker = ImagePicker();
                              picker
                                  .pickImage(source: ImageSource.gallery)
                                  .then((value) {
                                if (value != null) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Container(
                                          height: double.infinity,
                                          color: Colors.black,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: FullScreenImageViewer(
                                                    "", File(value.path),
                                                    type: false),
                                              ),
                                              state is UploadChatImageLoadingState ||
                                                      state
                                                          is UpdateChatWallpapperLoadingState
                                                  ? const CircularProgressIndicator()
                                                  : TextButton(
                                                      onPressed: () {
                                                        widget.cubb
                                                            .uploadChatimage(
                                                                file: File(
                                                                    value.path))
                                                            .then((onValue) {
                                                          widget.cubb
                                                              .updateChatWallpaper(
                                                                  chatId: widget
                                                                      .chat
                                                                      .chatId,
                                                                  wallpaperUrl:
                                                                      onValue);
                                                        });
                                                      },
                                                      child: const Text(
                                                        "Set as Wallpaper",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ))
                                            ],
                                          ),
                                        ),
                                      ));
                                }
                                debugPrint("Image Picked");
                              });
                            }
                            print('Selected: $value');
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'swap',
                                child: Text('Swap'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'wallpaper',
                                child: Text('wallpaper'),
                              ),
                            ];
                          },
                          icon: const Icon(Icons.more_vert),
                        ),
                        messagesIds.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  widget.cubb.getallUsers().then((onValue) {
                                    String forwardMessage = "";

                                    for (var message in widget.cubb.messages) {
                                      if (message.id == messagesIds[0]) {
                                        forwardMessage = message.message!;
                                      }
                                    }
                                    // .firstWhere((message) =>
                                    //     message.id ==
                                    //     messagesIds.where((user) =>
                                    //         user !=
                                    //         AppCubit.userId))
                                    // .message!;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UsersScreen(
                                            message: forwardMessage,
                                            cubb: widget.cubb,
                                          ),
                                        ));
                                  });
                                },
                                icon: const Icon(Icons.forward))
                            : const SizedBox()
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: widget.cubb.messages.length,
                      itemBuilder: (context, index) {
                        final message = widget.cubb.messages[index];

                        final currentDate = AppCubit.formatDate(
                            message.time); // Format the date

                        bool isLastMessageOfDay =
                            (index == widget.cubb.messages.length - 1) ||
                                AppCubit.formatDate(
                                        widget.cubb.messages[index + 1].time) !=
                                    currentDate;
                        bool isHighlighted = message.id == highlightedMessageId;

                        return Column(
                          children: [
                            isLastMessageOfDay
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Center(
                                      child: Text(
                                        currentDate,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            _buildMessage(
                              index: index,
                              message: message,
                              context: context,
                              isDarkMode: false,
                              cubb: widget.cubb,
                              chatId: widget.chat.chatId,
                              isMe: message.senderId ==
                                  Constants.userAccount.userId,
                              isHighlighted: isHighlighted,
                            ),
                          ],
                        );

                        // Empty widget for unexpected cases
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
                      child: bottomBar(
                          widget.cubb,
                          Constants.userAccount.userId,
                          state,
                          widget.cubb.replyMessage)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _scrollToMessage(String messageId) {
    final messagesList = widget.cubb.messages;
    final messageIndex =
        messagesList.indexWhere((item) => (item.id == messageId));
    print(messageIndex);

    if (messageIndex != -1) {
      _scrollController.animateTo(
        messageIndex * 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        highlightedMessageId = messageId;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          highlightedMessageId = null;
        });
      });
    } else {
      print("Message not found");
    }
  }

  Widget bottomBar(AppCubit cubb, userId, state, MessageModel? replyMessage) {
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
              : SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      state is TurnReplyOnState
                          ? Column(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.topEnd,
                                  child: InkWell(
                                    onTap: () {
                                      cubb.cancleReply();
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.amber,
                                      radius: 10,
                                      child: Icon(
                                        color: Colors.white,
                                        Icons.close,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                replyItem(cubb.replyMessage!.message!, false)
                              ],
                            )
                          : Container(
                              color: Colors.white,
                            ),
                      DefaultTextField(
                        replyOn: cubb.isReplyOn,
                        height: 8,
                        type: TextInputType.text,
                        onChanged: (value) {},
                        label: "Enter a message",
                        controller: chatController,
                        errStr: "please Enter a message",
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(width: 8),
        state is UploadChatImageLoadingState
            ? const CircularProgressIndicator()
            : IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  size: 32,
                  color: Constants.appPrimaryColor,
                ),
                onPressed: () async {
                  if (chatController.text.isNotEmpty || cubb.img != null) {
                    String imageUrl = "";
                    if (cubb.img != null) {
                      imageUrl = await cubb.uploadChatimage(file: cubb.img);
                    }

                    await cubb.addMessage(
                        replyMessage:
                            replyMessage != null ? replyMessage.message : "",
                        chatId: widget.chat.chatId,
                        userId: userId,
                        type: imageUrl.isNotEmpty,
                        imagaeUrl: imageUrl,
                        message: chatController.text,
                        replyMessageId:
                            replyMessage != null ? replyMessage.id : "");
                  }
                  chatController.clear();
                  cubb.img = null;
                  cubb.changeSendIcon('');
                  cubb.cancleReply();
                },
              ),
        IconButton(
          icon: Icon(
            Icons.add_photo_alternate_rounded,
            size: 32.0,
            color: Constants.appPrimaryColor,
          ),
          onPressed: () {
            cubb.pickChatImage(ImageSource.gallery);
          },
        ),
      ],
    );
  }

  Widget replyItem(String reply, bool onMessage) {
    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadiusDirectional.only(
          bottomEnd: Radius.circular(onMessage ? 20 : 0),
          bottomStart: Radius.circular(onMessage ? 20 : 0),
          topStart: const Radius.circular(20),
          topEnd: const Radius.circular(20),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(width: 2, color: Colors.black),
          borderRadius: const BorderRadiusDirectional.all(
            Radius.circular(20),
          ),
        ),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            reply,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
      {index,
      required MessageModel message,
      required context,
      required bool isDarkMode,
      required bool isMe,
      required chatId,
      required AppCubit cubb,
      isHighlighted}) {
    String formattedTime = AppCubit.formatTime(message.time);

    return CustomSwipeItem(
      isMe: isMe,
      fun: () {
        cubb.turnReply(message);
      },
      child: Align(
        alignment: isMe
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.amber.shade900
                      .withOpacity(0.5) // Highlighted background color
                  : Colors.transparent, // Default background color
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: messagesIds.isNotEmpty
                      ? () {
                          messagesIds.contains(message.id)
                              ? messagesIds.remove(message.id)
                              : messagesIds.add(message.id);
                          cubb.selectMessage(message.id);
                        }
                      : () {
                          print(index);
                        },
                  onLongPress: () {
                    messagesIds.contains(message.id)
                        ? messagesIds.remove(message.id)
                        : messagesIds.add(message.id);
                    cubb.selectMessage(message.id);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      message.replyMessage.isNotEmpty
                          ? ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.5, // Limit to 80% of screen width
                              ),
                              child: GestureDetector(
                                  onTap: () {
                                    _scrollToMessage(message.replyMessageId);
                                  },
                                  child: replyItem(message.replyMessage, true)))
                          : const SizedBox(),
                      Container(
                        width: message.replyMessage.isNotEmpty
                            ? MediaQuery.of(context).size.width * 0.5
                            : null,
                        decoration: BoxDecoration(
                          color: message.isSelected
                              ? Colors.blue
                              : isMe
                                  ? Colors.amber.shade700
                                  : const Color(0xFF263238),
                          borderRadius: BorderRadiusDirectional.only(
                            topStart: const Radius.circular(16.0),
                            topEnd: const Radius.circular(16.0),
                            bottomStart: Radius.circular(isMe ? 16.0 : 0),
                            bottomEnd: Radius.circular(isMe ? 0.0 : 16.0),
                          ),
                        ),
                        child: message.type
                            ? Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: InkWell(
                                  onTap: messagesIds.isNotEmpty
                                      ? () {
                                          messagesIds.contains(message.id)
                                              ? messagesIds.remove(message.id)
                                              : messagesIds.add(message.id);
                                          cubb.selectMessage(message.id);
                                        }
                                      : () =>
                                          FullScreenImageViewer.showFullImage(
                                              context, message.imagaeUrl),
                                  child: ClipRRect(
                                    borderRadius:
                                        const BorderRadiusDirectional.only(
                                      topStart: Radius.circular(16.0),
                                      topEnd: Radius.circular(16.0),
                                      bottomStart: Radius.circular(16.0),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: message.imagaeUrl!,
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
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
                                  style: const TextStyle(color: Colors.white),
                                  message.message!,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isMe
                        ? Icon(
                            Icons.done_all,
                            color: message.isSeen ? Colors.blue : Colors.grey,
                          )
                        : const SizedBox(),
                    Text(
                      formattedTime,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
