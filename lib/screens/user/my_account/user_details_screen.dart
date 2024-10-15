import 'package:flutter/material.dart';

import '../../../Components/constants.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.appThirColor,
      body: Center(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Center(
              child: Text("Hello ${Constants.userAccount.name}"),
            )),
      ),
    );
  }
}
