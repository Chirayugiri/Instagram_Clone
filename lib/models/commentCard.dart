import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profileScreen.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {

  final snapshot;
  const CommentCard({Key? key, required this.snapshot}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.snapshot['uid']))),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.snapshot['profImage']
              ),
              radius: 18,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: '${widget.snapshot['username']}',
                            style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        TextSpan(text: " "),
                        TextSpan(
                          text: ' ${widget.snapshot['comment']}',
                          // style: TextStyle(color: Colors.black)
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        widget.snapshot['datePublished'].toDate(),
                      ),
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400,),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: (){},
              icon: const Icon(
                Icons.favorite,
                size: 16,
              ),
            )
          )
        ],
      ),
    );
  }
}