import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


//Note: update profile pic

class temp
{
  FirebaseStorage _firebaseStorage=FirebaseStorage.instance;

  void upload()
  {
    Reference ref=_firebaseStorage.ref().child('/profilePhotos').child(FirebaseAuth.instance.currentUser!.uid);

    
  }

}