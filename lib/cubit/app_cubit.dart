import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/models/chat_model.dart';
import 'package:flutter_project/models/message_model.dart';
import 'package:flutter_project/models/user_model.dart';
import 'package:flutter_project/screens/chats/my_chats/my_chasts.dart';
import 'package:flutter_project/screens/stories/stories_screen.dart';
import 'package:flutter_project/screens/user/user_screen/user_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitState());
  static AppCubit get(BuildContext context) => BlocProvider.of(context);

///////////////////////
  ///
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');

  // Set the user's status to online
  Future<void> setUserOnline(String userId) async {
    await usersRef.doc(userId).update({
      'status': true,
    });
  }

  // Set the user's status to offline
  Future<void> setUserOffline(String userId) async {
    await usersRef.doc(userId).update({
      'status': false,
    });
  }

  /////////////
  UserModel? currentUser;
  UserModel? currentUser2;

  Future<void> getUserData(String userId, bool isMe) {
    try {
      emit(GetUserDataLoadingState());
      // Listen to real-time updates from Firestore
      FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((users) {
        isMe
            ? currentUser2 = UserModel.fromJson(users.docs.first.data())
            : currentUser = UserModel.fromJson(users.docs.first.data());
        emit(GetUserDataSuccessState());
      });
    } catch (error) {
      emit(GetUserDataFailedState());
      print(error);
    }
    return Future(() => null);
  }

/////////////////
  ///
  List<UserModel> users = [];
  Future<void> getallUsers() {
    try {
      emit(GetUserDataLoadingState());
      // Listen to real-time updates from Firestore
      FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isNotEqualTo: userId)
          .snapshots()
          .listen((docUsers) {
        users = docUsers.docs
            .map((user) => UserModel.fromJson(user.data()))
            .toList();

        emit(GetUserDataSuccessState());
      });
    } catch (error) {
      emit(GetUserDataFailedState());
      print(error);
    }
    return Future(() => null);
  }

  //////////////
  ///Change Screen (Navigation Bar)
  final screens = [
    MyChasts(
      userId: userId,
    ),
    const UserScreen(),
    StoriesScreen()
  ];
  int selectedIndex = 0;
  void changeScreen(index) {
    selectedIndex = index;
    emit(ChangeScreenState());
  }

  /////////////////////////
  ///used in the chat screen to change the user to test chatting in one screen
  bool isMe = false;
  static String userId = "22010237";
  void changeUserId(bool isMe, context) {
    userId = isMe ? "22010237" : "22010289";
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("user changed $userId")));
    emit(ChangeUserIdState());
  }

///////////////
  /// image picker in chat screen
  File? img;
  void pickChatImage(ImageSource source) async {
    final picker = ImagePicker();
    emit(ImageLoadingState());
    await picker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        img = File(value.path);
        emit(PickImageState());
      }
      debugPrint("Image Picked");
    });
  }

  ////////////
  ///Upload the image into fire base
  String chatImageUrl = "";
  Future<String> uploadChatimage({
    required File? file,
  }) async {
    emit(UploadChatImageLoadingState());
    String url = 'ChatImages/${Uri.file(file!.path)}';
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('ChatImages/${Uri.file(file.path).pathSegments.last}');
    TaskSnapshot snapShot = await ref.putFile(file);
    String downloadURL = await snapShot.ref.getDownloadURL();
    url = downloadURL;
    debugPrint("Url is $url");
    return url;
  }

  ////////////////////
  ///set image to null
  void swap() {
    img = null;
    emit(SwapState());
  }

  /////////////////////////
  /// send message method
  Future<void> addMessage(
      {required String userId,
      required chatId,
      replyMessage = "",
      String? message,
      required bool type,
      String? imagaeUrl,
      required replyMessageId}) {
    String id = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection("Messages")
        .doc()
        .id;
    emit(AddMessageLoadingState());
    FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection("Messages")
        .doc(id)
        .set({
      'message': message,
      'time': DateTime.now().toString(),
      'id': id,
      'senderId': userId,
      "imagaeUrl": imagaeUrl,
      'type': type,
      'isSeen': false,
      'replyMessage': replyMessage,
      'replyMessageId': replyMessageId
    }).then((value) {
      img = null;
      emit(AddMessageSuccessState());
    }).catchError((error) {
      debugPrint(error);
    });
    return Future(() => null);
  }

