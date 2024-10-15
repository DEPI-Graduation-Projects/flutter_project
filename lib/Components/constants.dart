import 'package:flutter/material.dart';
import 'package:flutter_project/models/user_model.dart';

class Constants {
  static final Color appPrimaryColor = Colors.amber.shade700;
  static final Color appSecondaryColor = Colors.black.withOpacity(0.2);
  static final appThirColor =
      Color.alphaBlend(Colors.black.withOpacity(0.6), Colors.blueGrey.shade900);
  static late UserModel userAccount;
  static const String chatWallpaper =
      "https://th.bing.com/th/id/OIF.csGcQuy19CVl9ZrjLxBflw?rs=1&pid=ImgDetMain";
  static const String defaultProfilePic =
      "https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png";
}
