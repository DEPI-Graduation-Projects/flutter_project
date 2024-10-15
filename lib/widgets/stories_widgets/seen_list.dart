import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_states.dart';

import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';

class SeenList extends StatelessWidget {
  final String storyId;

  const SeenList({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoryCubit()..getStorySeenBy(storyId),
      child: BlocBuilder<StoryCubit, AppStates>(
        builder: (context, state) {
          final storyCubit = context.read<StoryCubit>();
          final seenCount = storyCubit.storySeenByCount(storyId);

          return Scaffold(
            backgroundColor: Constants.appThirColor,
            appBar: AppBar(
              backgroundColor: Constants.appPrimaryColor,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_red_eye,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(seenCount.toString(),
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            body: _buildBody(context, state, storyCubit),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AppStates state, StoryCubit StoryCubit) {
    if (state is GetStorySeenByLoadingState) {
      return Center(
          child: CircularProgressIndicator(
              backgroundColor: Colors.white, color: Constants.appPrimaryColor));
    } else if (state is GetStorySeenByErrorState) {
      return Center(child: Text('Error: $state'));
    } else {
      List<String> list = StoryCubit.storySeenByList(storyId);

      if (list.isEmpty) {
        return const Center(child: Text('No one has seen this story.'));
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
}
