import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'viewPostScreen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Saved Bookmarks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // foregroundColor: Colors.black,
      ),

      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('bookmark').get(),
        builder: (context, snapshot) {

          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 1.5,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              DocumentSnapshot snap = snapshot.data!.docs[index];
              return InkWell(
                onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewPostScreen(snapshot: snap),)),
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
    );
  }
}
