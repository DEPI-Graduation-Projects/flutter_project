import 'package:flutter/material.dart';

import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';
import '../../models/stories_model.dart';
import 'user_story_card.dart';

Widget storiesGrid(BuildContext context, StoryCubit cubit) {
  final Map<String, List<UserStory>> groupedStories = {};
  for (var story in cubit.stories) {
    if (!groupedStories.containsKey(story.userId)) {
      groupedStories[story.userId] = [];
    }
    groupedStories[story.userId]!.add(story);
  }

  groupedStories.forEach((userId, stories) {
    stories.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  });

  final currentUserId = Constants.userAccount.userId;
  final unmutedUserIds = groupedStories.keys.where((userId) =>
  !cubit.isUserMuted(userId) && (cubit.isFriend(userId) || userId == currentUserId)
  ).toList();
  final mutedUserIds = groupedStories.keys.where((userId) =>
  cubit.isUserMuted(userId) && (cubit.isFriend(userId) || userId == currentUserId)
  ).toList();
  unmutedUserIds.remove(currentUserId);
  unmutedUserIds.insert(0, currentUserId);
  mutedUserIds.sort();
  final userIds = [...unmutedUserIds, ...mutedUserIds];

  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 12,
        crossAxisSpacing: 4),
    itemCount: userIds.length,
    itemBuilder: (context, index) {
      final userId = userIds[index];
      final userStories = groupedStories[userId] ?? [];
      final isCurrentUser = userId == currentUserId;
      return userStoryCard(context, cubit, userStories, userId, isCurrentUser);
    },
  );
}