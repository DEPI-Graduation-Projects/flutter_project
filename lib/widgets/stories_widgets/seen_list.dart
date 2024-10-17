import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_states.dart';

import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';
Widget seenList(
    BuildContext context, AppStates state, StoryCubit StoryCubit, String storyId) {
  if (state is GetStorySeenByLoadingState) {
    return Center(
        child: CircularProgressIndicator(
            backgroundColor: Colors.white, color: Constants.appPrimaryColor));
  } else if (state is GetStorySeenByErrorState) {
    return Center(child: Text('Error: $state'));
  } else {
    List<String> list = StoryCubit.storySeenByList(storyId);

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: const Center(child: Text('No one has seen this story.', style:
            const TextStyle(fontSize: 16, color: Colors.white),)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
      child: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.3)),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      radius: 25,
                      backgroundImage:
                      StoryCubit.getUserProfilePhoto(list[index]),
                      child: StoryCubit.currentUser?.profilePhoto == null
                          ? const Icon(Icons.person,
                          color: Colors.white, size: 25)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      StoryCubit.userNames?[list[index]] ?? 'No name found',
                      style:
                      const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
