import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';
import 'package:flutter_project/layout/home_layout.dart';
import 'package:flutter_project/screens/auth/login/login.dart';
import 'package:flutter_project/sharedPref/sharedPrefHelper.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'cubit/story_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
        create: (context) => AppCubit()..getMyData()..fetchAllUsers(),

      ),
        BlocProvider<StoryCubit>(
          create: (context) => StoryCubit()
            ..getStories()
            ..fetchAllUserNames(),
        ),],
      child: BlocBuilder<AppCubit, AppStates>(
        builder: (context, state) {
          AppCubit cubb = AppCubit.get(context);
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: CacheHelper.getUserIdValue() != null
                ? HomeLayout(cubb: cubb)
                : const LoginScreen(
              // cubb: cubb,
            ),
          );
        },
      ),
    );
  }
}
