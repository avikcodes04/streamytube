import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_client/cubits/auth/auth_cubit.dart';
import 'package:flutter_client/pages/auth/login_page.dart';
import 'package:flutter_client/services/auth_service.dart';
import 'package:flutter_client/utils/utils.dart';

class ConfirmSignupPage extends StatefulWidget {
  final String email;

  static route(String email) =>
      MaterialPageRoute(builder: (context) => ConfirmSignupPage(email: email));
  const ConfirmSignupPage({super.key, required this.email});
  @override
  State<ConfirmSignupPage> createState() => _ConfirmSignupPageState();
}

class _ConfirmSignupPageState extends State<ConfirmSignupPage> {
  late TextEditingController emailController;
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void confirmsignUp() async {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().confirmSignup(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthConfirmSignupSuccess) {
              showSnackBar(
                context,
                state.message,
                icon: Icons.check_circle,
                iconColor: Colors.green,
              );
              Navigator.of(context).push(LoginPage.route());
            } else if (state is AuthError) {
              showSnackBar(
                context,
                state.error,
                icon: Icons.error_rounded,
                iconColor: Colors.red,
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: const CircularProgressIndicator.adaptive());
            }
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    "Confirm Signup.",
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "Email"),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter your email"
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: otpController,
                    decoration: InputDecoration(hintText: "OTP"),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter your OTP"
                        : null,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: confirmsignUp,
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
