import 'package:flutter/material.dart';
import '../../cubit/story_cubit.dart';
import '../../models/stories_model.dart';
import '../../cubit/app_cubit.dart';

class StoryContent extends StatelessWidget {
  final List<UserStory> stories;
  final PageController pageController;
  final int currentIndex;
  final Function(int) onPageChanged;

  const StoryContent({
    super.key,
    required this.stories,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: stories.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(stories[index].imgURL),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 15,
              child: Text(
                stories[index].userId == AppCubit.userId
                    ? 'My Story'
                    : '${StoryCubit.get(context).userNames?[stories[index].userId]}\'s Story',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
