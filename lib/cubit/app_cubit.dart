import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../Components/constants.dart';
import '../sharedPref/sharedPrefHelper.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

///////////////////////
  Map<String, String> userNames = {};

///////////formate Time
////
  static String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd', 'en').format(dateTime);
  }

  static String formatTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat(
      'hh:mm a',
    ).format(dateTime);
  }

  ///
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');

////////////////////
////User Sign up
  void appSignUp(
      {required String email,
      required String password,
      required String userName}) {
    emit(UserSignUpLoadingState());
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((onValue) {
      String userId =
          '${Random.secure().nextInt(10)}${Random.secure().nextInt(10)}${Random.secure().nextInt(10)}${Random.secure().nextInt(10)}${Random.secure().nextInt(10)}${Random.secure().nextInt(10)}${Random.secure().nextInt(10)}${Random.secure().nextInt(10)}';
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .set(UserModel(
                  "https://th.bing.com/th/id/OIF.csGcQuy19CVl9ZrjLxBflw?rs=1&pid=ImgDetMain",
                  chatWallpapers: {},
                  name: userName,
                  friends: [],
                  userId: userId,
                  status: false,
                  email: email,
                  password: password)
              .toMap())
          .then((value) {
        CacheHelper.putUserIdValue(userId);

        emit(UserSignUpSuccessState(
            user: UserModel(
                "https://th.bing.com/th/id/OIF.csGcQuy19CVl9ZrjLxBflw?rs=1&pid=ImgDetMain",
                chatWallpapers: {},
                name: userName,
                friends: [],
                userId: userId,
                status: false,
                email: email,
                password: password)));
      });
    }).catchError((error) {
      debugPrint(error);
    });
  }

  ///////////////////////////////////////
  //////
  void appLogin({required String email, required String password}) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((onValue) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get()
          .then((doc) {
        String userId = UserModel.fromJson(doc.docs.first.data()).userId;
        CacheHelper.putUserIdValue(userId);
        getMyData();
      });
      emit(UserLoginSuccessState());
    }).catchError((onError) {
      emit(UserLoginFailedState());
    });
  }

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
        if (currentUser != null) {
          print('the other user name is ${currentUser!.name}');
        }
        emit(GetUserDataSuccessState(
            user: UserModel.fromJson(users.docs.first.data())));
      });
    } catch (error) {
      emit(GetUserDataFailedState());
      print(error);
    }
    return Future(() => null);
  }

  //////////////
  void fetchAllUserNames() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      for (var doc in querySnapshot.docs) {
        String userId = doc['userId'];
        String userName = doc['name'];
        userNames[userId] = userName;
      }
      emit(GetAllUserDataSuccessState());
    } catch (error) {
      print('Error fetching user data: $error');
      emit(GetUserDataFailedState());
    }
  }

  Future<void> fetchAllUsers() async {
    emit(GetAllUsersLoadingState());
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      users = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      emit(GetAllUsersSuccessState());
    } catch (error) {
      print('Error fetching all users: $error');
      emit(GetAllUsersErrorState());
    }
  }

///////
  UserModel? user3;

  Future<void> getUserData2(String userId) async {
    try {
      emit(GetUserDataLoadingState());

      // Wait for Firestore data
      final users = await FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isEqualTo: userId)
          .get();

      // Assign user3 only if data is found
      if (users.docs.isNotEmpty) {
        user3 = UserModel.fromJson(users.docs.first.data());
        print('the other user name is ${user3!.name}');
        emit(GetUserDataSuccessState2(userName: user3!.name));
      } else {
        print("No user found with this ID");
        emit(GetUserDataFailedState());
      }
    } catch (error) {
      emit(GetUserDataFailedState());
      print(error);
    }
  }

  ///////////
  Future<void> getMyData() async {
    if (CacheHelper.getUserIdValue() != null) {
      String id = CacheHelper.getUserIdValue()!;
      emit(GetUserDataLoadingState());
      try {
        // Wait for Firestore data
        FirebaseFirestore.instance
            .collection("Users")
            .where('userId', isEqualTo: id)
            .snapshots()
            .listen((users) {
          if (users.docs.isNotEmpty) {
            Constants.userAccount = UserModel.fromJson(users.docs.first.data());
            // print('user name is ${Constants.userAccount.name}');
            emit(GetUserDataSuccessState(
                user: UserModel.fromJson(users.docs.first.data())));
          } else {
            print("No user found with this ID");
            emit(GetUserDataFailedState());
          }
        });

        // Assign user3 only if data is found
      } catch (error) {
        emit(GetUserDataFailedState());
        print(error);
      }
    }
  }

