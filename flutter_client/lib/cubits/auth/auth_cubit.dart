import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_client/services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final AuthService authService = AuthService();

  void signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final res = await authService.signUpUser(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthSignupSuccess(res));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void confirmSignup({required String email, required String otp}) async {
    emit(AuthLoading());
    try {
      final res = await authService.confirmSignup(email: email, otp: otp);
      emit(AuthConfirmSignupSuccess(res));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void loginUser({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final res = await authService.login(email: email, password: password);
      emit(AuthLoginSuccess(res));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void isAuthenticated({int count = 0}) async {
    emit(AuthLoading());
    try {
      final res = await authService.isAuthenticated();
      if (res) {
        emit(AuthLoginSuccess('User is authenticated'));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
