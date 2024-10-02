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
  Future<void> getUserData(String userId) {
    try {
      emit(GetUserDataLoadingState());
      // Listen to real-time updates from Firestore
      FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((users) {
        currentUser = UserModel.fromJson(users.docs.first.data());
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
  final pages = [const MyChasts(), const UserScreen(), StoriesScreen()];
  int selectedIndex = 0;
  void changeScreen(index) {
    selectedIndex = index;
    emit(ChangeScreenState());
  }

  /////////////////////////
  ///used in the chat screen to change the user to test chatting in one screen
  bool isMe = false;
  String userId = "22010237";
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
      String? message,
      required bool type,
      String? imagaeUrl}) {
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
      'type': type
    }).then((value) {
      img = null;
      emit(AddMessageSuccessState());
    }).catchError((error) {
      debugPrint(error);
    });
    return Future(() => null);
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

////////////////////////
  /// changing icon in the chat
  bool isTyping = false;
  void changeSendIcon(value) {
    isTyping = value.isNotEmpty;
    emit(ChangeSendIconstate());
  }

  /////////////////////
  /// create chat method for the first time
  void createChat(
      {required String userId,
      required String receiverId,
      required String message}) {
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
      addMessage(userId: userId, chatId: id, type: false, message: message);
      emit(CreateChatSuccessState());
    }).catchError((onError) {
      emit(CreateChatFailState());
    });
  }

//////////////////////////////////
  /// get all chat messages
  List<MessageModel> messages = [];
  void getChat({required String userId, required String chatId}) {
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
  bool cancleDeletion = false;
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
    messages.removeAt(index);
    emit(TempDeleteState());
  }
}
