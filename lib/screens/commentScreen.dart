import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/commentCard.dart';
import 'package:instagram/resources/firebase_methods.dart';
import 'package:instagram/utils/utils.dart';

class CommentScreen extends StatefulWidget {
  final snapshot;
  const CommentScreen({Key? key,required this.snapshot}) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {

  TextEditingController _comment = TextEditingController();
  String? username;
  String? profImage;

  Future<void> getUserName() async
  {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value){
      setState(() {
        username=value['username'];
        profImage=value['photoURL'];
      });
    });
  }

  void sendComment() async
  {
    String result=await FirebaseMethods().postComment(
      postId: widget.snapshot['postId'],
      comment: _comment.text,
      profilePic: profImage!,
      uid: FirebaseAuth.instance.currentUser!.uid,
      username: username!,
    );
    print("The value is: ${result}");
    if(result=="success")
    {
      setState(() {
        _comment.clear();
      });
      showSnackBar('Comment Posted!', context);
    }
    else{
      showSnackBar(result, context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _comment.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            // color: Colors.black,
          ),
        ),
        title: Text(
          "Comments",
          // style: TextStyle(color: Colors.black),
        ),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').doc(widget.snapshot['postId']).collection('comments').orderBy('datePublished').snapshots(),
        builder: (context,AsyncSnapshot snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting)
            {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width>webScreenSize ? MediaQuery.of(context).size.width*0.3 : 0,
              ),
              child: CommentCard(
                snapshot: snapshot.data!.docs[index].data(),   //each document data of andar->ka ander ka collection, will be passed to the widget 'commentCard'
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(left: 18, right: 8, bottom: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  profImage!
                ),
                radius: 18,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: _comment,
                  decoration: InputDecoration(
                      hintText: 'Comment as ${username}',
                      border: InputBorder.none),
                ),
              ),
              TextButton(
                onPressed: (){
                  sendComment();
                },
                child: Text(
                  'Post',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
