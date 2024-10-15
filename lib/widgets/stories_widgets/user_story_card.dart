import 'package:flutter/material.dart';
import 'package:flutter_project/Components/constants.dart';

import '../../cubit/story_cubit.dart';
import '../../models/stories_model.dart';
import '../../screens/stories/story_view.dart';
import 'addStoryCard.dart';
import 'user_content.dart';

Widget userStoryCard(BuildContext context, StoryCubit cubit,
    List<UserStory> userStories, String userId, bool isCurrentUser) {
  if (isCurrentUser && userStories.isEmpty) {
    return addStoryCard(context, cubit);
  }

  final lastStory = userStories.isNotEmpty ? userStories.first : null;
  final hasUnseenStory =
      userStories.any((story) => !story.isSeenBy(Constants.userAccount.userId));

  return GestureDetector(
    onTap: () {
      if (userStories.isNotEmpty) {
        print(
            "Calling listenForNewStories for user: ${Constants.userAccount.userId}");
        cubit.listenForNewStories(Constants.userAccount.userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryView(
              stories: userStories.reversed.toList(),
            ),
          ),
        );
      } else if (isCurrentUser) {
        cubit.pickAndUploadStoryImage(Constants.userAccount.userId);
      }
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: hasUnseenStory && !isCurrentUser
            ? Border.all(color: Constants.appPrimaryColor, width: 3)
            : null,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: lastStory != null
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                      child: Image.network(
                        lastStory.imgURL,
                        fit: BoxFit.cover,
                      ),
                    )
                  : userContent(cubit),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  isCurrentUser
                      ? 'My Story'
                      : (cubit.userNames?[userId] ?? 'No name found'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (userStories.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Constants.appPrimaryColor,
                  child: Text(
                    '${userStories.length}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (isCurrentUser && userStories.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    cubit.pickAndUploadStoryImage(Constants.userAccount.userId);
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Constants.appPrimaryColor,
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
