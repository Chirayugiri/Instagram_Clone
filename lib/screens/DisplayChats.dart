import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/screens/profileScreen.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';

class DisplayChats extends StatefulWidget {
  final String roomId;
  final dynamic currUserSnap;
  final dynamic receiverUserSnap;

  DisplayChats({required this.roomId, required this.currUserSnap, required this.receiverUserSnap});

  @override
  State<DisplayChats> createState() => _DisplayChatsState();
}

class _DisplayChatsState extends State<DisplayChats> {

  TextEditingController _inputController = TextEditingController();
  String inputValue = "default value";

  void storeMessage() async
  {
    await FirebaseFirestore.instance.collection('messages').doc(widget.roomId).collection('msgList').doc().set({
      'msg': inputValue,
      'msgTime': Timestamp.now(),
      'uid': widget.currUserSnap['uid'],
    }).onError((error, stackTrace) => print('Unable to store msg: '+error.toString())).whenComplete(() => print('success'));
  }

  void deleteMessage(DocumentReference docID) async
  {
    print('Document id to delete: '+docID.toString());
    await docID.delete().whenComplete(() => print('Message Deleted'));
  }

  Future deleteMessageDialog(BuildContext context, DocumentReference docID) {
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
                  deleteMessage(docID);
                  showSnackBar('Message Deleted...', context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('hh:mm a'); // 12-hour format with AM/PM
    return formatter.format(dateTime);
  }
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.receiverUserSnap['uid'],),));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.receiverUserSnap['photoURL']),
              ),
            ),
            SizedBox(width: 5,),
            InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.receiverUserSnap['uid'],),));
              },
                child: Text(widget.receiverUserSnap['username']),
            ),
          ],
        ), // get name using chatroomID
        backgroundColor: Colors.transparent,
        elevation: 0,
        // foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('messages').doc(widget.roomId).collection('msgList').orderBy('msgTime').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('No data available');
                  return Center(child: Text('No Messages'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index){
                    DocumentSnapshot snap = snapshot.data!.docs[index];

                    if(snap['uid'] == FirebaseAuth.instance.currentUser!.uid){
                      //Current user message
                      return ListTile(
                        contentPadding: EdgeInsets.only(left: 64.0, right: 16.0),
                        title: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: ()=> {
                              deleteMessageDialog(context, snap.reference),
                            },
                            child: Container(
                              padding: EdgeInsets.all(7.0),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    snap['msg'],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(height: 2.0),
                                  Text(
                                    formatTimestamp(snap['msgTime']),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 10.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    else{
                      // Receiver Message
                      return ListTile(
                        contentPadding: EdgeInsets.only(left: 16.0, right: 64.0),
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(7.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snap['msg'],
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  formatTimestamp(snap['msgTime']),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 10.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                );
              },
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey), // Border decoration
              borderRadius: BorderRadius.circular(50.0), // Adjust border radius as needed
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.all(10.0),
                  onPressed: () {
                    setState(() {
                      inputValue = _inputController.text;
                    });
                    _inputController.clear();
                    // Add your message sending logic here
                    storeMessage();
                  },
                  icon: Icon(
                    Icons.send_sharp,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
