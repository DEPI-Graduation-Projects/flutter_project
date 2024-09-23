import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/screens/chats/chat_screen/chats_screen.dart';
import 'package:flutter_project/screens/stories/stories_screen.dart';
import 'package:flutter_project/screens/user/user_screen/user_screen.dart';

import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitState());
  static AppCubit get(BuildContext context) => BlocProvider.of(context);

  final pages = [
    const ChatsScreen(),
    const UserScreen(),
     StoriesScreen()
  ];
  int selectedIndex = 0;
  void changeScreen(index) {
    selectedIndex = index;
    emit(ChangeScreenState());
  }
}
