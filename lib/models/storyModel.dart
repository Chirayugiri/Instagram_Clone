
class StoryModel
{
  final String uid;
  final String username;
  final String profileURL;
  final String caption;
  final String storyID;
  final String storyURL;
  dynamic datePublished;

  StoryModel({required this.uid,required this.username,required this.profileURL,required this.caption,required this.datePublished,required this.storyID,required this.storyURL});

  Map<String,dynamic> toJson()=>{
    'uid': uid,
    'username': username,
    'profileURL':profileURL,
    'caption': caption,
    'storyID': storyID,
    'storyURL':storyURL,
    'datePublished': datePublished,
  };
}