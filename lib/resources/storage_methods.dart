import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods
{
  final FirebaseStorage _storage=FirebaseStorage.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;

  //adding image to storage
  Future<String> uploadImageToStorage(String childName,Uint8List file,bool isPost) async
  {
    Reference ref=_storage.ref().child(childName).child(_auth.currentUser!.uid);  //pointing to the document(directory)

    if(isPost){
      //The uuid package provides unique id, so a user can upload multiple post so the file name should be unique for
      // each post, so it will not be overridden
      String id=Uuid().v1();
      ref=ref.child(id); // its a 3rd child() function because 2 were already present in ref variable

      print("Ref id is: ${ref}");
    }

    UploadTask uploadTask=ref.putData(file);    //inserting data to pointed directory
    //getting URL of uploaded image so we can see the post using NetworkImage() and can specify the url of uploaded img
    TaskSnapshot snapshot=await uploadTask;
    String downloadUrl=await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }
  
}