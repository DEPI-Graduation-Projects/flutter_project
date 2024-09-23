import 'package:flutter/material.dart';
import 'package:flutter_project/data/user_story.dart';
import 'package:flutter_project/screens/stories/story_view.dart';

class StoriesView extends StatelessWidget {

  final UserStory story;

  const StoriesView({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => StoryView(story: story))),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(story.imgURL),
          ),
          const SizedBox(height: 5),
          Text(story.user, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
