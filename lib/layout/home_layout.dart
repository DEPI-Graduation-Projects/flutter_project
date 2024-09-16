import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';

class HomeLayout extends StatefulWidget {
  final AppCubit cubit;
  const HomeLayout({super.key, required this.cubit});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, Appstates>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text("ChatApp"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search))
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: double.infinity,
                padding: const EdgeInsetsDirectional.only(end: 20, start: 5),
                decoration: const BoxDecoration(
                    border: BorderDirectional(
                        end: BorderSide(width: 1, color: Colors.black))),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                    SideNavigationBarItem(
                      fun: () {
                        widget.cubit.changeScreen(0);
                      },
                      icon: Icons.chat,
                      label: "Chats",
                      isSelected: widget.cubit.selectedIndex == 0,
                    ),
                    const SizedBox(height: 15),
                    SideNavigationBarItem(
                      fun: () {
                        widget.cubit.changeScreen(1);
                      },
                      icon: Icons.person,
                      label: "Users",
                      isSelected: widget.cubit.selectedIndex == 1,
                    ),
                    const SizedBox(height: 15),
                    SideNavigationBarItem(
                      fun: () {
                        widget.cubit.changeScreen(2);
                      },
                      icon: Icons.update,
                      label: "Stories",
                      isSelected: widget.cubit.selectedIndex == 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: widget.cubit.pages[widget.cubit.selectedIndex],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}