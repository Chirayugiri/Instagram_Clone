import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import '../utils/utils.dart';

class ViewStory extends StatefulWidget {
  final snapshot;
  const ViewStory({Key? key,required this.snapshot}) : super(key: key);

  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {

  final controller=StoryController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width>webScreenSize ? MediaQuery.of(context).size.width*0.3 : 0,
      ),
      child: Material(
        child: StoryView(
          controller: controller,
          onComplete: ()=> Navigator.of(context).pop(),
          storyItems: [
            StoryItem.inlineImage(
              controller: controller,
              url: widget.snapshot['storyURL'],
              caption: Text(widget.snapshot['caption'],textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 20),),
              imageFit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
