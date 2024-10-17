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
    WidgetsBinding.instance.addObserver(this);
    widget.cubb.setUserOnline(CacheHelper.getUserIdValue()!);
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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                            width: 39,
                            height: 41,
                            fit: BoxFit.cover,
                            imageUrl: state is GetUserDataSuccessState
                                ? Constants.userAccount.profilePhoto!
                                : Constants.defaultProfilePic),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    await widget.cubb
                        .setUserOffline(CacheHelper.getUserIdValue()!);

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
          body: Column(
            mainAxisSize: MainAxisSize.max,
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
                    border:
                        Border.all(color: Constants.appPrimaryColor, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: widget.cubb.screens[widget.cubb.selectedIndex],
                ),
              ),
            ],
          )),
    );
  }
}
