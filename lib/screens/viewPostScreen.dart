import 'package:flutter/material.dart';
import 'package:instagram/models/postCard.dart';

import '../utils/utils.dart';

class ViewPostScreen extends StatelessWidget {
  final snapshot;
  const ViewPostScreen({Key? key, required this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
          child: InteractiveViewer(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width>webScreenSize ? MediaQuery.of(context).size.width*0.3 :0,
              ),
                child: PostCard(snapshot: snapshot)
            ),
          ),
      ),
    );
  }
}
