// ================== Imports ==================
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// ================== UploadVideoService Class ==================
class UploadVideoService {
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
        return "http://$hostIpAddress:8000/upload/video";
      } else {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        return "http://10.0.2.2:8000/upload/video";
      }
    } else if (Platform.isIOS) {
      if (usePhysicalDevice) {
        // For physical iOS device, use your computer's IP address
        return "http://$hostIpAddress:8000/upload/video";
      } else {
        // iOS simulator can use localhost
        return "http://localhost:8000/upload/video";
      }
    } else {
      // For Windows, Linux, macOS desktop apps, localhost works
      return "http://localhost:8000/upload/video";
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

  // ========== Public Methods ==========
  // Future<Map<String, dynamic>> getPresignedUrlForThumbnail() async {
  //   final res = await http.get(
  //     Uri.parse("$backendUrl/url/thumbnail"),
  //     headers: await _getCookieHeader(),
  //   );
  //   if (res.statusCode == 200) {
  //     // Successfully got presigned URL
  //     return jsonDecode(res.body) as Map<String, dynamic>;
  //   } else {
  //     throw jsonDecode(res.body)['detail'];
  //   }
  // }

  Future<Map<String, dynamic>> getPresignedUrlForThumbnail(
    String thumbnailid,
  ) async {
    final headers = await _getCookieHeader();
    final res = await http.get(
      Uri.parse("$backendUrl/url/thumbnail?video_id=$thumbnailid"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to get thumbnail presigned URL");
    }
  }

  Future<Map<String, dynamic>> getPresignedUrlForVideo() async {
    final res = await http.get(
      Uri.parse("$backendUrl/url"),
      headers: await _getCookieHeader(),
    );
    if (res.statusCode == 200) {
      // Successfully got presigned URL
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw jsonDecode(res.body)['detail'];
    }
  }

  // Future<bool> uploadFileToS3({
  //   required String presignedUrl,
  //   required File file,
  //   required bool isVideo,
  // }) async {
  //   final res = await http.put(
  //     Uri.parse(presignedUrl),
  //     headers: {'Content-Type': isVideo ? 'video/mp4' : 'image/jpg'},
  //     body: file.readAsBytesSync(),
  //   );
  //   return res.statusCode == 200;
  // }
  Future<bool> uploadFileToS3({
    required String presignedUrl,
    required File file,
    required bool isVideo,
  }) async {
    final res = await http.put(
      Uri.parse(presignedUrl),
      headers: {
        'Content-Type': isVideo ? 'video/mp4' : 'image/jpg',
        if (!isVideo) 'x-amz-acl': 'public-read',
      },
      body: await file.readAsBytes(),
    );

    print(' upload file to s3 : response \n ${res.body} ');

    debugPrint("S3 upload status: ${res.statusCode}");
    debugPrint("S3 upload body: ${res.body}");

    return res.statusCode == 200;
  }

  Future<bool> uploadMetadata({
    required String title,
    required String description,
    required String visibility,
    required String s3key,
  }) async {
    final res = await http.post(
      Uri.parse("$backendUrl/metadata"),
      headers: await _getCookieHeader(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'visibility': visibility,
        'video_id': s3key,
        'video_s3_key': s3key,
      }),
    );
    return res.statusCode == 200;
  }
}
