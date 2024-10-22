import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Components/components.dart';
import '../../Components/constants.dart';
import '../../cubit/app_states.dart';
import '../../cubit/story_cubit.dart';

Widget bottomNav(BuildContext context,
    TextEditingController replyController, Function sendReply, String storyId) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: DefaultTextField(
              replyOn: true,
              height: 8,
              type: TextInputType.text,
              onChanged: (value) {},
              label: "Reply",
              controller: replyController,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.send_rounded,
            size: 24,
            color: Constants.appPrimaryColor,
          ),
          onPressed: () {
            sendReply();
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        BlocBuilder<StoryCubit, AppStates>(
          builder: (context, state) {
            final storyCubit = context.read<StoryCubit>();
            final isFavorited = storyCubit.isStoryFavorited(
                storyId, Constants.userAccount.userId);

            return FloatingActionButton(
              backgroundColor: Constants.appPrimaryColor,
              onPressed: () {
                storyCubit.toggleFavoriteStatus(
                  storyId, Constants.userAccount.userId,
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