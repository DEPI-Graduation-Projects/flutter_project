import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/data/user_story.dart';
import 'package:flutter_project/screens/stories/story_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoriesView extends StatelessWidget {
  final UserStory? story;
  final int index;

  const StoriesView({
    super.key,
    this.story, required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final hasStory = story != null;
    var cubit = AppCubit.get(context);

    return GestureDetector(
      onTap: () {
        if (hasStory) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StoryView(stories: cubit.stories,)));
        } else {
          context.read<AppCubit>().pickAndUploadStoryImage(currentUser!.uid);
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StoryView(stories: cubit.stories, initialIndex: index,))),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                    child: Image.network(
                      cubit.stories[index].imgURL,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                if (cubit.isMe && !hasStory)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.add, color: Colors.white, size: 15),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    cubit.currentUser?.name ?? 'Loading...',
                    style: const TextStyle(color: Colors.white, fontSize: 17),),
                ),
        ]
            ),
        ),
      ),
    );
  }
}
