import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/components.dart';
import 'package:flutter_project/Components/constants.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/models/user_model.dart';
import 'package:toggle_switch/toggle_switch.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppCubit.get(context).getallUsers();
  }

  TextEditingController userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    AppCubit cubb = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AddFriendLoadingState) {
          LoadingAlert.showLoadingDialogUntilState(
              context: context, cubit: cubb, targetState: state);
        } else if (state is AddFriendSuccessState) {
          cubb = AppCubit.get(context);
          Navigator.pop(context);
          cubb.getMyData();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.add ? "Friend Added " : "UnFriended"),
          ));
        }
      },
      builder: (context, state) => SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, right: 10, left: 10),
              child: DefaultTextField(
                  onChanged: (value) {
                    cubb.filterUsers(value);
                  },
                  replyOn: false,
                  type: TextInputType.text,
                  label: 'Search user',
                  controller: userNameController),
            ),
            const SizedBox(
              height: 30,
            ),
            ToggleSwitch(
              initialLabelIndex: cubb.choosenFilter,
              minWidth: 100.0,
              dividerColor: Colors.white,
              totalSwitches: 2,
              labels: const ['All Users', 'Friends'],
              activeBgColor: [Constants.appPrimaryColor],
              inactiveFgColor: Colors.white,
              inactiveBgColor: Colors.black,
              activeFgColor: Colors.black,
              onToggle: (index) {
                print(' index is $index');
                index != null ? cubb.filterFriends(index) : null;
              },
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return userItem(cubb: cubb, user: cubb.filteredUsers[index]);
                },
                itemCount: cubb.filteredUsers.length,
              ),
            ),
            const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget userItem({
    required UserModel user,
    required AppCubit cubb,
  }) {
    return GestureDetector(
      child: Card(
        color: Constants.appSecondaryColor,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 5, end: 5),
          leading: Stack(
            children: [
              const CircleAvatar(
                radius: 25,
                child: Icon(Icons.person),
              ),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: user.status ? Colors.green : Colors.red,
                    ),
                  ))
            ],
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user.userId),
          trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Constants.userAccount.friends.contains(user.userId)
                          ? Colors.red
                          : Colors.green),
              clipBehavior: Clip.none,
              onPressed: () {
                Constants.userAccount.friends.contains(user.userId)
                    ? cubb.unFriend(friendUserId: user.userId)
                    : cubb.addFriend(friendUserId: user.userId);
              },
              child: Text(
                Constants.userAccount.friends.contains(user.userId)
                    ? "Unfriend"
                    : 'Add Friend',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              )),
        ),
      ),
    );
  }
}
