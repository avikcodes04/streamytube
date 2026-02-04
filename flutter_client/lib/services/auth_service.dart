import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  // Configuration: Set to true when testing on physical device, false for emulator/simulator
  static const bool usePhysicalDevice = false;

  // Your computer's IP address (for physical device testing)
  // Update this with your actual IP: 192.168.0.218
  static const String hostIpAddress = "192.168.0.218";

  String get backendUrl {
    if (Platform.isAndroid) {
      if (usePhysicalDevice) {
        // For physical Android device, use your computer's IP address
        return "http://$hostIpAddress:8000/auth";
      } else {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        return "http://10.0.2.2:8000/auth";
      }
    } else if (Platform.isIOS) {
      if (usePhysicalDevice) {
        // For physical iOS device, use your computer's IP address
        return "http://$hostIpAddress:8000/auth";
      } else {
        // iOS simulator can use localhost
        return "http://localhost:8000/auth";
      }
    } else {
      // For Windows, Linux, macOS desktop apps, localhost works
      return "http://localhost:8000/auth";
    }
  }

  Future<Map<String, String>> _getCookieHeader() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    final refreshToken = await secureStorage.read(key: 'refresh_token');
    final userCognitoSub = await secureStorage.read(key: 'user_cognito_sub');

    final headers = {'Content-Type': 'application/json'};

    if (accessToken != null) {
      headers['Cookie'] = 'access_token=$accessToken';

      if (refreshToken != null) {
        headers['Cookie'] = '${headers['Cookie']};refresh_token=$refreshToken';
        if (userCognitoSub != null) {
          headers['Cookie'] =
              '${headers['Cookie']};user_cognito_sub=$userCognitoSub';
        }
      }
    }

    return headers;
  }

  Future<void> _storeCookies(http.Response res) async {
    String? cookies = res.headers['set-cookie'];
    if (cookies != null) {
      final accessTokenMatch = RegExp(
        r'access_token=([^;]+)',
      ).firstMatch(cookies);
      if (accessTokenMatch != null) {
        // print("The access token is:");
        // print(accessTokenMatch.group(1));
        await secureStorage.write(
          key: 'access_token',
          value: accessTokenMatch.group(1),
        );
      }

      final refreshTokenMatch = RegExp(
        r'refresh_token=([^;]+)',
      ).firstMatch(cookies);
      if (refreshTokenMatch != null) {
        // print("The refresh token is:");
        // print(refreshTokenMatch.group(1));
        await secureStorage.write(
          key: 'refresh_token',
          value: refreshTokenMatch.group(1),
        );
      }
    }
  }

  Future<String> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$backendUrl/signup"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw jsonDecode(res.body)['detail'];
    }
    return jsonDecode(res.body)['message'];
  }

  Future<String> confirmSignup({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse("$backendUrl/confirm-signup"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    print("The headers: ${res.headers}");
    // Handle different status codes
    if (res.statusCode == 200) {
      // Success - return custom success message
      return 'Sign up confirmed successfully! You can now sign in.';
    } else if (res.statusCode == 400) {
      // Bad request - extract error detail
      final errorBody = jsonDecode(res.body);
      if (errorBody is Map && errorBody.containsKey('detail')) {
        throw errorBody['detail'] ?? 'Invalid OTP or request';
      }
      throw 'Invalid OTP. Please check and try again.';
    } else if (res.statusCode == 404) {
      // Not found
      throw 'User not found. Please sign up first.';
    } else if (res.statusCode >= 500) {
      // Server error
      throw 'Server error. Please try again later.';
    } else {
      // Other errors
      final errorBody = jsonDecode(res.body);
      if (errorBody is Map && errorBody.containsKey('detail')) {
        throw errorBody['detail'] ?? 'An error occurred';
      }
      throw 'An error occurred. Please try again.';
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$backendUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    //print("The headers: ${res.headers}");
    await _storeCookies(res);
    isAuthenticated();
    if (res.statusCode != 200) {
      print(res.body);
      throw jsonDecode(res.body)['detail'] ?? 'An error occurred!';
    }
    return jsonDecode(res.body)['message'] ?? 'Login successful';
  }

  Future<String> refreshToken() async {
    final cookieHeaders = await _getCookieHeader();

    final res = await http.post(
      Uri.parse("$backendUrl/refresh"),
      headers: cookieHeaders,
    );

    if (res.statusCode != 200) {
      throw jsonDecode(res.body)['detail'] ?? 'An error occurred!';
    }
    await _storeCookies(res);

    return jsonDecode(res.body)['message'] ?? 'Login successful';
  }

  Future<bool> isAuthenticated({int count = 0}) async {
    if (count > 1) {
      return false;
    }
    final cookieHeaders = await _getCookieHeader();

    final res = await http.get(
      Uri.parse("$backendUrl/me"),
      headers: cookieHeaders,
    );
    print(jsonDecode(res.body)['user']);
    if (res.statusCode != 200) {
      await refreshToken();
      isAuthenticated(count: count + 1);
    } else {
      await secureStorage.write(
        key: 'user_cognito_sub',
        value: jsonDecode(res.body)['user']['sub'],
      );
    }
    return res.statusCode == 200;
  }
}
