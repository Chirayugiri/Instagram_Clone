class CommentModel {

  final String profilePic;
  final String username;
  final String uid;
  final String comment;
  final String commentId;
  final datePublished;

  CommentModel(                                                                         //constructor
      {required this.profilePic,
      required this.username,
      required this.uid,
      required this.comment,
      required this.commentId,
      required this.datePublished});

  Map<String,dynamic> toJson()=>{
    'profImage':profilePic,
    'username':username,
    'uid':uid,
    'comment':comment,
    'commentId':commentId,
    'datePublished':datePublished,
  };
}
