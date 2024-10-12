import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import '../../widgets/stories_widgets/stories_grid.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..getStories()..fetchAllUserNames(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Stories'),
        ),
        body: BlocConsumer<AppCubit, AppStates>(
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

            return Column(
              children: [
                Expanded(
                  child: state is GetStoriesLoadingState
                      ? const Center(child: CircularProgressIndicator())
                      : state is GetStoriesSuccessState ? storiesGrid(context, cubit)
                      : const Center(child: Text('No stories available')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}