import 'package:flutter/material.dart';

import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';
import '../../cubit/app_states.dart';
import 'user_avatar.dart';

Widget userListTile(BuildContext context, StoryCubit storyCubit, String userId,
    String storyId) {
  print("Building tile for userId: $userId, storyId: $storyId");
  print("Is story favorited: ${storyCubit.isStoryFavorited(storyId, userId)}");
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
    child: Card(
      color: Colors.white.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        leading: userAvatar(context, storyCubit, userId),
        title: Text(
          storyCubit.userNames[userId] ?? 'No name found',
          style: const TextStyle(fontSize: 16, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: storyCubit.isStoryFavorited(storyId, userId)
            ? Icon(Icons.favorite, color: Constants.appPrimaryColor)
            : const SizedBox.shrink(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  );
}