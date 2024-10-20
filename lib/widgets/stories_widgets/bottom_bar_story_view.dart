import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Components/components.dart';
import '../../Components/constants.dart';
import '../../cubit/app_states.dart';
import '../../cubit/story_cubit.dart';

Widget bottomNav(BuildContext context,
    TextEditingController replyController, Function sendReply, int index) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DefaultTextField(
            replyOn: true,
            height: 8,
            type: TextInputType.text,
            onChanged: (value) {},
            label: "Reply",
            controller: replyController,
            maxLines: 2,
          ),
        ),

        // Send button
        IconButton(
          icon: Icon(
            Icons.send_rounded,
            size: 32,
            color: Constants.appPrimaryColor,
          ),
          onPressed: () {
            sendReply();
          },
        ),

        // Favorite button
        BlocBuilder<StoryCubit, AppStates>(
          builder: (context, state) {
            final storyCubit = context.read<StoryCubit>();
            final currentStory = storyCubit.stories[index];
            final isFavorited = storyCubit.isStoryFavorited(
                currentStory.id, Constants.userAccount.userId);

            return FloatingActionButton(
              backgroundColor: Constants.appPrimaryColor,
              onPressed: () {
                storyCubit.toggleFavoriteStatus(
                  currentStory.id, Constants.userAccount.userId,
                );
              },
              child: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    ),
  );
}