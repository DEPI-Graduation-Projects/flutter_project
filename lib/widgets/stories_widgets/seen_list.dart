import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import '../../Components/constants.dart';

class SeenList extends StatelessWidget {
  final String storyId;

  SeenList({required this.storyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..getStorySeenBy(storyId),
      child: BlocBuilder<AppCubit, AppStates>(
        builder: (context, state) {
          final appCubit = context.read<AppCubit>();
          final seenCount = appCubit.storySeenByCount(storyId);

          return Scaffold(
            backgroundColor: Constants.appThirColor,
            appBar: AppBar(
              backgroundColor: Constants.appPrimaryColor,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_red_eye, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(seenCount.toString(), style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            body: _buildBody(context, state, appCubit),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppStates state, AppCubit appCubit) {
    if (state is GetStorySeenByLoadingState) {
      return Center(child: CircularProgressIndicator(backgroundColor: Colors.white, color: Constants.appPrimaryColor));
    } else if (state is GetStorySeenByErrorState) {
      return Center(child: Text('Error: ${state}'));
    } else {
      List<String> list = appCubit.storySeenByList(storyId);

      if (list.isEmpty) {
        return Center(child: Text('No one has seen this story.'));
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
        child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.3)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        radius: 25,
                        backgroundImage: appCubit.getUserProfilePhoto(list[index]),
                        child: appCubit.currentUser?.profilePhoto == null
                            ? Icon(Icons.person, color: Colors.white, size: 25)
                            : null,
                      ),
                      SizedBox(width: 10),
                      Text(
                        appCubit.userNames[list[index]] ?? 'No name found',
                        style: TextStyle(fontSize: 16, color: Colors.white),
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