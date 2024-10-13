import 'package:flutter/material.dart';
import 'package:flutter_project/cubit/app_cubit.dart';

Widget SeenList(String storyId, int seenCount) {
  AppCubit cubit = AppCubit();
  final userProfilePhoto = cubit.currentUser?.profilePhoto;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,
      leading: Icon(
        Icons.remove_red_eye,
        color: Colors.white,
        size: 20,
      ),
      title: Text(seenCount.toString(), style: TextStyle(color: Colors.white),),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<String>>(
        future: cubit.getStorySeenBy(storyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No one has seen this story.'));
          } else {
            List<String> list = snapshot.data!;
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 25,
                        backgroundImage: cubit.getUserProfilePhoto(list[index]),
                        child: userProfilePhoto == null
                            ? Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 25,
                        )
                            : null,
                      ),
                      SizedBox(width: 10),
                      Text(
                        cubit.userNames[list[index]] ?? 'No name found',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    ),
  );
}