import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:image_picker/image_picker.dart';
import '../models/stories_model.dart';
import '../models/user_model.dart';
import 'app_states.dart';

class StoryCubit extends Cubit<AppStates> {
  static const int storyExpirationDuration = 24 * 60 * 60 * 1000;
  List<UserStory> stories = [];
  final Map<String, List<String>> _storySeenByMap = {};
  AppCubit appCubit = AppCubit();

  static StoryCubit get(BuildContext context) => BlocProvider.of(context);

  final CollectionReference storiesRef =
  FirebaseFirestore.instance.collection('stories');

  StoryCubit(): super(AppInitState());

  UserModel? get currentUser => appCubit.currentUser;
  Map<String, String>? get userNames => appCubit.userNames;

  ImageProvider? getUserProfilePhoto(String userId){
    return appCubit.getUserProfilePhoto(userId);
  }

  void fetchAllUserNames(){
    appCubit.fetchAllUserNames();
  }

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

///get stories seen
Future<List<String>> getStorySeenBy(String storyId) async {
  if (_storySeenByMap.containsKey(storyId)) {
    emit(GetStorySeenBySuccessState());
    return _storySeenByMap[storyId] ?? [];
  }

  emit(GetStorySeenByLoadingState());

  try {
    DocumentSnapshot storyDoc = await storiesRef.doc(storyId).get();

    if (storyDoc.exists) {
      Map<String, dynamic> data = storyDoc.data() as Map<String, dynamic>;
      List<String> seenBy = List<String>.from(data['seenBy'] ?? []);
      _storySeenByMap[storyId] = seenBy;
      emit(GetStorySeenBySuccessState());
      return seenBy;
    } else {
      _storySeenByMap[storyId] = [];
      emit(GetStorySeenBySuccessState());
      return [];
    }
  } catch (e) {
    emit(GetStorySeenByErrorState(e.toString()));
    return [];
  }
}

int storySeenByCount(String storyId) {
  return _storySeenByMap[storyId]?.length ?? 0;
}

List<String> storySeenByList(String storyId) {
  return _storySeenByMap[storyId] ?? [];
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
}