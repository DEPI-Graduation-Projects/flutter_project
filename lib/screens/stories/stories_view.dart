// import 'package:flutter/material.dart';
// import 'package:flutter_project/data/user_story.dart';
// import 'package:flutter_project/screens/stories/story_view.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class StoriesView extends StatelessWidget {
//   final UserStory? story;
//   final bool isUserStory;
//   final VoidCallback? onAddStory;
//
//   const StoriesView({
//     super.key,
//     this.story,
//     required this.isUserStory,
//     this.onAddStory,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     final hasStory = story != null;
//
//     return GestureDetector(
//       onTap: hasStory
//           ? () => Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => StoryView(story: story!)))
//           : onAddStory,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundImage: hasStory
//                     ? NetworkImage(story!.imgURL)
//                     : (currentUser?.photoURL != null
//                     ? NetworkImage(currentUser!.photoURL!)
//                     : null),
//                 child: !hasStory && currentUser?.photoURL == null
//                     ? const Icon(Icons.person, size: 30, color: Colors.white)
//                     : null,
//               ),
//               if (isUserStory && !hasStory)
//                 const Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: CircleAvatar(
//                     radius: 12,
//                     backgroundColor: Colors.blue,
//                     child: Icon(Icons.add, color: Colors.white, size: 15),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 5),
//           Text(
//             isUserStory ? 'Your Story' : (story?.userId ?? ''),
//             style: const TextStyle(fontSize: 12, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }