import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/constants.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';

import '../../cubit/story_cubit.dart';
import '../../widgets/stories_widgets/stories_grid.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoryCubit()
        ..getStories()
        ..fetchAllUserNames(),
      child: Scaffold(
        backgroundColor: Constants.appSecondaryColor,
        body: BlocConsumer<StoryCubit, AppStates>(
          listener: (context, state) {
            if (state is PickStoryImageSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Image selected successfully!'),
                  backgroundColor: Constants.appThirColor,
                ),
              );
            } else if (state is UploadStoryImageFailedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Failed to upload story image!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Constants.appThirColor,
                ),
              );
            } else if (state is AddStorySuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Story uploaded successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Constants.appThirColor,
                ),
              );
              StoryCubit.get(context).getStories();
            } else if (state is GetStoriesSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  'Get Stories successfully!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Constants.appThirColor,
              ));
            } else if (state is GetStoriesErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  'Failed to get Stories!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Constants.appThirColor,
              ));
            } else if (state is GetStoriesLoadingState) {
              const Center(child: CircularProgressIndicator());
            } else if (state is UpdateStorySuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  'Marked as Seen!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Constants.appThirColor,
              ));
            } else if (state is UpdateStoryErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  'Failed to Mark as Seen!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Constants.appThirColor,
              ));
            }
          },
          builder: (context, state) {
            var cubit = StoryCubit.get(context);

            return Column(
              children: [
                Expanded(
                  child: storiesGrid(context, cubit),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
