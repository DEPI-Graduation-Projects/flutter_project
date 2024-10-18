import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';

void showUploadOptionsDialog(BuildContext context, StoryCubit cubit) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Center(child: Text(
          'Upload Story', style: TextStyle(color: Constants.appPrimaryColor),)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                  Icons.photo_library, color: Constants.appPrimaryColor),
              title: const Text(
                  'Upload from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                cubit.pickAndUploadStoryImage(
                    Constants.userAccount.userId, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Constants.appPrimaryColor),
              title: const Text(
                  'Take a Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                cubit.pickAndUploadStoryImage(
                    Constants.userAccount.userId, ImageSource.camera);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                'Cancel', style: TextStyle(color: Constants.appPrimaryColor)),
          ),
        ],
      );
    },
  );
}