import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/postCard.dart';
import 'package:instagram/models/viewStory.dart';
import 'package:instagram/resources/firebase_methods.dart';
import 'package:instagram/screens/ChatScreen.dart';
import 'package:instagram/screens/StoryCard.dart';
import 'package:instagram/screens/bookmarkScreen.dart';
import 'package:instagram/screens/notificationScreen.dart';
import 'package:instagram/screens/uploadStoryScreen.dart';
import '../utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? profileURL;
  bool isViewed = false;
  bool isStoryUploaded = false;
  String? currUserStoryURL;
  dynamic curUserSnap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileImage();
    checkStoryStatus();
  }

  void getProfileImage() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        profileURL = value['photoURL'];
      });
    });
  }

  dynamic checkStoryStatus() async {
    // if(count>1){//means story is uploaded by current user}
    int storyCount = await FirebaseFirestore.instance.collection('stories')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get()
        .then((querySnapshot) => querySnapshot.size);

    QuerySnapshot<Map<String, dynamic>> querySnap = await FirebaseFirestore
        .instance
        .collection('stories')
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> snap = querySnap.docs[0].data();

    setState(() {
      curUserSnap = snap;
      currUserStoryURL = snap['storyURL'];
      isStoryUploaded = true;
    });
  }

  Future deleteStoryDialog(BuildContext context, String storyURL) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Delete'),
                onTap: () {
                  FirebaseMethods().deleteStory(storyURL: storyURL);
                  showSnackBar('Story deleted!', context);
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
    return Scaffold(
      appBar: MediaQuery.of(context).size.width > 600
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // foregroundColor: Colors.black,
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image(image: AssetImage('assets/insta.png'), color: Colors.white,width: 120),
                // child: Text('Instagram'),
              ),
              actions: [
                IconButton(
                  padding: EdgeInsets.only(right: 10),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => BookmarkScreen()));
                  },
                  icon: Icon(Icons.bookmarks_rounded,),
                ),
                IconButton(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationScreen(),));
                    },
                    icon: Icon(Icons.favorite)),
                IconButton(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(),));
                    },
                    icon: Icon(Icons.message_outlined)),
              ],
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // The Stories section
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > webScreenSize
                      ? 20
                      : 0),
              height: 100,
              child: FutureBuilder(
                future: FirebaseFirestore.instance.collection('stories').get(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap = snapshot.data!.docs[index];

                        if (index == 0) {
                          // if current user ka story hai and he is currently logged in
                          //  remove upload symbol and view the story
                          // else
                          return isStoryUploaded == true
                              ? GestureDetector(
                                  //Note: we have to change the snap as first document is 0000000
                                  //show the story of current user
                                  onLongPress: () {
                                    deleteStoryDialog(
                                        context, currUserStoryURL!);
                                  },
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ViewStory(
                                              snapshot: curUserSnap))),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: StoryCard(
                                      snapshot: curUserSnap,
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 5, right: 5, top: 13),
                                      child: CircleAvatar(
                                        radius: 38,
                                        backgroundImage:
                                            NetworkImage(profileURL!),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -2,
                                      right: -4,
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const UploadStoryScreen()));
                                        },
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: Colors.white70,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                        } else {
                          if (isStoryUploaded == true && snap['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                            return Container();
                          }
                          return GestureDetector(
                            onLongPress: () {
                              deleteStoryDialog(context, snap['storyURL']);
                            },
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewStory(snapshot: snap))),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: StoryCard(
                                snapshot: snap,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(),
            // The Posts section
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true, // Add shrinkWrap property to prevent nested ListView conflicts.
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling for this ListView.

                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal:
                          MediaQuery.of(context).size.width > webScreenSize
                              ? MediaQuery.of(context).size.width * 0.3
                              : 0,
                      vertical:
                          MediaQuery.of(context).size.width > webScreenSize
                              ? 15
                              : 0,
                    ),
                    child: InteractiveViewer(
                      child: PostCard(
                        snapshot: snapshot.data!.docs[index].data(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
