import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/stories_widgets/upload_story.dart';
import 'package:flutter_project/widgets/stories_widgets/user_content.dart';

import '../../Components/constants.dart';
import '../../cubit/story_cubit.dart';

Widget addStoryCard(BuildContext context, StoryCubit cubit) {
  return GestureDetector(
    onTap: () {
      showUploadOptionsDialog(context, cubit);
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
          Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Constants.appPrimaryColor,
              child: const Icon(Icons.add, color: Colors.white, size: 20),
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

// void showUploadOptionsDialog(BuildContext context, StoryCubit cubit) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.grey[800],
//         title: Center(child: Text('Upload Story', style: TextStyle(color: Constants.appPrimaryColor),)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.photo_library, color: Constants.appPrimaryColor),
//               title: const Text('Upload from Gallery', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 // Close the dialog
//                 Navigator.pop(context);
//                 // Call the method to pick an image from the gallery
//                 showUploadOptionsDialog(context, cubit);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.camera_alt, color: Constants.appPrimaryColor),
//               title: const Text('Take a Photo', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 // Call the method to take a photo
//                 _showUploadOptionsDialog(context, cubit);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: TextStyle(color: Constants.appPrimaryColor)),
//           ),
//         ],
//       );
//     },
//   );
//
// }
