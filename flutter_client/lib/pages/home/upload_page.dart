// ========================== IMPORTS ==========================
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_client/color/colorpallete.dart';
import 'package:flutter_client/cubits/upload_video/upload_video_cubit.dart';
import 'package:flutter_client/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// ======================== ROUTE & PAGE =======================
class UploadPage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const UploadPage());
  }

  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

// ========================= PAGE STATE ========================
class _UploadPageState extends State<UploadPage> {
  // ===================== CONTROLLERS =====================
  final TextEditingController titlecontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();
  String visibility = 'PRIVATE';
  File? imageFile;
  File? videoFile;
  @override
  void dispose() {
    super.dispose();
    titlecontroller.dispose();
    descriptioncontroller.dispose();
  }

  void selectImage() async {
    final _imageFile = await pickImage();
    setState(() {
      imageFile = _imageFile;
    });
  }

  void selectVideo() async {
    final _videoFile = await pickVideo();
    setState(() {
      videoFile = _videoFile;
    });
  }

  void uploadVideo() async {
    if (titlecontroller.text.trim().isNotEmpty &&
        descriptioncontroller.text.trim().isNotEmpty &&
        videoFile != null &&
        imageFile != null) {
      await context.read<UploadVideoCubit>().uploadVideo(
        videoFile: videoFile!,
        thumbnailFile: imageFile!,
        title: titlecontroller.text.trim(),
        description: descriptioncontroller.text.trim(),
        visibility: visibility,
      );
    } else {
      showSnackBar(
        context,
        "Please fill all the fields",
        icon: Icons.error,
        iconColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ========================= PAGE SCAFFOLD ========================
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Video")),
      body: BlocConsumer<UploadVideoCubit, UploadVideoState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is UploadVideoSuccess) {
            showSnackBar(context, "Video Uploaded Successfully");
            Navigator.pop(context);
          } else if (state is UploadVideoError) {
            showSnackBar(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state is UploadVideoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ===================== VIDEO UPLOAD BOX ======================
                  GestureDetector(
                    onTap: () {
                      selectVideo();
                    },
                    child: videoFile != null
                        ? DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: [10, 5],
                              strokeWidth: 1.5,
                              padding: EdgeInsets.all(16),
                              radius: Radius.circular(20),
                              color: Colors.grey,
                            ),
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      137,
                                      125,
                                      125,
                                      125,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    "Video Selected: ${videoFile!.path.split('/').last}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: [10, 5],
                              strokeWidth: 1.5,
                              padding: EdgeInsets.all(16),
                              radius: Radius.circular(20),
                              color: Colors.grey,
                            ),
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              // Centered icon & text prompting to upload video
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  Text("Tap to upload video"),
                                ],
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 15),

                  // ==================== THUMBNAIL UPLOAD BOX ===================
                  GestureDetector(
                    onTap: selectImage,
                    child: imageFile != null
                        ? DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: [10, 5],
                              strokeWidth: 1.5,
                              padding: EdgeInsets.all(16),
                              radius: Radius.circular(20),
                              color: Colors.grey,
                            ),
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  imageFile!,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          )
                        : DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: [10, 5],
                              strokeWidth: 1.5,
                              padding: EdgeInsets.all(16),
                              radius: Radius.circular(20),
                              color: Colors.grey,
                            ),
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.video_file_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  Text("Tap to upload thumnail"),
                                ],
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 15),

                  // ===================== TITLE INPUT FIELD =====================
                  TextFormField(
                    controller: titlecontroller,
                    decoration: InputDecoration().copyWith(
                      hintText: "Title",
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                  SizedBox(height: 15),

                  // ================== DESCRIPTION INPUT FIELD ==================
                  TextFormField(
                    controller: descriptioncontroller,
                    decoration: InputDecoration().copyWith(
                      contentPadding: EdgeInsets.all(20),
                      hintText: 'Description',
                    ),
                  ),
                  SizedBox(height: 15),

                  // ===================== VISIBILITY DROPDOWN ====================
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorPalette.bordercolor,
                        width: 3,
                      ),

                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                      value: visibility,
                      underline: SizedBox(),
                      items: ['PUBLIC', 'PRIVATE', 'UNLISTED']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          visibility = value!;
                        });
                      },
                      hint: Text("Select Visibility"),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: uploadVideo,
                    child: Text(
                      "Upload",
                      style: GoogleFonts.bungee(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
