import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_client/cubits/auth/auth_cubit.dart';
import 'package:flutter_client/pages/auth/signup_page.dart';
import 'package:flutter_client/pages/home/home_page.dart';

import 'package:flutter_client/services/auth_service.dart';
import 'package:flutter_client/utils/utils.dart';

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  void loginUser() async {
    // Sign up logic to be implemented
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoginSuccess) {
              showSnackBar(
                context,
                state.message,
                icon: Icons.check_circle,
                iconColor: Colors.green,
              );
              Navigator.of(context).push(HomePage.route());
            } else if (state is AuthError) {
              showSnackBar(
                context,
                state.error,
                icon: Icons.error,
                iconColor: Colors.red,
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    "Log In.",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "Email"),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter your email"
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(hintText: "Password"),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter your password"
                        : null,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: loginUser,
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(SignupPage.route());
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
