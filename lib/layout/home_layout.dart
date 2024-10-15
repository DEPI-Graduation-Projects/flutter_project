import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/constants.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/screens/auth/login/login.dart';
import 'package:flutter_project/screens/user/my_account/user_details_screen.dart';
import 'package:flutter_project/sharedPref/sharedPrefHelper.dart';

class HomeLayout extends StatefulWidget {
  final AppCubit cubb;
  const HomeLayout({super.key, required this.cubb});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with WidgetsBindingObserver {
  bool setOnline = true;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // widget.cubb.getMyData();
    WidgetsBinding.instance.addObserver(this);
    // Set the user as online when the app starts
    widget.cubb.setUserOnline(CacheHelper.getUserIdValue()!);
    // Handle the disconnection case
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Mark user as offline when the app goes to background
      widget.cubb.setUserOffline(CacheHelper.getUserIdValue()!);
    } else if (state == AppLifecycleState.resumed) {
      // Mark user as online when the app is resumed
      widget.cubb.setUserOnline(CacheHelper.getUserIdValue()!);
    }
  }

  // void changeUser() {
  //   setState(() {
  //     userId = isMe ? "22010237" : "22010289";
  //     AppCubit.userId = isMe ? "22010237" : "22010289";
  //     print(AppCubit.userId);
  //     widget.cubb.setUserOnline(userId);
  //     widget.cubb.setUserOffline(!isMe ? "22010237" : "22010289");
  //     isMe = !isMe;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
        backgroundColor: Constants.appThirColor,
        appBar: AppBar(
          backgroundColor: Constants.appThirColor,
          title: const Text(
            "Link Up ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserDetailsScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2, color: Constants.appPrimaryColor)),
                  width: 50,
                  height: 50,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                          width: 39,
                          height: 41,
                          fit: BoxFit.cover,
                          imageUrl: Constants.userAccount.profilePhoto!),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ));
                  CacheHelper.sharedPreferences!.clear();
                },
                icon: const Icon(Icons.exit_to_app))
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: widget.cubb.selectedIndex,
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.chat),
              label: 'Chats',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.person),
              label: 'Users',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.update),
              label: 'Stories',
            ),
          ],
          color: Constants.appThirColor,
          buttonBackgroundColor: Colors.black,
          backgroundColor: Constants.appPrimaryColor,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: (index) {
            widget.cubb.changeScreen(index);
          },
          letIndexChange: (index) => true,
        ),
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 9, // Expands the shadow
                          blurRadius: 2, // Smoothens the shadow
                          offset: const Offset(
                              5, 6), // Controls the shadow's position
                        )
                      ],
                      border: Border.all(
                          color: Constants.appPrimaryColor, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: widget.cubb.screens[widget.cubb.selectedIndex],
                  ),
                ),
                // Container(
                //   height: 75,
                //   width: double.infinity,
                //   padding: const EdgeInsetsDirectional.only(end: 20, start: 5),
                //   decoration: const BoxDecoration(

                //       // border: BorderDirectional(
                //       //     end: BorderSide(
                //       //         style: BorderStyle.none, color: Colors.black)
                //       //         )
                //       ),
                //   child: Row(
                //     children: [
                //       SideNavigationBarItem(
                //         onClick: () {
                //           widget.cubb.changeScreen(0);
                //         },
                //         icon: Icons.chat,
                //         label: "Chats",
                //         isSelected: widget.cubb.selectedIndex == 0,
                //       ),
                //       const SizedBox(height: 15),
                //       SideNavigationBarItem(
                //         onClick: () {
                //           widget.cubb.changeScreen(1);
                //         },
                //         icon: Icons.person,
                //         label: "Friends",
                //         isSelected: widget.cubb.selectedIndex == 1,
                //       ),
                //       const SizedBox(height: 15),
                //       SideNavigationBarItem(
                //         onClick: () {
                //           widget.cubb.changeScreen(2);
                //         },
                //         icon: Icons.update,
                //         label: "Stories",
                //         isSelected: widget.cubb.selectedIndex == 2,
                //       ),
                //       const SizedBox(height: 15),
                //       // IconButton(
                //       //     onPressed: () {
                //       //       // setState(() {
                //       //       //   changeUser();
                //       //       // });
                //       //     },
                //       //     icon: const Icon(Icons.swap_calls))
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