///////////////
////Set message as seen

  void listenForNewMessages(String chatId, String recipientId) {
    FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .where('isSeen', isEqualTo: false)
        .where('senderId', isEqualTo: recipientId)
        .snapshots()
        .listen((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        // Automatically mark messages as seen when the recipient views them
        doc.reference.update({
          'isSeen': true,
        }).then((value) {
          emit(UpdateMessageSuccessState());
        });
      }
    });
  }
  // static bool listen = false;

  // void listenForNewMessages(
  //     String chatId, String recipientId, isChatScreenActive) {
  //   FirebaseFirestore.instance
  //       .collection('Chats')
  //       .doc(chatId)
  //       .collection('Messages')
  //       .where('isSeen', isEqualTo: false)
  //       .where('senderId', isEqualTo: recipientId)
  //       .snapshots()
  //       .listen((querySnapshot) {
  //     if (isChatScreenActive) {
  //       // Only mark as seen if the chat screen is active
  //       for (var doc in querySnapshot.docs) {
  //         // Automatically mark messages as seen when the recipient views them
  //         doc.reference.update({
  //           'isSeen': true,
  //         }).then((value) {
  //           emit(UpdateMessageSuccessState());
  //         });
  //       }
  //     }
  //   });
  // }

  //////////
  ////Reply messages
  bool isReplyOn = false;
  MessageModel? replyMessage;
  void turnReply(reply) {
    isReplyOn = true;
    replyMessage = reply;
    print(isReplyOn);
    emit(TurnReplyOnState());
  }

  void cancleReply() {
    isReplyOn = false;
    emit(CancleReplyState());
  }

  ///////////////////
  ///Delete Message
  Future<void> deleteChatMessage({required chatId, required messageId}) {
    FirebaseFirestore.instance
        .collection("Chats")
        .doc(chatId)
        .collection("Messages")
        .doc(messageId)
        .delete()
        .then((onValue) {});
    emit(DeleteMessageSuccessState());

    return Future(() => null);
  }

///////////
////Copy Message
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      emit(CopyTextSuccessState());
    });
  }

////////////
  ///Select message
  void selectMessage(messageId) {
    int index = messages.indexWhere((message) => message.id == messageId);

    if (index != -1) {
      messages[index].isSelected = !messages[index].isSelected;
    } else {
      print("Message with ID $messageId not found.");
    }
    emit(SelectMessageSuccesState());
  }

  ////////////
  ////
  Future<void> deleteSelectedMessages(
      List<String> documentIds, String chatId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String docId in documentIds) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection("Chats")
          .doc(chatId)
          .collection("Messages")
          .doc(docId);
      batch.delete(docRef);
    }

    try {
      await batch.commit(); // Execute the batch delete operation
      emit(DeleteSelectedMessagesState());
      print("All documents deleted successfully.");
    } catch (e) {
      print("Error deleting documents: $e");
    }
  }

////////////////////////
  /// changing icon in the chat
  bool isTyping = false;
  void changeSendIcon(value) {
    isTyping = value.isNotEmpty;
    emit(ChangeSendIconstate());
  }

  /////////////////////
  /// create chat method for the first time
  void createChat({
    required String userId,
    required String receiverId,
    required String message,
  }) {
    emit(CreateChatLoadingState());
    String id = FirebaseFirestore.instance.collection('Chats').doc().id;
    FirebaseFirestore.instance
        .collection('Chats')
        .doc(id)
        .set(ChatModel(
                chatId: id,
                usersIds: [userId, receiverId],
                lastMessage: message)
            .toMap())
        .then((onValue) {
      addMessage(
          userId: userId,
          chatId: id,
          type: false,
          message: message,
          replyMessage: "",
          replyMessageId: "");
      emit(CreateChatSuccessState());
    }).catchError((onError) {
      emit(CreateChatFailState());
    });
  }

//////////////////
  ///Update Chat Wallpaper
  String currentWallpaper =
      "https://th.bing.com/th/id/OIF.csGcQuy19CVl9ZrjLxBflw?rs=1&pid=ImgDetMain";
  void updateChatWallpaper({
    required String chatId,
    required String wallpaperUrl,
  }) {
    emit(UpdateChatWallpapperLoadingState());

    // Map<String, dynamic> newWallpaper = {chatId: wallpaperUrl};

    FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'chatWallpapers.$chatId': wallpaperUrl,
    }).then((onValue) {
      currentWallpaper = wallpaperUrl;
      emit(UpdateChatWallpapperSuccessState(chatWallpaperUrl: wallpaperUrl));
    }).catchError((onError) {
      emit(UpdateChatWallpapperFailedState());
    });
  }

//////////////////////////////////
  /// get all chat messages
  List<MessageModel> messages = [];
  void getChatMessages({required String userId, required String chatId}) {
    emit(GetChatMessagesLoadingState());
    messages = [];
    FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection("Messages")
        .orderBy('time')
        .snapshots()
        .listen((snapshot) {
      messages = snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList()
          .reversed
          .toList();
      messages.map((toElement) {
        print(toElement.message);
      });
      emit(GetChatMessagesSuccessState());
    });
  }

  ////////////////////////
  ///get all chats
  List<ChatModel> chats = [];
  void getMyChats({required String userId}) {
    emit(GetChatsLoadingState());
    chats = [];
    FirebaseFirestore.instance
        .collection('Chats')
        .where('usersIds', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      chats =
          snapshot.docs.map((doc) => ChatModel.fromJson(doc.data())).toList();
      emit(GetChatsSuccessState());
    });
  }

  /////////////////////////////
  /// undo method
  bool delete = true;
  void deleteChat({required String chatId}) {
    FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .delete()
        .then((onValue) {
      emit(DeleteChatSuccessState());
    });
  }

  ////////////////////
  ///undo method
  void tempDelete(index) {
    chats.removeAt(index);
    emit(TempDeleteState());
  }
}
