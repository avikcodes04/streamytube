import 'dart:io';

import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? iconColor,
}) {
  DelightToastBar(
    builder: (context) => ToastCard(
      leading: Icon(icon ?? Icons.info_outline, size: 28, color: iconColor),
      title: Text(
        message,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  ).show(context);
}

Future<File?> pickImage() async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(source: ImageSource.gallery);
  if (xFile != null) {
    // Image selected, you can use xFile.path to get the file path
    return File(xFile.path);
  }
  return null; // No image selected
}

Future<File?> pickVideo() async {
  final picker = ImagePicker();
  final xFile = await picker.pickVideo(source: ImageSource.gallery);
  if (xFile != null) {
    // Image selected, you can use xFile.path to get the file path
    return File(xFile.path);
  }
  return null; // No image selected
}
