import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class VideoPlayerPage extends StatefulWidget {
  static route(Map<String, dynamic> video) =>
      MaterialPageRoute(builder: (context) => VideoPlayerPage(video: video));
  final Map<String, dynamic> video;
  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late BetterPlayerController betterPlayerController;
  @override
  void initState() {
    super.initState();
    final videoId = widget.video['video_s3_key'];
    final playbackUrl =
        "https://d1bhzxwuliubab.cloudfront.net/$videoId/manifest.mpd";
    debugPrint("VideoPlayerPage playback URL: $playbackUrl");
    betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePlayPause: true,
          enableProgressBar: true,
          enableQualities: true,
          enableProgressBarDrag: true,

          enableMute: true,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
        playbackUrl,
        videoFormat: BetterPlayerVideoFormat.dash,
      ),
    );
  }

  @override
  void dispose() {
    betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          "Now playing",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎥 Video Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.white,
              child: BetterPlayer(controller: betterPlayerController),
            ),
          ),

          // 📄 Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎬 Title
                  Text(
                    widget.video['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 👁 Views + Date (mocked for now)
                  Text(
                    "12K views • 2 days ago",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⭐ Action Row (like/share etc.)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _VideoAction(icon: Icons.thumb_up_outlined, label: "Like"),
                      _VideoAction(
                          icon: Icons.thumb_down_outlined, label: "Dislike"),
                      _VideoAction(icon: Icons.share_outlined, label: "Share"),
                      _VideoAction(
                          icon: Icons.download_outlined, label: "Download"),
                      _VideoAction(icon: Icons.playlist_add, label: "Save"),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: const Color.fromARGB(255, 167, 167, 167)),

                  // 👤 Channel Row
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Channel Name",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "120K subscribers",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "SUBSCRIBE",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 📝 Description Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 229, 229, 229),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:  Color.fromARGB(255, 103, 103, 103),
                              ),
                            ),
                            Icon(
                              Icons.expand_more,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.video["description"],
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: const Color.fromARGB(255, 41, 41, 41),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VideoAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 133, 133, 133),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

