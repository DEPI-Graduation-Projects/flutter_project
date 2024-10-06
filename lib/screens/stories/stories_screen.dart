import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/app_cubit.dart';
import '../../cubit/app_states.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppCubit cubit = AppCubit.get(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.getUserName(cubit.userId);
    });

    return BlocProvider(
      create: (context) =>
          AppCubit()..getStories(cubit.userId), // Load stories on init
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stories'),
        ),
        body: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {
            if (state is PickStoryImageSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image selected successfully!')),
              );
            } else if (state is UploadStoryImageFailedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload story image!')),
              );
            } else if (state is AddStorySuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Story uploaded successfully!')),
              );
              // Refresh stories after upload
              AppCubit.get(context).getStories(cubit.userId);
            }
          },
          builder: (context, state) {
            var cubit = AppCubit.get(context);

            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    cubit.pickAndUploadStoryImage(cubit.userId);
                  },
                  child: Text('Add Story'),
                ),
                Expanded(
                    child: state is GetStoriesLoadingState
                        ? Center(child: CircularProgressIndicator())
                        : state is GetStoriesSuccessState &&
                                cubit.stories.isNotEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                      childAspectRatio: 0.65,
                                ),
                                itemCount: cubit.stories.length,
                                itemBuilder: (context, index) {
                                  return Card(
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
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          cubit.currentUser?.name ?? 'Loading...',
                                        style: TextStyle(color: Colors.white),),
                                      ),
                                        ]
                                    ),

                                  );
                                },
                              )
                            : Center(child: CircularProgressIndicator())),
              ],
            );
          },
        ),
      ),
    );
  }
}
