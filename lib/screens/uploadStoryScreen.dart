import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/resources/firebase_methods.dart';
import 'package:instagram/utils/utils.dart';

class UploadStoryScreen extends StatefulWidget {
  const UploadStoryScreen({Key? key}) : super(key: key);

  @override
  State<UploadStoryScreen> createState() => _UploadStoryScreenState();
}

class _UploadStoryScreenState extends State<UploadStoryScreen> {
  Uint8List? _file;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? profileURL;
  String? username;
  bool isLoading = false;
  TextEditingController _description = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void selectImage() async {
    //media can be audio or video
    Uint8List file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
    });
  }

  void postStory() async {
    Uint8List compressedFile = await compressImageFile(_file!);
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseMethods().postStory(
        caption: _description.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        username: username!,
        profileURL: profileURL!,
        file: compressedFile,
      );
      setState(() {
        _file = null;
      });
      showSnackBar('Story Uploaded!', context);
    } catch (err) {
      print(err.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        profileURL = value['photoURL'];
        username = value['username'];
      });
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? Scaffold(
            appBar: AppBar(
              // foregroundColor: Colors.black,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context)),
            ),
            body: Center(
              child: IconButton(
                icon: Icon(Icons.cloud_upload, size: 40),
                onPressed: () {
                  selectImage();
                },
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              title: Text(
                "Post Story",
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        postStory();
                      },
                      child: Text(
                        "Post",
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                isLoading == true
                    ? LinearProgressIndicator(
                        color: Colors.blue,
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width > webScreenSize
                            ? MediaQuery.of(context).size.width * 0.2
                            : 0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundImage: profileURL != null
                            ? NetworkImage(profileURL!)
                            : NetworkImage("https://cdn.pixabay.com/photo/2012/04/13/21/07/user-33638_640.png"),
                        radius: 25,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: TextField(
                          controller: _description,
                          decoration: InputDecoration(
                            hintText: 'Write a caption...',
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundImage: MemoryImage(_file! as Uint8List),
                        radius: 25,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
