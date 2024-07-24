import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/addPostScreen.dart';
import 'package:instagram/screens/homeScreen.dart';
import 'package:instagram/screens/notificationScreen.dart';
import 'package:instagram/screens/profileScreen.dart';
import 'package:instagram/screens/reelsScreen.dart';
import 'package:instagram/screens/searchScreen.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({Key? key}) : super(key: key);

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {

  final screen=[HomeScreen(),SearchScreen(),AddPostScreen(),ReelsScreen(),ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,)];
  int _currentIndex=0;
  // String? profImage;
  bool isLoading=false;

  // Future<void> getProfImage() async
  // {
  //   setState(() {
  //     isLoading=true;
  //   });
  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(
  //         FirebaseAuth.instance.currentUser!.uid).get().then((value) {
  //       setState(() {
  //         profImage = value['photoURL'];
  //       });
  //     });
  //   }catch(err){
  //     print(err.toString());
  //   }
  //   setState(() {
  //     isLoading=false;
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: screen[_currentIndex],

      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index)
        {
          setState(() {
            _currentIndex=index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_front_outlined),
          ),
          // BottomNavigationBarItem(
          //   icon: CircleAvatar(
          //     backgroundImage: NetworkImage(
          //       profImage!
          //     ),
          //   ),
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
          )
        ],
      ),
    );
  }
}
