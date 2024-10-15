import 'package:flutter/material.dart';

import '../../Components/constants.dart';

Widget buildSeenButton(String text, VoidCallback? onPressed) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Constants.appPrimaryColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.remove_red_eye,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ],
      ),
    ),
  );
}
