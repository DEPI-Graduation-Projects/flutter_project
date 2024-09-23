import 'package:flutter/material.dart';

class AddStory extends StatelessWidget {

  final VoidCallback onPressed;

  const AddStory({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: const Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Icon(Icons.add, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text('Add Story', style: TextStyle(fontSize: 12, color: Colors.white),),
        ],
      ),
    );
  }
}
