import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/models/userModel.dart';
import 'package:instagram/resources/storage_methods.dart';

class AuthMethods {
  //creating Authentication object
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //creating firebase database object
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> SignUpUser( //this is a function
      {
    required String username,
    required String email,
    required String password,
    required bio,
    required Uint8List file,
  }) async {
    String result = "error occurred";
    try {
      if (username.isNotEmpty || email.isNotEmpty || password.isNotEmpty || bio.isNotEmpty || file != null)
      {
        //register user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        // print(userCredential.user!.uid);  -> returns user document id

        String photoURL = await StorageMethods().uploadImageToStorage('profilePics', file, false);

        //not called UserModel() because some error was occurred
        // UserModel userData=UserModel(username: username, email: email, password: password, bio: bio, following: [], followers: [], photoURL: photoURL);

        //add user data to db
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          "username":username,
          "email":email,
          "password":password,
          "bio":bio,
          "following": [],
          "followers":[],
          "photoURL":photoURL,
          "uid":FirebaseAuth.instance.currentUser!.uid,
          "lastSeen": DateTime.now(),
        });
        result = "success";

      }
    } catch (err) {
      result = err.toString();
    }
    return result;
  }

  // Login user
  Future<String> LoginUser({required String email,required String password}) async
  {
    //here below signIn... method returns UserCredentials we can store in var like did above, but we don't need thus not storing in variable
    String res="Some error occurred!";
    try{
      if(email.isNotEmpty || password.isNotEmpty)
        {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          res="success";
          print("The result is: ${res}");
          return res;
        }
    } catch(err)
    {
      res=err.toString();
      print("The error is: ${res}");
    }
    return res;
  }

  Future<void> signOut() async
  {
    await _auth.signOut();
  }


}
