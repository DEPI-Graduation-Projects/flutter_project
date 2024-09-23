import 'package:flutter/material.dart';
import 'package:flutter_project/data/user_story.dart';

class StoryView extends StatelessWidget {

  final UserStory story;

  const StoryView({super.key, required this.story});

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
    );
  }
}
