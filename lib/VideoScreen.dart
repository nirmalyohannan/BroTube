import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

class VideoScreen extends StatefulWidget {
  VideoScreen({Key? key, required this.videoID}) : super(key: key);
  String videoID;
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late PodPlayerController _controller;

  @override
  void initState() {
    _controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube(widget.videoID),
    )..initialise();
    super.initState();
  }

//controller Dispose function not added yet
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PodVideoPlayer(
      controller: _controller,
    );
  }
}
