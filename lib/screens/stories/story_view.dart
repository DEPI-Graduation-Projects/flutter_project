import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/data/user_story.dart';

class StoryView extends StatelessWidget {

  final UserStory story;

  const StoryView({super.key, required this.story});

  Future<void> _deleteStory(BuildContext context) async {
    final String storyId = story.id;
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final FirebaseStorage storage = FirebaseStorage.instance;

    await fireStore.collection('stories').doc(storyId).delete();

    try {
      Reference ref = storage.ref().child('stories/$storyId');
      await ref.delete();
    } catch (e) {
      print('Error deleting image from storage: $e');
    }

    Navigator.pop(context); // Close the StoryView after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(story.imgURL),
            )
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          _deleteStory(context);
        },
      child: const Icon(Icons.delete),
      ),
    );
  }
}