/////////////////
  ///
  List<UserModel> users = [];

  bool isFriend(String userId) {
    return Constants.userAccount.friends.contains(userId);
  }

  Future<void> getallUsers() {
    try {
      emit(GetUserDataLoadingState());
      // Listen to real-time updates from Firestore
      FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isNotEqualTo: Constants.userAccount.userId)
          .snapshots()
          .listen((docUsers) {
        users = docUsers.docs
            .map((user) => UserModel.fromJson(user.data()))
            .toList();
        filteredUsers = users;
        emit(GetAllUserDataSuccessState());
      });
    } catch (error) {
      emit(GetUserDataFailedState());
      print(error);
    }
    return Future(() => null);
  }

///////////////////
  List<UserModel> filteredUsers = [];

  void filterUsers(String query) {
    emit(FilterMessagesStartState());
    if (query.isEmpty) {
      filteredUsers = users;
    } else {
      filteredUsers = users
          .where((user) => user.name.toLowerCase().contains(query
              .toLowerCase())) // Non-case-sensitive filtering and partial matching
          .toList();
    }
    emit(FilterMessagesEndState());
  }

  int choosenFilter = 0;

  void filterFriends(int index) {
    emit(FilterMessagesStartState());
    filteredUsers = index == 1
        ? users
            .where(
                (user) => Constants.userAccount.friends.contains(user.userId))
            .toList()
        : users;
    choosenFilter = index;
    emit(FilterMessagesEndState());
  }

  Future<String> getUserName(String userId) async {
    try {
      emit(GetUserDataLoadingState());

      final snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userModel = UserModel.fromJson(snapshot.docs[1].data());
        emit(GetUserDataSuccessState(user: userModel));
        return userModel.name;
      } else {
        emit(GetUserDataFailedState());
        return 'Unknown';
      }
    } catch (error) {
      emit(GetUserDataFailedState());
      print(error);
      return error.toString();
    }
  }

  ///////////
  ///Add friend
  void addFriend({required String friendUserId}) {
    emit(AddFriendLoadingState());
    FirebaseFirestore.instance
        .collection('Users')
        .doc(Constants.userAccount.userId)
        .update({
      'friends': FieldValue.arrayUnion([friendUserId])
    }).then((onValue) {
      emit(AddFriendSuccessState(add: true));
    });
  }

////////////
  ///unfriend
  void unFriend({required String friendUserId}) {
    emit(AddFriendLoadingState());
    FirebaseFirestore.instance
        .collection('Users')
        .doc(Constants.userAccount.userId)
        .update({
      'friends': FieldValue.arrayRemove([friendUserId])
    }).then((onValue) {
      emit(AddFriendSuccessState(add: false));
    });
  }

  ////////////
  ///Change Screen (Navigation Bar)
  final screens = [const MyChasts(), const UserScreen(), const StoriesScreen()];
  int selectedIndex = 0;

  void changeScreen(index) {
    selectedIndex = index;
    emit(ChangeScreenState());
  }

  /////////////////////////
  ///used in the chat screen to change the user to test chatting in one screen
  // bool isMe = false;
  // static String userId = "22010237";
  // void changeUserId(bool isMe, context) {
  //   userId = isMe ? "22010237" : "22010289";
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(content: Text("user changed $userId")));
  //   emit(ChangeUserIdState());
  // }

///////////////
  /// image picker in chat screen
  ///
  ///
  ///
  Future<void> updateUserProfile(String userId, String imaeUrl) async {
    await usersRef.doc(userId).update({
      'profilePhoto': imaeUrl,
    });
    emit(UpdateUserProfileSuccessState());
  }

