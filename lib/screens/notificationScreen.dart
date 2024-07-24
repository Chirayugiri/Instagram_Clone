import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/NotificationCard.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notifications'),
        // foregroundColor: Colors.black,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('notifications').snapshots(),
        builder: (context,AsyncSnapshot snapshot) {

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width>600 ? MediaQuery.of(context).size.width*0.3 : 0,
                ),
                child: NotificationCard(
                    snapshot: snapshot.data!.docs[index].data(),
                ),
              );
            },
          );
        },
      ),

    );

  }
}
