import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/resources/firebase_methods.dart';
import 'package:instagram/screens/commentScreen.dart';
import 'package:instagram/screens/profileScreen.dart';
import 'package:instagram/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PostCard extends StatefulWidget {
  final snapshot;
  const PostCard({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int commentLen = 0;
  static const delay = Duration(seconds: 1);

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getCommentLength();
  }

  void sendToWhatsapp(String msg) async {
    String url = "whatsapp://send?&text=${Uri.encodeComponent(msg)}";
    if (await launchUrlString(url)) {
      print("launched successfully");
    } else {
      showSnackBar("Can't open WhatsApp", context);
    }
  }

  offLike() {
    setState(() {
      isLiked = false;
      isLiked = false;
    });
  }

  void getCommentLength() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snapshot['postId'])
        .collection('comments')
        .get();
    setState(() {
      commentLen = querySnapshot.docs.length;
    });
  }

  void postLike() async {
    DocumentSnapshot<Map<String, dynamic>> docSnap = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.snapshot['postId'])
        .get();
    List likesList = docSnap.data()!['likes'];

    if (likesList.contains(FirebaseAuth.instance.currentUser!.uid)) {
      setState(() {
        isLiked = true;
      });
    } else {
      setState(() {
        isLiked = false;
      });
    }
  }

  Future sharePost(BuildContext context, String postURL) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Share'),
                onTap: () {
                  // showSnackBar('Functionality not implemented yet!', context);
                  Navigator.of(context).pop();
                  sendToWhatsapp(postURL);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future threeDot(BuildContext context, String postURL) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Share'),
                onTap: () {
                  Navigator.of(context).pop();
                  sendToWhatsapp(postURL);
                },
              ),
              ListTile(
                title: Text('Delete'),
                onTap: () async {
                  String result = await FirebaseMethods()
                      .deletePost(widget.snapshot['postId']);
                  if (result == "success") {
                    showSnackBar('post deleted!', context);
                  } else {
                    showSnackBar(result, context);
                  }
                  // remove the dialog box
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 10,bottom: 5),
            child: Row(
              children: [
                InkWell(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.snapshot['profImage']), //here 'widget.snapshot' because this class is stateful widget
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(uid: widget.snapshot['uid'])));
                  },
                ),
                InkWell(
                  child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        '${widget.snapshot['username']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(uid: widget.snapshot['uid'])));
                  },
                ),
                widget.snapshot['uid'] == FirebaseAuth.instance.currentUser!.uid
                    ? Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () {
                        threeDot(context, widget.snapshot['postURL']);
                      },
                      icon: Icon(Icons.more_vert),
                    ),
                  ),
                )
                    : Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () {
                        sharePost(context, widget.snapshot['postURL']);
                      },
                      icon: Icon(Icons.more_vert),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              //keep in mind, we are using StreamBuilder in homeScreen.dart which is iterating for each document in 'posts' collection
              // so the below snapshot variable will get data of each user
              await FirebaseMethods().likePost(
                  postId: widget.snapshot['postId'],
                  uid: FirebaseAuth.instance.currentUser!.uid,
                  likes: widget.snapshot['likes']);
              setState(() {
                postLike();
                Future.delayed(delay, () => offLike());
              });
            },
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.snapshot['postURL'],
                        placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ),
                  ),
                ),
                isLiked == true
                    ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: LottieBuilder.asset('assets/like_anim.json'))
                    : Container(),
              ],
            ),
          ),
          Container(
            // padding: EdgeInsets.all(5.0),
            child: Row(
              children: [
                IconButton(
                    onPressed: () async {
                      await FirebaseMethods().likePost(
                          postId: widget.snapshot['postId'],
                          uid: FirebaseAuth.instance.currentUser!.uid,
                          likes: widget.snapshot['likes']);

                    },
                    icon: widget.snapshot['likes']
                        .contains(FirebaseAuth.instance.currentUser!.uid)
                        ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 26,
                    )
                        : Icon(
                      Icons.favorite_border_outlined,
                      size: 26,
                    )),
                // SizedBox(width: 5,),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CommentScreen(snapshot: widget.snapshot),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.comment_outlined,
                    size: 26,
                  ),
                ),
                // SizedBox(width: 5,),
                IconButton(
                  onPressed: () {
                    sendToWhatsapp(widget.snapshot['postURL']);
                  },
                  icon: Icon(
                    Icons.send,
                    size: 26,
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () async {

                        String result = await FirebaseMethods().addUidToBookMarkList(
                          postId: widget.snapshot['postId'],
                          uid: FirebaseAuth.instance.currentUser!.uid,
                          bookmarkLists: widget.snapshot['bookmarkLists'],
                        );
                        if (result == "success") {
                          await FirebaseMethods().bookmarkPost(
                            uid: FirebaseAuth.instance.currentUser!.uid,
                            username: widget.snapshot['username'],
                            profImage: widget.snapshot['profImage'],
                            postURL: widget.snapshot['postURL'],
                            likes: widget.snapshot['likes'],
                            description: widget.snapshot['description'],
                            postId: widget.snapshot['postId'],
                            bookmarkList: widget.snapshot['bookmarkLists'],
                          );
                          showSnackBar('Saved', context);
                        } else if(result=="removed"){
                          showSnackBar('Unsaved', context);
                        }
                      },
                      icon: widget.snapshot['bookmarkLists'].contains(FirebaseAuth.instance.currentUser!.uid)
                          ? Icon(Icons.bookmark_added,size: 26,)
                          : Icon(
                              Icons.bookmark_add_outlined,
                              size: 26,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${widget.snapshot['likes'].length} likes' //likes.length because likes array contains all users userId who liked the post
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.snapshot['username'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                        child: Text(
                          ' ${widget.snapshot['description']}',
                          softWrap: true,
                        )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommentScreen(
                          snapshot: widget.snapshot,
                        ))),
                    child: Text('View all ${commentLen} comments')),
                SizedBox(
                  height: 5,
                ),
                Text(DateFormat.yMMMd().format(
                  widget.snapshot['datePublished'].toDate(),
                )),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
