// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../data/stories_model.dart';
//
// class StoryService{
//
//   final UserStory story;
//   final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
//
//   StoryService(this.story);
//
//   Future<void> addStory(ImageSource source) async {
//
//     // if (currentUserId == null) {
//     //   print('User is not authenticated');
//     //   return;
//     // }
//
//     final ImagePicker imagePicker = ImagePicker();
//     final XFile? img = await imagePicker.pickImage(source: source);
//
//     if (img != null) {
//       File file = File(img.path);
//
//       DocumentReference docRef = _fireStore.collection('stories').doc();
//
//       Reference ref = _storage.ref().child('stories/${docRef.id}');
//
//       await ref.putFile(file);
//       String getURL = await ref.getDownloadURL();
//
//       await docRef.set({
//         'id' : docRef.id,
//         'userId': currentUserId,
//         'imgURL': getURL,
//         'timeStamp': FieldValue.serverTimestamp()
//       });
//     }
//   }
//
//   Future<void> deleteStory(BuildContext context) async {
//     final String storyId = story.id;
//     final FirebaseFirestore fireStore = FirebaseFirestore.instance;
//     final FirebaseStorage storage = FirebaseStorage.instance;
//
//     await fireStore.collection('stories').doc(storyId).delete();
//
//     try {
//       Reference ref = storage.ref().child('stories/$storyId');
//       await ref.delete();
//     } catch (e) {
//       print('Error deleting image from storage: $e');
//     }
//
//     Navigator.pop(context); // Close the StoryView after deletion
//   }
//
//
// }