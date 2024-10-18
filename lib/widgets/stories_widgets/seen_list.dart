import 'package:flutter/material.dart';
import 'package:flutter_project/cubit/app_states.dart';

import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';

Widget seenList(
    BuildContext context, AppStates state, StoryCubit storyCubit, String storyId) {
  if (state is GetStorySeenByLoadingState) {
    return Center(
        child: CircularProgressIndicator(
            backgroundColor: Colors.white, color: Constants.appPrimaryColor));
  } else if (state is GetStorySeenByErrorState) {
    return Center(child: Text('Error: $state'));
  } else {
    List<String> seenList = storyCubit.storySeenByList(storyId);


    if (seenList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: Text('No one has seen this story.',
            style: TextStyle(fontSize: 16, color: Colors.white))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: seenList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
            child: Card(
              color: Colors.white.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage: storyCubit.getUserProfilePhoto(seenList[index]),
                  child: storyCubit.currentUser?.profilePhoto == null
                      ? const Icon(Icons.person, color: Colors.white, size: 25)
                      : null,
                ),
                title: Text(
                  storyCubit.userNames?[seenList[index]] ?? 'No name found',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: storyCubit.isStoryFavorited(storyId, seenList[index]) ? Icon(Icons.favorite, color: Constants.appPrimaryColor,) : SizedBox.shrink(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          );
        },
      ),
    );
  }
}