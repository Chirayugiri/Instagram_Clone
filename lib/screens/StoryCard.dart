import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget {
  final snapshot;
  const StoryCard({Key? key,required this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 3,color: Colors.transparent),
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple], // Customize the gradient colors
          begin: Alignment.topLeft, // Customize the gradient start position
          end: Alignment.bottomRight, // Customize the gradient end position
        ),
      ),
      child: CircleAvatar(
        radius: 36,
        backgroundImage: NetworkImage(snapshot['profileURL']),
      ),
    );
  }
}

