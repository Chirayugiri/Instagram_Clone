import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/resources/firebase_methods.dart';
import 'package:instagram/utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {

  TextEditingController _description=TextEditingController();
  Uint8List? _file;
  String? profileURL;
  String? userName;
  bool isLoading=false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        profileURL = value['photoURL'];
        userName= value['username'];
      });
    });
  }

  void postImage({required String uid,required String username,required String profImage}) async
  {
    Uint8List compressedFile=await compressImageFile(_file!);
    setState(() {
      isLoading=true;
    });
    try{
      String res=await FirebaseMethods().uploadPost(
          description: _description.text,
          file: compressedFile,
          uid: uid,
          username: username,
          profImage: profImage,
      );

      if(res=="success"){
        //post is uploaded and its description too
        showSnackBar('Post Uploaded!', context);
        setState(() {
          _file=null;
          isLoading=false;
        });
      }
    }catch(err){
      showSnackBar('Failed to Upload!', context);
      setState(() {
        isLoading=false;
      });
    }
  }

  selectImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create a Post'),
            children: [
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text('Take a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource
                      .gallery); //This file need to be uploaded on storage
                  setState(() {
                    _file = file;
                    print("file is not null now");
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); //removes dialog box from screen
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? Center(
            child: IconButton(
              icon: Icon(Icons.cloud_upload,size: 40),
              onPressed: () {
                selectImage(context);
              },
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
                "Post to",
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: (){
                        postImage(uid: _auth.currentUser!.uid, username: userName!, profImage: profileURL!);
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
                isLoading==true ?LinearProgressIndicator(color: Colors.blue,)
                :Container(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width>webScreenSize ? MediaQuery.of(context).size.width*0.2 : 0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundImage: profileURL != null
                            ? NetworkImage(profileURL!)
                            : NetworkImage(
                                "https://cdn.pixabay.com/photo/2012/04/13/21/07/user-33638_640.png"),
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
                        backgroundImage: MemoryImage(_file!),
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
