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

class StoryCubit extends AppCubit {
  static const int storyExpirationDuration = 24 * 60 * 60 * 1000;
  List<UserStory> stories = [];
  final Map<String, List<String>> _storySeenByMap = {};
  final Map<String, List<String>> _storyFavByMap = {};
  AppCubit appCubit = AppCubit();

  static StoryCubit get(BuildContext context) => BlocProvider.of(context);

  final CollectionReference storiesRef =
  FirebaseFirestore.instance.collection('stories');


  UserModel? get currentUser => appCubit.currentUser;

/// Pick Story Image
void pickAndUploadStoryImage(String userId, ImageSource source) async {
  final picker = ImagePicker();
  emit(StoryImageLoadingState());

  await picker.pickImage(source: source).then((value) async {
    if (value != null) {
      File storyImage = File(value.path);
      emit(PickStoryImageSuccessState());

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
      favBy: [],
    );

    await storiesRef.doc(storyId).set({
      'id': userStory.id,
      'userId': userStory.userId,
      'imgURL': userStory.imgURL,
      'timeStamp': userStory.timeStamp.toIso8601String(),
      'seenBy': userStory.seenBy,
      'favBy': userStory.favBy
    });
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

  ///listen to seen
  void listenForNewStories(String currentUserId) async {
    print("Starting listenForNewStories for user: $currentUserId");
    FirebaseFirestore.instance.collection('stories').snapshots().listen(
          (querySnapshot) {
        print("Received snapshot with ${querySnapshot.docs.length} documents");
        for (var doc in querySnapshot.docs) {
          try {
            UserStory story = UserStory.fromMap(doc.data(), doc.id);

            print("Checking story ${story.id} - userId: ${story.userId}, seenBy: ${story.seenBy}");

            if (story.userId != currentUserId) {
              if (!story.isSeenBy(currentUserId)) {
                print("User $currentUserId has not seen story ${story.id} yet.");
              } else {
                print("Story ${story.id} already seen by $currentUserId");
              }
            } else {
              print("Story ${story.id} belongs to the current user, not marking as seen");
            }
          } catch (e) {
            print("Error processing story: $e");
            emit(UpdateStoryErrorState(e.toString()));
          }
        }
      },
      onError: (error) {
        print("Error in listenForNewStories: $error");
        emit(UpdateStoryErrorState(error.toString()));
      },
    );
  }

  void markStoryAsSeen(String storyId, String currentUserId) {
    FirebaseFirestore.instance.collection('stories').doc(storyId).update({
      'seenBy': FieldValue.arrayUnion([currentUserId]),
    }).then((_) {
      print('Story $storyId marked as seen by $currentUserId');
      emit(UpdateStorySuccessState());
    }).catchError((error) {
      print('Error updating story: $error');
      emit(UpdateStoryErrorState(error.toString()));
    });
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

  // mute user for stories
  Future<void> muteUser(String currentUserId, String userToMuteId) async {
    emit(MuteUserLoadingState());
    try {
      print('Attempting to mute user: $userToMuteId');

      DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          print('User document does not exist, creating a new one.');
          transaction.set(userRef, {
            'userId': currentUserId,
            'mutedUsers': [userToMuteId],
          });
        } else {
          print('User document exists, attempting to update mutedUsers.');
          List<String> mutedUsers = List<String>.from(userDoc['mutedUsers'] ?? []);

          if (!mutedUsers.contains(userToMuteId)) {
            print('Adding $userToMuteId to mutedUsers list.');
            mutedUsers.add(userToMuteId);
            transaction.update(userRef, {'mutedUsers': mutedUsers});
          } else {
            print('User $userToMuteId is already muted.');
          }
        }
      });

      await refreshCurrentUserData(currentUserId);

      print('User muted successfully');
      emit(MuteUserSuccessState());
    } catch (e) {
      print('Error muting user: $e');
      emit(MuteUserErrorState(e.toString()));
    }
  }

  // unmute user for stories
  Future<void> unmuteUser(String currentUserId, String userToUnmuteId) async {
    emit(UnmuteUserLoadingState());
    try {
      print('Attempting to unmute user: $userToUnmuteId');

      DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);

        if (userDoc.exists) {
          List<String> mutedUsers = List<String>.from(userDoc['mutedUsers'] ?? []);
          mutedUsers.remove(userToUnmuteId);
          transaction.update(userRef, {'mutedUsers': mutedUsers});
        }
      });

