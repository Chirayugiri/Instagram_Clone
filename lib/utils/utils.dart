import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/addPostScreen.dart';
import 'package:instagram/screens/bookmarkScreen.dart';
import 'package:instagram/screens/homeScreen.dart';
import 'package:instagram/screens/notificationScreen.dart';
import 'package:instagram/screens/profileScreen.dart';
import 'package:instagram/screens/searchScreen.dart';

//Note: This file consist of all user defined function

const int webScreenSize=600;
List<Widget> homeScreenItems = [
  const HomeScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const NotificationScreen(),
  const BookmarkScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];

pickImage(ImageSource source) async
{
  //source is basically from were to we want to read img file. ex: from gallary,drive,etc;
  final ImagePicker _imagePicker=ImagePicker();

  XFile? _file=await _imagePicker.pickImage(source: source);

  if(_file!=null)
    {
      //file is not null i.e user have selected one image file
      return await _file.readAsBytes();
    }
  print("No Image Selected!");

}

pickMultipleImages(ImageSource source) async
{
  //media can be audio or video
  final imagePicker=ImagePicker();
  List<XFile> file=await imagePicker.pickMultiImage();

  if(file!=null){
    return file;
  }
  print("No media selected");
}



Future<Uint8List> compressImageFile(Uint8List fileData) async {
  // Lower values mean higher compression but lower image quality.
  int quality = 75; // You can set the quality based on your needs

  // Compress the image using the flutter_image_compress library
  List<int> compressedData = await FlutterImageCompress.compressWithList(fileData, quality: quality,);

  return Uint8List.fromList(compressedData);
}

showSnackBar(String msg,BuildContext context)
{
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(msg),
    )
  );
}
