import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/stories_widgets/user_content.dart';

import '../../cubit/app_cubit.dart';

Widget addStoryCard(BuildContext context, AppCubit cubit) {
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
            child: userContent(cubit),
          ),
          const Positioned(
            right: 8,
            top: 8,
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