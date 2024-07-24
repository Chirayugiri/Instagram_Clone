import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/models/bookmarkModel.dart';
import 'package:instagram/models/commentModel.dart';
import 'package:instagram/models/postModel.dart';
import 'package:instagram/models/storyModel.dart';
import 'package:instagram/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

//This class is used to upload posts to storage and all details related to post to firebase
class FirebaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost({
    //user defined function
    //The below are the detail stuff related to post will be stored in firestore db
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    String res = "some error occurred!";

    try {
      //upload post to storage
      String postURL =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      //upload post details to firestore
      String postId = Uuid().v1();
      Posts posts = Posts(
          description: description,
          uid: uid,
          username: username,
          postID: postId,
          datePublished: DateTime.now(),
          postURL: postURL,
          profImage: profImage,
          likes: [],
          bookmarkLists: []);

      await _firestore.collection('posts').doc(postId).set(
            posts.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(
      {required String postId,
      required String uid,
      required List likes}) async {
    try {
      if (likes.contains(uid)) {
        //if likes[list] contains our uid then 'remove' our userId because we disliked the post
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        //if we liked the post then 'insert' our userId in likes[list]
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<String> postComment(
      {required String postId,
      required String comment,
      required String uid,
      required String username,
      required String profilePic}) async {
    String res = "some error occurred";
    try {
      String commentId = Uuid().v1(); //generating unique post id for each post
      CommentModel commentModel = CommentModel(
        profilePic: profilePic,
        username: username,
        uid: uid,
        comment: comment,
        commentId: commentId,
        datePublished: DateTime.now(),
      );
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(commentModel.toJson())
          .whenComplete(() => print('posted comment.......'));
      res = "success";
    } catch (err) {
      res = err.toString();
      print(err.toString());
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = "some error occurred";
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      res = "success";
    } catch (err) {
      res = err.toString();
      print(res);
    }
    return res;
  }

  Future<void> followUser(
      {required String uid, required String followId}) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        //To unfollow:
        //  current user ke following se dusre ka id nikalo
        //    and dusre ke followers se current user ka id nikalo

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });

        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
      } else {
        //To follow:
        //  current user ke following meh dusre ka id
        //      and dusre ke followers meh current user ka id
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });

        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> storeNotification(
      {required String uid,
      required String followId,
      required profileURL,
      required username}) async {
    try {
      String notificationId = Uuid().v1();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followId)
          .collection('notifications')
          .doc(notificationId)
          .set({
        "notificationId": notificationId,
        "profileURL": profileURL,
        "from": uid,
        "username": username,
        "date": DateTime.now(),
      });
      print("success");
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> removeNotification(
      {required String uid, required String notificationId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> postStory(
      {required String caption,
      required String uid,
      required String username,
      required String profileURL,
      required Uint8List file}) async {
    try {
      String storyID = Uuid().v1();

      String storyURL = await StorageMethods().uploadImageToStorage(
          'stories', file, true); //uploading file to storage

      StoryModel storyModel = StoryModel(
          uid: uid,
          profileURL: profileURL,
          username: username,
          caption: caption,
          storyID: storyID,
          storyURL: storyURL,
          datePublished: DateTime.now());

      await _firestore
          .collection('stories')
          .doc(storyID)
          .set(storyModel.toJson()); //creating document for stories
      print('story uploaded success');
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deleteStory({required String storyURL}) async
  {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('stories').where('storyURL', isEqualTo: storyURL).get();
    DocumentReference documentReference=querySnapshot.docs[0].reference;
    documentReference.delete();
  }


  Future<void> bookmarkPost(
      {required String uid,
      required String postId,
      required String postURL,
      required String description,
      required List likes,
      required String profImage,
      required String username,
        required List bookmarkList}) async {
    try {
      String bookmarkId = Uuid().v1(); //generates unique id everytime

      BookMarkModel bookMarkModel = BookMarkModel(
        uid: uid,
        postID: postId,
        postURL: postURL,
        bookmarkId: bookmarkId,
        description: description,
        likes: likes,
        profImage: profImage,
        savedDate: DateTime.now(),
        username: username,
        bookmarkList: bookmarkList,
      );

      await _firestore.collection('users').doc(uid).collection('bookmark').doc(bookmarkId).set(bookMarkModel.toJson());
      print('bookmark done');
    } catch (err) {
      print(err.toString());
    }
  }

  Future<String> addUidToBookMarkList({required String postId, required String uid, required List bookmarkLists,}) async {
    if (bookmarkLists.contains(uid)) {
      await _firestore.collection('posts').doc(postId).update({
        'bookmarkLists': FieldValue.arrayRemove([uid]), //removing id
      });
      deleteBookmarkPost(postId);
      return "removed";
    } else {
      await _firestore.collection('posts').doc(postId).update({
        'bookmarkLists': FieldValue.arrayUnion([uid]), //adding uid
      });
      return "success";
    }
  }

  Future<void> deleteBookmarkPost(String postId) async
  {
    QuerySnapshot querySnapshot=await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('bookmark').where('postId',isEqualTo: postId).get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Get the reference to the document
      DocumentReference documentReference = documentSnapshot.reference;

      // Delete the document
      await documentReference.delete();
    }
  }
}
