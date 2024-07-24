import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/resources/auth_methods.dart';
import 'package:instagram/resources/firebase_methods.dart';
import 'package:instagram/resources/storage_methods.dart';
import 'package:instagram/screens/viewPostScreen.dart';
import 'package:instagram/utils/followButton.dart';
import 'package:instagram/utils/utils.dart';


class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  int postLen = 0;
  int following = 0;
  int followers = 0;
  bool isFollowing = false;
  Uint8List? _file;

  var userObj = {};
  var currUserObj = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      userObj = userSnap.data()!;

      following = userObj['following'].length;
      followers = userObj['followers'].length;

      var currUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      currUserObj = currUserData.data()!;

      List currUserFollowing = currUserData.data()!['following'];

      if (currUserFollowing.contains(widget.uid)) {
        isFollowing = true;
      }

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;

      // print();
      setState(() {});
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  void updateProfilePhoto() async {
    try {
      Uint8List file = await pickImage(ImageSource.gallery);
      setState(() {
        _file = file;
      });
      if (_file != null) {
        Uint8List compressedFile = await compressImageFile(_file!);
        String newProfileURL = await StorageMethods()
            .uploadImageToStorage('profilePics', compressedFile, false);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'photoURL': newProfileURL,
        });
        setState(() {});
        showSnackBar('Profile pic updated!', context);
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future updateProfileDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change profile photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Upload Photo'),
                onTap: () async {
                  // 1) upload file to storage
                  // 2) get link for the file which is uploaded in storage and update the photoURL field in curr user document
                  updateProfilePhoto();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              // foregroundColor: Colors.black,
              elevation: 0,
              title: Text(
                userObj['username'],
              ),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > webScreenSize ? MediaQuery.of(context).size.width * 0.2 : 12,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(
                                  userObj['photoURL'],
                                ),
                                radius: 40,
                              ),
                              onTap: () => widget.uid == currUserObj['uid']
                                  ? updateProfileDialog(context)
                                  : null,
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    // mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildStatColumn(postLen, "posts"),
                                      buildStatColumn(followers, "followers"),
                                      buildStatColumn(following, "following"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      widget.uid == FirebaseAuth.instance.currentUser!.uid
                                          ? FollowButton(
                                              text: 'Sign Out',
                                              backgroundColor:
                                                  Colors.transparent,
                                              textColor: Colors.white,
                                              borderColor: Colors.grey,
                                              function: () async {
                                                await AuthMethods().signOut();
                                                Navigator.pushReplacementNamed(
                                                    context, '/loginScreen');
                                              },
                                            )
                                          : isFollowing
                                              ? FollowButton(
                                                  text: 'UnFollow',
                                                  backgroundColor: Colors.white,
                                                  textColor: Colors.black,
                                                  borderColor: Colors.blue,
                                                  function: () async {
                                                    await FirebaseMethods()
                                                        .followUser(
                                                            uid: FirebaseAuth.instance.currentUser!.uid,
                                                            followId: widget.uid);
                                                    setState(() {
                                                      isFollowing = false;
                                                      followers--;
                                                      // getData();
                                                    });
                                                  },
                                                )
                                              : FollowButton(
                                                  text: 'Follow',
                                                  backgroundColor: Colors.blue,
                                                  textColor: Colors.white,
                                                  borderColor: Colors.blue,
                                                  function: () async {
                                                    await FirebaseMethods().followUser(
                                                            uid: FirebaseAuth.instance.currentUser!.uid,
                                                            followId: widget.uid);
                                                    setState(() {
                                                      isFollowing = true;
                                                      followers++;
                                                      // getData();
                                                    });
                                                    await FirebaseMethods()
                                                        .storeNotification(
                                                            uid: FirebaseAuth.instance.currentUser!.uid,
                                                            followId: widget.uid,
                                                            username: currUserObj['username'],
                                                            profileURL: currUserObj['photoURL']);
                                                  },
                                                )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(
                            top: 15,
                          ),
                          child: Text(
                            userObj['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(
                            top: 1,
                          ),
                          child: Text(
                            userObj['bio'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Displaying posts of user

                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.uid)
                        .get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          DocumentSnapshot snap = snapshot.data!.docs[index];
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewPostScreen(snapshot: snap))),
                            child: Container(
                              child: Image(
                                image: NetworkImage(snap['postURL']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
