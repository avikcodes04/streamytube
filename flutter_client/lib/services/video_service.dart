import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class VideoService {
  // Video service implementation
  // ========== Fields ==========
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  //String backendUrl = 'http://localhost:8000/upload/video';
  static const bool usePhysicalDevice = false;

  // Your computer's IP address (for physical device testing)
  // Update this with your actual IP: 192.168.0.218
  static const String hostIpAddress = "192.168.0.218";

  String get backendUrl {
    if (Platform.isAndroid) {
      if (usePhysicalDevice) {
        // For physical Android device, use your computer's IP address
        return "http://$hostIpAddress:8000/video";
      } else {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        return "http://10.0.2.2:8000/video";
      }
    } else if (Platform.isIOS) {
      if (usePhysicalDevice) {
        // For physical iOS device, use your computer's IP address
        return "http://$hostIpAddress:8000/video";
      } else {
        // iOS simulator can use localhost
        return "http://localhost:8000/video";
      }
    } else {
      // For Windows, Linux, macOS desktop apps, localhost works
      return "http://localhost:8000/video";
    }
  }

  // ========== Private Methods ==========
  Future<Map<String, String>> _getCookieHeader() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    final headers = {'Content-Type': 'application/json'};
    if (accessToken != null) {
      headers['Cookie'] = 'access_token=$accessToken';
    }
    return headers;
  }

  Future<List<Map<String, dynamic>>> getVideos() async {
    try {
      final res = await http.get(
        Uri.parse("$backendUrl/all"),
        headers: await _getCookieHeader(),
      );
      // print("Response body: ${res.body}"); // Debug print

      print(jsonDecode(res.body)[0]); // Debug print

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['detail'] ?? 'Failed to fetch videos';
      }
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}