      await refreshCurrentUserData(currentUserId);

      print('User unmuted successfully');
      emit(UnmuteUserSuccessState());
    } catch (e) {
      print('Error unmuting user: $e');
      emit(UnmuteUserErrorState(e.toString()));
    }
  }

  // check user is Muted or not for stories
  bool isUserMuted(String userId) {
    bool isMuted = currentUser?.mutedUsers.contains(userId) ?? false;
    print('Checking if user $userId is muted: $isMuted');
    return isMuted;
  }

  Future<void> refreshCurrentUserData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      appCubit.currentUser = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } else {
      print('User document does not exist');
    }
  }

  bool isStoryFavorited(String storyId, String userId) {
    return _storyFavByMap[storyId]?.contains(userId) ?? false;
  }

  // Add this method to toggle favorite status
  Future<void> toggleFavoriteStatus(String storyId, String userId) async {
    emit(ToggleFavoriteLoadingState());
    try {
      DocumentReference storyRef = storiesRef.doc(storyId);
      DocumentSnapshot storyDoc = await storyRef.get();

      if (storyDoc.exists) {
        List<String> favBy = List<String>.from(storyDoc['favBy'] ?? []);

        if (favBy.contains(userId)) {
          favBy.remove(userId);
        } else {
          favBy.add(userId);
        }

        await storyRef.update({'favBy': favBy});

        _storyFavByMap[storyId] = favBy;
        print("_storyFavByMap after update: $_storyFavByMap");
        emit(ToggleFavoriteSuccessState());
      } else {
        emit(ToggleFavoriteErrorState('Story not found'));
      }
    } catch (e) {
      emit(ToggleFavoriteErrorState(e.toString()));
    }
  }

  List<String> storyFavByList(String storyId) {
    return _storyFavByMap[storyId] ?? [];
  }

  // Modify the getStories method to include favBy
  void getStories() {
    if (isClosed) return;
    emit(GetStoriesLoadingState());
    deleteExpiredStoriesFromBackend();

    try {
      FirebaseFirestore.instance.collection('users').doc(currentUser?.userId).snapshots().listen((userDoc) {
        storiesRef
            .orderBy('timeStamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          stories = snapshot.docs.map((doc) {
            final timestampString = doc['timeStamp'] as String;
            DateTime timeStampDateTime = DateTime.parse(timestampString);
            List<String> favBy = List<String>.from(doc['favBy'] ?? []);
            _storyFavByMap[doc['id']] = favBy;
            return UserStory(
              id: doc['id'] ?? '',
              userId: doc['userId'] ?? '',
              imgURL: doc['imgURL'] ?? '',
              timeStamp: timeStampDateTime,
              seenBy: List<String>.from(doc['seenBy'] ?? []),
              favBy: favBy,
            );
          }).toList();


            emit(GetStoriesSuccessState());


          deleteExpiredStoriesFromBackend();
        });
      });
    } catch (e) {
        emit(GetStoriesErrorState(e.toString()));

    }
  }

  Future<void> replyToStory({
    required String storyId,
    required String replyingUserId,
    required String replyContent,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(storyId)
          .collection('Replies')
          .add({
        'replyingUserId': replyingUserId,
        'content': replyContent,
        'timestamp': FieldValue.serverTimestamp(),
      });
      emit(StoryReplySuccess());
    } catch (e) {
      emit(StoryReplyFailure(e.toString()));
    }
  }
}