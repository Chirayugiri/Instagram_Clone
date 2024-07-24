import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/resources/firebase_methods.dart';
import 'package:instagram/screens/profileScreen.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatefulWidget {
  final snapshot;
  const NotificationCard({Key? key,required this.snapshot}) : super(key: key);

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("The snapshot data is: ${widget.snapshot}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.snapshot['from']),)),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.snapshot['profileURL']),
                  radius: 24,
                ),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(widget.snapshot['username'],style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  SizedBox(height: 4,),
                  Text("Followed you on ${DateFormat.yMMMd().format(widget.snapshot['date'].toDate(),)}",
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400,),
                  ),
                ],
              ),
              Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        onPressed: ()async{
                          await FirebaseMethods().removeNotification(uid: FirebaseAuth.instance.currentUser!.uid, notificationId: widget.snapshot['notificationId']);
                        },
                        icon: Icon(Icons.close_rounded),
                    ),
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
