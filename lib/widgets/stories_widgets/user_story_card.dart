import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/widgets/stories_widgets/upload_story.dart';
import 'package:flutter_project/widgets/stories_widgets/user_content.dart';
import '../../Components/constants.dart';
import '../../cubit/app_states.dart';
import '../../cubit/story_cubit.dart';
import '../../models/stories_model.dart';
import '../../screens/stories/story_view.dart';
import 'addStoryCard.dart';

Widget userStoryCard(BuildContext context, StoryCubit cubit,
    List<UserStory> userStories, String userId, bool isCurrentUser) {

  if (isCurrentUser) {
    print('userStories for current user: ${userStories.length}');
    if (userStories.isEmpty) {
      return addStoryCard(context, cubit);
    }
  }

  final lastStory = userStories.isNotEmpty ? userStories.first : null;
  final hasUnseenStory =
  userStories.any((story) => !story.isSeenBy(Constants.userAccount.userId));

  return BlocConsumer<StoryCubit, AppStates>(
    listener: (context, state) {
      if (state is MuteUserSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User $userId Muted Successfully!')));
      } else if (state is UnmuteUserSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User $userId Un-Muted Successfully!')));
      } else if (state is MuteUserErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Muting User $userId!')));
      } else if (state is UnmuteUserErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Un-Muting User $userId!')));
      }
    },
    builder: (context, state) {
      final isMuted = cubit.isUserMuted(userId);
      print('Building userStoryCard for user: $userId, isMuted: $isMuted');
      return GestureDetector(
        onTap: () {
          if (userStories.isNotEmpty) {
            print("Calling listenForNewStories for user: ${Constants.userAccount.userId}");
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
            showUploadOptionsDialog(context, cubit);
          }
        },
        onLongPress: () {
          if (!isCurrentUser) {
            print('Long press detected on user story: $userId');
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.grey[800],
                title: Center(child: Text(isMuted ? 'Unmute Stories' : 'Mute Stories', style: TextStyle(color: Constants.appPrimaryColor),)),
                content: Text('Do you want to ${isMuted ? 'unmute' : 'mute'} stories from this user?'),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () async {
                          print('Mute/Unmute button pressed for user: $userId');
                          if (isMuted) {
                            print('trying isMuted: $isMuted');
                            await cubit.unmuteUser(Constants.userAccount.userId, userId);
                          } else {
                            await cubit.muteUser(Constants.userAccount.userId, userId);
                          }
                          Navigator.pop(context);
                        },
                        child: Text(isMuted ? 'Unmute' : 'Mute', style: TextStyle(color: Constants.appPrimaryColor),),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: Constants.appPrimaryColor),),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: hasUnseenStory && !isCurrentUser && !isMuted
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
                      Colors.black.withOpacity(isMuted ? 0.7 : 0.5),
                      BlendMode.darken,
                    ),
                    child: Image.network(
                      lastStory.imgURL,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error, color: Colors.red));
                      },
                    ),
                  )
                      : userContent(cubit),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      isCurrentUser ? 'My Story' : (cubit.userNames?[userId] ?? 'No name found'),
                      style: TextStyle(
                          color: isMuted ? Colors.grey : Colors.white,
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
                      backgroundColor: isMuted ? Colors.grey : Constants.appPrimaryColor,
                      child: Text(
                        '${userStories.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (isCurrentUser && userStories.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () {
                       showUploadOptionsDialog(context, cubit);
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Constants.appPrimaryColor,
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                if (isMuted)
                  const Positioned(
                    left: 8,
                    bottom: 8,
                    child: Icon(Icons.volume_off, color: Colors.white, size: 20),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
