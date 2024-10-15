// story_progress_bar.dart

import 'package:flutter/material.dart';
import '../../Components/constants.dart';

class StoryProgressBar extends StatelessWidget {
  final List<double> progressList;
  final int currentIndex;
  final int storyCount;

  const StoryProgressBar({
    super.key,
    required this.progressList,
    required this.currentIndex,
    required this.storyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(storyCount, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: LinearProgressIndicator(
              value: progressList[index],
              backgroundColor: index >= currentIndex
                  ? Colors.grey
                  : Constants.appPrimaryColor,
              minHeight: 4,
            ),
          ),
        );
      }),
    );
  }
}
