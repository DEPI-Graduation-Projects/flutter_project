import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Components/constants.dart';
import '../../cubit/app_states.dart';
import '../../cubit/story_cubit.dart';

Widget userAvatar(BuildContext context, StoryCubit storyCubit, String userId) {
  return BlocBuilder<StoryCubit, AppStates>(
    builder: (context, state) {
      if (state is UserProfilePhotoLoading) {
        return CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.3),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Constants.appPrimaryColor),
          ),
        );
      }

      ImageProvider? profilePhoto = storyCubit.getUserProfilePhoto(userId);
      return CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.3),
        backgroundImage: profilePhoto,
        child: profilePhoto == null
            ? const Icon(Icons.person, color: Colors.white, size: 25)
            : null,
      );
    },
  );
}
