import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram/screens/viewReelsScreen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {

  PageController pageController=PageController();

  List<Widget> reels=[
    ViewReelsScreen(videoURL: 'https://firebasestorage.googleapis.com/v0/b/instagram-clone-3f367.appspot.com/o/reels%2Fvid1.mp4?alt=media&token=30c8540e-169e-4d22-9af1-92712bb6f771',),
    ViewReelsScreen(videoURL: 'https://firebasestorage.googleapis.com/v0/b/instagram-clone-3f367.appspot.com/o/reels%2Fvid2.mp4?alt=media&token=e0c00ab3-2681-45ce-966a-9c3bbba4f813'),
    ViewReelsScreen(videoURL: 'https://firebasestorage.googleapis.com/v0/b/instagram-clone-3f367.appspot.com/o/reels%2Fvid3.mp4?alt=media&token=9f3c6797-514a-41d5-8fa5-7d4d4d53dae5'),
    ViewReelsScreen(videoURL: 'https://firebasestorage.googleapis.com/v0/b/instagram-clone-3f367.appspot.com/o/reels%2Fvid4.mp4?alt=media&token=c17d4551-8a00-4f26-82a6-db0219ec7f8f'),
    ViewReelsScreen(videoURL: 'https://firebasestorage.googleapis.com/v0/b/instagram-clone-3f367.appspot.com/o/reels%2Fvid5.mp4?alt=media&token=4e48fd2a-e0a3-4773-8cca-c698df439b5d')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Reels'),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   actions: [
      //     Icon(Icons.camera_alt_outlined),
      //   ],
      // ),

      body: Container(
        color: Colors.black,
        child: PageView(
          scrollDirection: Axis.vertical,
          children: reels,
        ),
      ),

    );
  }
}
