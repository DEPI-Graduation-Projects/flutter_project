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
import 'package:intl/intl.dart';

import '../models/stories_model.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

///////////////////////
  Map<String, String> userNames = {};
  static const int storyExpirationDuration = 24 * 60 * 60 * 1000;
  List<UserStory> stories = [];
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
        emit(GetUserDataSuccessState());
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
      emit(GetUserDataSuccessState());
    } catch (error) {
      print('Error fetching user data: $error');
      emit(GetUserDataFailedState());
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
  UserModel? userAccount;
  Future<void> getMyData(String userId) async {
    try {
      emit(GetUserDataLoadingState());

      // Wait for Firestore data
      final users = await FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isEqualTo: userId)
          .get();

      // Assign user3 only if data is found
      if (users.docs.isNotEmpty) {
        userAccount = UserModel.fromJson(users.docs.first.data());
        emit(GetUserDataSuccessState());
      } else {
        print("No user found with this ID");
        emit(GetUserDataFailedState());
      }
    } catch (error) {
      emit(GetUserDataFailedState());
      print(error);
    }
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
        filteredUsers = users;
        emit(GetUserDataSuccessState());
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
            .where((user) => userAccount!.friends.contains(user.userId))
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
        emit(GetUserDataSuccessState());
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
        .doc(userAccount!.userId)
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
        .doc(userAccount!.userId)
        .update({
      'friends': FieldValue.arrayRemove([friendUserId])
    }).then((onValue) {
      emit(AddFriendSuccessState(add: false));
    });
  }

  ////////////
  ///Change Screen (Navigation Bar)
  final screens = [
    MyChasts(
      userId: userId,
    ),
    const UserScreen(),
    const StoriesScreen()
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
              .firstWhere((name) => name != userAccount!.name)
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

  ImageProvider? getUserProfilePhoto(String userId) {
    try {
      // First, check if the user is the current user
      if (userId == AppCubit.userId && currentUser2 != null) {
        return NetworkImage(currentUser2!.profilePhoto!);
      }

      // If not, search in the users list
      UserModel? user = users.firstWhere((user) => user.userId == userId);
      if (user.profilePhoto != null) {
        return NetworkImage(user.profilePhoto!);
      }

      // If user not found or doesn't have a profile photo, return null
      return null;
    } catch (error) {
      print('Error getting user profile photo: $error');
      return null;
    }
  }

  final CollectionReference storiesRef =
      FirebaseFirestore.instance.collection('stories');

  ///listen to seen
  void listenForNewStories(String currentUserId) async {
    print("Starting listenForNewStories for user: $currentUserId");
    FirebaseFirestore.instance.collection('stories').snapshots().listen(
        (querySnapshot) {
      print("Received snapshot with ${querySnapshot.docs.length} documents");
      for (var doc in querySnapshot.docs) {
        try {
          UserStory story = UserStory.fromMap(doc.data(), doc.id);

          print(
              "Checking story ${story.id} - userId: ${story.userId}, seenBy: ${story.seenBy}");

          if (story.userId != currentUserId && !story.isSeenBy(currentUserId)) {
            print("Updating story ${story.id} for user $currentUserId");
            doc.reference.update({
              'seenBy': FieldValue.arrayUnion([currentUserId]),
            }).then((_) {
              print('Story ${story.id} marked as seen by $currentUserId');
              emit(UpdateStorySuccessState());
            }).catchError((error) {
              print('Error updating story: $error');
              emit(UpdateStoryErrorState(error.toString()));
            });
          } else if (story.userId == currentUserId) {
            print(
                "Story ${story.id} belongs to the current user, not marking as seen");
          } else {
            print("Story ${story.id} already seen by $currentUserId");
          }
        } catch (e) {
          print("Error processing story: $e");
          emit(UpdateStoryErrorState(e.toString()));
        }
      }
    }, onError: (error) {
      print("Error in listenForNewStories: $error");
      emit(UpdateStoryErrorState(error.toString()));
    });
  }

  /// Pick Story Image
  void pickAndUploadStoryImage(String userId) async {
    final picker = ImagePicker();
    emit(StoryImageLoadingState());

    // Pick an image
    await picker.pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        File storyImage = File(value.path);
        emit(PickStoryImageSuccessState());

        // Generate the storyId before uploading
        String storyId = storiesRef.doc().id;

        String storyImageUrl = await uploadStoryImage(storyImage, storyId);
        if (storyImageUrl.isNotEmpty) {
          await addStory(
              userId: userId, storyId: storyId, imageUrl: storyImageUrl);
        }
      } else {
        emit(PickStoryImageFailedState());
      }
    }).catchError((error) {
      emit(PickStoryImageFailedState());
      print("Error picking story image: $error");
    });

    getStories();
  }

  /// upload an image
  Future<String> uploadStoryImage(File imageFile, String storyId) async {
    emit(UploadStoryImageLoadingState());
    try {
      // Use storyId as the file name in Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child('stories/$storyId');
      TaskSnapshot snapShot = await ref.putFile(imageFile);
      String downloadURL = await snapShot.ref.getDownloadURL();
      emit(UploadStoryImageSuccessState());
      return downloadURL;
    } catch (e) {
      emit(UploadStoryImageFailedState());
      print("Error uploading story image: $e");
      return '';
    }
  }

  ///Add Story to Firestore
  Future<void> addStory(
      {required String userId,
      required String storyId,
      required String imageUrl}) async {
    emit(AddStoryLoadingState());

    try {
      UserStory userStory = UserStory(
        id: storyId,
        userId: userId,
        imgURL: imageUrl,
        timeStamp: DateTime.now(),
        seenBy: [],
      );

      await storiesRef.doc(storyId).set({
        'id': userStory.id,
        'userId': userStory.userId,
        'imgURL': userStory.imgURL,
        'timeStamp': userStory.timeStamp.toIso8601String(),
        'seenBy': userStory.seenBy,
      });

      // scheduleStoryDeletion(storyId);

      emit(AddStorySuccessState());
    } catch (e) {
      emit(AddStoryFailedState());
      print("Error adding story to Firestore: $e");
    }
  }

  /// delete Story
  Future<void> deleteStory({required String storyId}) async {
    emit(DeleteStoryLoadingState());

    try {
      await storiesRef.doc(storyId).delete();

      await FirebaseStorage.instance.ref().child('stories/$storyId').delete();

      emit(DeleteStorySuccessState());
      getStories();
    } catch (e) {
      emit(DeleteStoryFailedState());
      print("Error deleting story from Firestore: $e");
    }
  }

  /// Get All Stories
  void getStories() {
    emit(GetStoriesLoadingState());
    deleteExpiredStoriesFromBackend();

    try {
      storiesRef
          .orderBy('timeStamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        stories = snapshot.docs.map((doc) {
          final timestampString = doc['timeStamp'] as String;
          DateTime timeStampDateTime = DateTime.parse(timestampString);
          return UserStory(
            id: doc['id'] ?? '',
            userId: doc['userId'] ?? '',
            imgURL: doc['imgURL'] ?? '',
            timeStamp: timeStampDateTime,
            seenBy: List<String>.from(doc['seenBy'] ?? []),
          );
        }).toList();
        emit(GetStoriesSuccessState());

        deleteExpiredStoriesFromBackend();
      });
    } catch (e) {
      emit(GetStoriesErrorState(e.toString()));
    }
  }

  // auto delete Story after 24 hr
  void deleteExpiredStoriesFromBackend() {
    print('Checking for expired stories...');
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    print('Current time in milliseconds: $currentTime');

    for (var story in List.from(stories)) {
      final storyTimeStampInMillis = story.timeStamp.millisecondsSinceEpoch;
      final storyAge = currentTime - storyTimeStampInMillis;

      print('Story ID: ${story.id}, Age: $storyAge');

      if (storyAge >= storyExpirationDuration) {
        storiesRef.doc(story.id).delete().then((_) {
          print('Successfully deleted story: ${story.id}');
        }).catchError((error) {
          print('Failed to delete story: $error');
        });
        FirebaseStorage.instance
            .ref()
            .child('stories/${story.id}')
            .delete()
            .then((_) {
          print('Successfully deleted story: ${story.id}');
        }).catchError((error) {
          print('Failed to delete story: $error');
        });
      }
    }
  }

  ///get stories seen
  Future<List<String>> getStorySeenBy(String storyId) async {
    try {
      DocumentSnapshot storyDoc = await storiesRef.doc(storyId).get();

      if (storyDoc.exists) {
        Map<String, dynamic> data = storyDoc.data() as Map<String, dynamic>;
        List<String> seenBy = List<String>.from(data['seenBy'] ?? []);
        emit(GetStorySeenBySuccessState());
        return seenBy;
      } else {
        return [];
      }
    } catch (e) {
      emit(GetStorySeenByErrorState(e.toString()));
      return [];
    }
  }
}
