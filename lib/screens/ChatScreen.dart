import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'DisplayChats.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  dynamic currentUserData;
  dynamic receiverUserData;
  List<dynamic> myFollowersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //when screen loads prefetch currUserData
    // fetchFollowingUsersList();
    getCurrUserSnap();
  }

  void getCurrUserSnap() async
  {
    String currUserUid = await FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot currUserSnap = await FirebaseFirestore.instance.collection('users').doc(currUserUid).get();

    setState(() {
      currentUserData = currUserSnap.data();
    });
  }

  String receiverUserId = "default";
  String roomId = "";

  Future<String> createChatRoom(String currUserId, String receiverUserId) async {
    String room_id = "";
    try {
      if (receiverUserId != "default") {
        List<String> users = [currUserId, receiverUserId];
        users.sort();
        room_id = users[0] + '&&' + users[1];
        setState(() {
          roomId = room_id;
        });
        print("RoomId: "+roomId);
      }

      //create document for above roomId
      // await FirebaseFirestore.instance.collection('messages').doc(roomId).set({});

    } catch (err) {
      print("Error occurred: " + err.toString());
      return "error";
    }
    return "success";
  }

  void handleUserTap(DocumentSnapshot snap) async {
    receiverUserId = snap['uid'];
    String result = await createChatRoom(FirebaseAuth.instance.currentUser!.uid, receiverUserId);
    if (result == "success") {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DisplayChats(roomId: roomId, currUserSnap: currentUserData, receiverUserSnap: receiverUserData,),
      ));

      setState(() {
        receiverUserData = snap.data();
      });
    }
  }

  Future<String> getLastSeen(DocumentSnapshot docSnap) async {
    try {
      var data = docSnap.data() as Map<String, dynamic>;
      if (data.containsKey("lastSeen")) {
        var daysAgo = DateTime.now().difference(data['lastSeen'].toDate()).inDays;
        var hoursAgo = DateTime.now().difference(data['lastSeen'].toDate()).inHours;
        var minAgo = DateTime.now().difference(data['lastSeen'].toDate()).inMinutes;

        if(daysAgo==0 && hoursAgo==0){
          return "${minAgo} minutes ago...";
        }
        else if(daysAgo==0 && hoursAgo!=0){
          return "${hoursAgo} hours ago...";
        }
        else if(daysAgo!=0 && daysAgo<7){
          return "${daysAgo} days ago...";
        }
        else if(daysAgo>7 && daysAgo<14){
          return "A week ago...";
        }
        else{
          var timestamp = DateFormat.yMMMd().format(data['lastSeen'].toDate(),);
          return timestamp.toString();
        }

      } else {
        return "Unknown";
      }
    } catch (err) {
      print("Error got: $err");
      return "None";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // foregroundColor: Colors.black,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context,AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot snap = snapshot.data!.docs[index];

              if (snap['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                return SizedBox.shrink();
              } else {
                return InkWell(
                  onTap: () => handleUserTap(snap),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(snap['photoURL']),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snap['username'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            FutureBuilder<String>(
                              future: getLastSeen(snap),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text('Last Seen: loading...', style: TextStyle(color: Colors.grey, fontSize: 14));
                                }
                                return Text('Last Seen: ${snapshot.data}', style: TextStyle(color: Colors.grey, fontSize: 14));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
