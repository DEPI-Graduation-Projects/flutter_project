import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';
import '../../cubit/app_states.dart';
import 'seen_listTile.dart';
import 'user_avatar.dart';

Widget seenList(BuildContext context, AppStates state, StoryCubit storyCubit, String storyId) {
  if (state is GetStorySeenByLoadingState || state is GetAllUsersLoadingState) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        color: Constants.appPrimaryColor,
      ),
    );
  } else if (state is GetStorySeenByErrorState || state is GetAllUsersErrorState) {
    return Center(child: Text('Error: $state'));
  }

  List<String> seenList = storyCubit.storySeenByList(storyId);

  if (seenList.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: Text(
          'No one has seen this story.',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: seenList.length,
      itemBuilder: (context, index) {
        String userId = seenList[index];
        return userListTile(context, storyCubit, userId, storyId);
      },
    ),
  );
}

