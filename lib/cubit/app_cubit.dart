import 'dart:io';

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
import 'package:image_picker/image_picker.dart';

import '../data/user_story.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

///////////////////////

  // String? userName;

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


  Future<String> getUserName(String userId) async {
    try {
      emit(GetUserDataLoadingState());

      final snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userModel = UserModel.fromJson(snapshot.docs[1].data()) ;
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

  ////////////
  ///Change Screen (Navigation Bar)
  final pages = [const MyChasts(), const UserScreen(), const StoriesScreen()];
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

////////////
  ///Select message
  void selectMessage(messageId) {
    int index = messages.indexWhere((message) => message.id == messageId);

    if (index != -1) {
      // If the message is found, update its isSelected value
      messages[index].isSelected =
          !messages[index].isSelected; // Change to true or toggle if needed
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
      addMessage(userId: userId, chatId: id, type: false, message: message);
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

    Map<String, dynamic> newWallpaper = {chatId: wallpaperUrl};

    FirebaseFirestore.instance.collection('Users').doc("22010237").update({
      'chatWallpapers': FieldValue.arrayUnion([newWallpaper]),
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

  final CollectionReference storiesRef =
      FirebaseFirestore.instance.collection('stories');

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
        String storyId =
            FirebaseFirestore.instance.collection('stories').doc().id;

        // Upload to Firebase Storage using the same storyId
        String storyImageUrl = await uploadStoryImage(storyImage, storyId);
        if (storyImageUrl.isNotEmpty) {
          // Add story metadata to Firestore using the same storyId
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
      );

      await FirebaseFirestore.instance.collection('stories').doc(storyId).set({
        'id': userStory.id,
        'userId': userStory.userId,
        'imgURL': userStory.imgURL,
        'timeStamp': userStory.timeStamp.toIso8601String(),
      });

      emit(AddStorySuccessState());
    } catch (e) {
      emit(AddStoryFailedState());
      print("Error adding story to Firestore: $e");
    }
  }

  Future<void> deleteStory({required String storyId}) async {
    emit(DeleteStoryLoadingState());

    try {
      // Delete story metadata from Firestore
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(storyId)
          .delete();

      // Delete story image from Firebase Storage
      await FirebaseStorage.instance.ref().child('stories/$storyId').delete();

      emit(DeleteStorySuccessState());
      getStories();
    } catch (e) {
      emit(DeleteStoryFailedState());
      print("Error deleting story from Firestore: $e");
    }
  }

  /// Get All Stories
  List<UserStory> stories = [];

  void getStories() {
    emit(GetStoriesLoadingState());
    FirebaseFirestore.instance
        .collection('stories')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      stories = snapshot.docs.map((doc) {
        final timestamp = doc['timeStamp'];
        DateTime timeStampDateTime =
            timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
        return UserStory(
            id: doc['id'] ?? '',
            userId: doc['userId'] ?? '',
            imgURL: doc['imgURL'] ?? '',
            timeStamp: timeStampDateTime);
      }).toList();
      emit(GetStoriesSuccessState());
    });
  }

  Map<String, UserModel> users = {};
  List<User> getUsersWithStories() {
    Set<String> userIds = stories.map((story) => story.userId).toSet();
    return userIds
        .map((userId) => users[userId])
        .where((user) => user != null)
        .cast<User>()
        .toList();
  }

  List<UserStory> getStoriesForUser(String userId) {
    return stories.where((story) => story.userId == userId).toList();
  }

  // void uploadStory(String userId, String imgUrl) {
  //   FirebaseFirestore.instance.collection('stories').add({
  //     'userId': userId,
  //     'imgURL': imgUrl,
  //     'timeStamp': FieldValue.serverTimestamp(),
  //   }).then((value) {
  //     getStories();
  //     emit(AddStorySuccessState());
  //   }).catchError((error) {
  //     emit(UploadStoryImageFailedState());
  //   });
  // }
}
