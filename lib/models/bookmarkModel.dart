
class BookMarkModel
{
  final String description;
  final String uid;
  final String username;
  final String postID;
  final dynamic savedDate;
  final String postURL;
  final String profImage;
  final likes;
  final String bookmarkId;
  final bookmarkList;

  BookMarkModel({required this.description,required this.uid,required this.username,required this.postID,required this.savedDate,required this.postURL,required this.profImage,required this.likes,required this.bookmarkId,required this.bookmarkList});

  Map<String,dynamic> toJson()=>{
    "description":description,
    "uid":uid,
    "username":username,
    "postId":postID,
    "datePublished":savedDate,
    "postURL":postURL,
    "profImage":profImage,
    "likes":likes,
    'bookmarkId':bookmarkId,
    'bookmarkLists':bookmarkList,
  };

}