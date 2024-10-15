import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/Components/constants.dart';
import 'package:flutter_project/cubit/app_cubit.dart';
import 'package:flutter_project/cubit/app_states.dart';

import '../../../layout/home_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppCubit cubb = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is UserLoginFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("check you email and password")));
        }
        if (state is UserLoginSuccessState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("LoginSuccess")));
        }
        if (state is GetUserDataSuccessState) {
          print("state is reached ${state.user.name}");

          Constants.userAccount = state.user;
          print("constants name is ${Constants.userAccount.name}");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => HomeLayout(cubb: cubb)));
        } else if (state is UserSignUpSuccessState) {
          Constants.userAccount = state.user;
          print("constants name is ${Constants.userAccount.name}");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => HomeLayout(cubb: cubb)));
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: Constants.appThirColor, // Background color
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Assign the form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Text(
                  "WeLcOmE To LiNk Up ",
                  style: TextStyle(color: Constants.appPrimaryColor),
                ),
                const SizedBox(height: 30),

                // Email Field with validation
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field with validation
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true, // To hide password input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      cubb.appLogin(
                          email: _emailController.text,
                          password: _passwordController.text);
                      print('Logging in with: ${_emailController.text}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                        double.infinity, 50), // Make button full width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 18, color: Constants.appPrimaryColor),
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot Password and Sign Up Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Add forgot password functionality
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Constants.appPrimaryColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          cubb.appSignUp(
                              email: _emailController.text,
                              password: _passwordController.text,
                              userName: "wahba");
                        }

                        // Add sign up navigation
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Constants.appPrimaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
