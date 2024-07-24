
class Posts
{
  final String description;
  final String uid;
  final String username;
  final String postID;
  final datePublished;
  final String postURL;
  final String profImage;
  final likes;
  final bookmarkLists;

  Posts({required this.description,required this.uid,required this.username,required this.postID,required this.datePublished,required this.postURL,required this.profImage,required this.likes,required this.bookmarkLists});

  Map<String,dynamic> toJson()=>{
    "description":description,
    "uid":uid,
    "username":username,
    "postId":postID,
    "datePublished":datePublished,
    "postURL":postURL,
    "profImage":profImage,
    "likes":likes,
    'bookmarkLists':bookmarkLists,
  };

}