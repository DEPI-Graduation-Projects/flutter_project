import 'package:flutter/material.dart';
import 'package:flutter_project/cubit/story_cubit.dart';

import '../../Components/constants.dart';

Widget userContent(StoryCubit cubit) {
  final userProfilePhoto = Constants.userAccount.profilePhoto;
  if (userProfilePhoto != null) {
    return Image.network(
      userProfilePhoto,
      fit: BoxFit.cover,
    );
  } else {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 100,
      ),
    );
  }
}
