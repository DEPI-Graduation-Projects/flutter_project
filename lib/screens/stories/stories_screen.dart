import 'package:flutter/material.dart';
import 'package:flutter_project/data/user_story.dart';
import 'package:flutter_project/screens/stories/stories_view.dart';

class StoriesScreen extends StatelessWidget {

  List<UserStory> stories = [
    UserStory(user: 'User 1', imgURL: 'https://w7.pngwing.com/pngs/193/660/png-transparent-computer-icons-woman-avatar-avatar-girl-thumbnail.png'),
    UserStory(user: 'User 2', imgURL: 'https://cdn.vectorstock.com/i/1000v/51/05/male-profile-avatar-with-brown-hair-vector-12055105.jpg')
  ];

  StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF000E08),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
          itemCount: stories.length,
          itemBuilder: (context, index){
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: StoriesView(story: stories[index],),
            );
      },
      ),
    );
  }
}
