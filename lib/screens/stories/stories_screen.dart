import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/screens/stories/story_view.dart';

import '../../data/user_story.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppCubit.get(context).getStories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is PickStoryImageSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image selected successfully!')),
          );
        } else if (state is UploadStoryImageFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload story image!')),
          );
        } else if (state is AddStorySuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Story uploaded successfully!')),
          );
          AppCubit.get(context).getStories();
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Stories'),
          ),
          body: Column(
            children: [
              Expanded(
                child: state is GetStoriesLoadingState
                    ? const Center(child: CircularProgressIndicator())
                    : state is GetStoriesSuccessState &&
                            cubit.stories.isNotEmpty
                        ? _buildStoriesGrid(context, cubit)
                        : const Center(child: Text('No stories available')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoriesGrid(BuildContext context, AppCubit cubit) {
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

    final currentUserId = AppCubit.userId;
    final userIds = groupedStories.keys.toList()
      ..remove(currentUserId)
      ..insert(0, currentUserId);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: userIds.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddStoryCard(context, cubit);
        } else {
          final userId = userIds[index - 1];
          final userStories = groupedStories[userId]!;
          return _buildUserStoryCard(context, cubit, userStories, userId);
        }
      },
    );
  }

  Widget _buildUserStoryCard(BuildContext context, AppCubit cubit,
      List<UserStory> userStories, String userId) {
    final lastStory = userStories.first;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryView(
              stories: userStories,
              initialIndex: 0,
            ),
          ),
        );
      },
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
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
                child: Image.network(
                  lastStory.imgURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  // cubit.getUserName(userId).toString(),
                  cubit.currentUser?.name ?? 'Unknown',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Text(
                  '${userStories.length}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStoryCard(BuildContext context, AppCubit cubit) {
    return GestureDetector(
      onTap: () {
        cubit.pickAndUploadStoryImage(AppCubit.userId);
      },
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
              child: _buildUserContent(cubit),
            ),
            const Positioned(
              right: 8,
              top: 15,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Add Story',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserContent(AppCubit cubit) {
    final userProfilePhoto = cubit.currentUser?.profilePhoto;
    if (userProfilePhoto != null) {
      return Image.network(
        userProfilePhoto,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.person,
          color: Colors.grey,
          size: 100,
        ),
      );
    }
  }
}
