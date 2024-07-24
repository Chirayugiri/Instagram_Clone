import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ViewReelsScreen extends StatefulWidget {
  final String videoURL;
  const ViewReelsScreen({super.key, required this.videoURL});

  @override
  State<ViewReelsScreen> createState() => _ViewReelsScreenState();
}

class _ViewReelsScreenState extends State<ViewReelsScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoURL))
          ..initialize().then((_) {
            setState(() {
              _videoController.play();
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: GestureDetector(
        onTap: () => _videoController.value.isPlaying
            ? _videoController.pause()
            : _videoController.play(),
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
        ),
      ),
    );
  }
}