/////////////////////
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
    emit(UploadChatImageSuccessState());
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
      String? replyMessage = "",
      String? message,
      required bool type,
      String? imagaeUrl,
      String? replyMessageId = ""}) {
    DocumentReference chatRef =
        FirebaseFirestore.instance.collection('Chats').doc(chatId);
    String id = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection("Messages")
        .doc()
        .id;
    emit(AddMessageLoadingState());
    chatRef.collection("Messages").doc(id).set({
      'message': message,
      'time': DateTime.now().toString(),
      'id': id,
      'senderId': userId,
      "imagaeUrl": imagaeUrl,
      'type': type,
      'isSeen': false,
      if (replyMessage != null) 'replyMessage': replyMessage,
      if (replyMessageId != null) 'replyMessageId': replyMessageId
    }).then((value) {
      img = null;
      chatRef.update({
        'lastMessage': message,
        'lastMessageTime': DateTime.now().toString()
      });
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
  Future<void> createChat({
    required String userId,
    required String receiverId,
    required String message,
    required List usersNames,
  }) {
    emit(CreateChatLoadingState());
    String id = FirebaseFirestore.instance.collection('Chats').doc().id;
    FirebaseFirestore.instance
        .collection('Chats')
        .doc(id)
        .set(ChatModel(
                lastMessageTime: DateTime.now().toString(),
                usersNames: usersNames,
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
    return Future(() => null);
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

    FirebaseFirestore.instance
        .collection('Users')
        .doc(Constants.userAccount.userId)
        .update({
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

//////////////
  ///filter chats
  List<ChatModel> filteredChats = [];

  void filterList(String query) {
    emit(FilterMessagesStartState());
    if (query.isEmpty) {
      filteredChats = chats;
    } else {
      filteredChats = chats
          .where((chat) => chat.usersNames
              .firstWhere((name) => name != Constants.userAccount.name)
              .toString()
              .toLowerCase()
              .contains(query
                  .toLowerCase())) // Non-case-sensitive filtering and partial matching
          .toList();
    }
    emit(FilterMessagesEndState());
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
      filteredChats = chats;
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
    filteredChats.removeAt(index);
    emit(TempDeleteState());
  }

  Future<String?> getChatId(String userId1, String userId2) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Chats')
          .where('usersIds', arrayContainsAny: [userId1, userId2]).get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        List<dynamic> usersIds = doc['usersIds'];
        if (usersIds.contains(userId1) && usersIds.contains(userId2)) {
          return doc.id; // This is the chatId
        }
      }

      return null; // No matching chat found
    } catch (e) {
      print('Error getting chat ID: $e');
      return null;
    }
  }

// Assuming you have a Cubit or Bloc managing the users state
  ImageProvider? getUserProfilePhoto(String userId) {
    emit(UserProfilePhotoLoading());
    print("Getting profile photo for user: $userId");
    try {
      // First, check if the user is the current user
      if (userId == Constants.userAccount.userId && currentUser2 != null) {
        print(
            "User is current user. Profile photo: ${currentUser2!.profilePhoto}");
        emit(UserProfilePhotoLoaded());
        return currentUser2!.profilePhoto != null
            ? NetworkImage(currentUser2!.profilePhoto!)
            : null;
      }

      // If the users list is empty, try to fetch all users
      if (users.isEmpty) {
        print("Users list is empty. Attempting to fetch all users.");
        fetchAllUsers();
        emit(UserProfilePhotoLoaded());
        return null; // Return null for now, the UI should update when users are fetched
      }

      // Search in the users list
      print("Searching for user in users list. List length: ${users.length}");
      UserModel? user = users.firstWhereOrNull((user) => user.userId == userId);
      if (user != null) {
        print("User found. Profile photo: ${user.profilePhoto}");
        emit(UserProfilePhotoLoaded());
        return user.profilePhoto != null
            ? NetworkImage(user.profilePhoto!)
            : null;
      } else {
        print("User not found in the list.");
      }

      // If user not found or doesn't have a profile photo, return null
      print("Returning null as no profile photo was found.");
      emit(UserProfilePhotoEmpty());
      return null;
    } catch (error) {
      print('Error getting user profile photo: $error');
      emit(UserProfilePhotoError(error.toString()));
      return null;
    }
  }
}
