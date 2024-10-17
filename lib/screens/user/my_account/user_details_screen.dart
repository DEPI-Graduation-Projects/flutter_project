import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Components/constants.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppCubit cubb = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is UploadChatImageLoadingState) {
          LoadingAlert.showLoadingDialogUntilState(
              context: context, cubit: cubb, targetState: state);
        } else if (state is UpdateChatWallpapperSuccessState) {
          Navigator.pop(context);
        }
        if (state is UpdateUserProfileSuccessState) {
          Navigator.pop(context);
          Navigator.pop(context);

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("picture updated ")));
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Picture
                GestureDetector(
                  onTap: () {
                    FullScreenImageViewer.showFullImage(
                        context, Constants.userAccount.profilePhoto!);
                  },
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(Constants.userAccount
                          .profilePhoto!) // Placeholder for user image
                      ),
                ),
                const SizedBox(height: 10),

                // Button to change profile picture
                TextButton.icon(
                  onPressed: () {
                    // Implement logic to change profile picture here
                    final picker = ImagePicker();
                    picker.pickImage(source: ImageSource.gallery).then((value) {
                      if (value != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Container(
                                height: double.infinity,
                                color: Colors.black,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: FullScreenImageViewer(
                                          "", File(value.path),
                                          type: false),
                                    ),
                                    state is UploadChatImageLoadingState ||
                                            state
                                                is UpdateChatWallpapperLoadingState
                                        ? const CircularProgressIndicator()
                                        : TextButton(
                                            onPressed: () {
                                              cubb
                                                  .uploadChatimage(
                                                      file: File(value.path))
                                                  .then((onValue) {
                                                cubb.updateUserProfile(
                                                    Constants
                                                        .userAccount.userId,
                                                    onValue);
                                              });
                                            },
                                            child: const Text(
                                              "update User Profile",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))
                                  ],
                                ),
                              ),
                            ));
                      }
                      debugPrint("Image Picked");
                    });
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: Constants.appPrimaryColor,
                  ),
                  label: Text(
                    "Change Profile Picture",
                    style: TextStyle(color: Constants.appPrimaryColor),
                  ),
                ),
                const SizedBox(height: 20),

                // User Name
                TextFormField(
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                  ),
                  initialValue:
                      Constants.userAccount.name, // Example initial value
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  enabled: false,

                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  initialValue:
                      Constants.userAccount.email, // Example initial value
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  enabled: false,

                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  initialValue:
                      Constants.userAccount.password, // Example initial value
                ),
                const SizedBox(height: 20),

                // User ID (read-only)
                TextFormField(
                  enabled: false,

                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: Constants.userAccount.userId, // Example user ID
                  readOnly: true, // Disable editing for user ID
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
