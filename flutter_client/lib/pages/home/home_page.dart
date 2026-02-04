import 'package:flutter/material.dart';
import 'package:flutter_client/pages/home/upload_page.dart';
import 'package:flutter_client/pages/home/video_player_page.dart';

import 'package:flutter_client/services/video_service.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static route() {
    return MaterialPageRoute(builder: (context) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VideoService videoService = VideoService();
  final videoFuture = VideoService().getVideos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Streammytube",
          style: GoogleFonts.afacad(fontWeight: FontWeight.w700, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, UploadPage.route());
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: videoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "No videos posted \nyet, ${snapshot.error.toString()}",
              ),
            );
          }
          print("this is ${snapshot.data}");
          final videos = snapshot.data;
          print(snapshot.data);
          return ListView.builder(
            itemCount: videos!.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final video_title = video["title"];
              // final thumbnail =
              //     "https://aviksinha-video-thumbnails.s3.us-east-2.amazonaws.com/${video['video_s3_key'].replaceAll('.mp4', ".jpg").replaceAll("videos/", "thumbnails/")}";
              final thumbnail =
                  "https://d1wlz8rn8mrw8r.cloudfront.net/${video['video_s3_key'].replaceAll('.mp4', ".jpg").replaceAll("videos/", "thumbnails/")}";
              return GestureDetector(
                onDoubleTap: () {
                  Navigator.push(context, VideoPlayerPage.route(video));
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(thumbnail, fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 5, 0, 0),
                        child: Text(
                          video_title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
