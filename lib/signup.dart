import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/main2.dart';
import 'package:instagram/resources/auth_methods.dart';
import 'package:instagram/utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _userName = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _bio = TextEditingController();
  bool isLoading = false;

  Uint8List? _imageFile;

  void selectImage() async {
    Uint8List _img = await pickImage(ImageSource.gallery);
    setState(() {
      _imageFile = _img;
    });
  }

  Future<void> signUp() async //user defined function
  {
    //check if field are empty or not
    bool isFieldsEmpty=true;
    if(_userName.text!=" " || _userName.text!=null && _email.text!=" " || _email.text!=null && _pass.text!=" " || _pass.text!=null && _bio.text!=" " || _bio.text!=null){
      isFieldsEmpty=false;
    }
    if(isFieldsEmpty==true){
      showSnackBar("Fields Cannot Be Empty!", context);
      return;
    }

    //Before storing it to firebase storage we have to compress it
    Uint8List compressedFile = await compressImageFile(_imageFile!);
    setState(() {
      isLoading = true;
    });
    //calling method of class AuthMethods to register user with email and password and store data in db
    String result = await AuthMethods().SignUpUser(
        username: _userName.text,
        email: _email.text,
        password: _pass.text,
        bio: _bio.text,
        file: compressedFile);

    if (result == "success") {
      setState(() {
        _email.clear();
        _pass.clear();
        _userName.clear();
        _bio.clear();
      });
      showSnackBar("SignUp Done Successfully!", context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> Main2()));
    } else {
      showSnackBar("SignUp Failed", context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: MediaQuery.of(context).size.width > webScreenSize
                ? EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: MediaQuery.of(context).size.width / 3)
                : EdgeInsets.all(35.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(height: 50),
                  Image.asset('assets/insta.png', color: Colors.white),
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      _imageFile != null
                          ? CircleAvatar(
                              radius: 55,
                              backgroundImage: MemoryImage(_imageFile!),
                            )
                          : CircleAvatar(
                              radius: 55,
                              backgroundImage: NetworkImage(
                                  "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                            ),
                      Positioned(
                        bottom: -2,
                        right: -3,
                        child: IconButton(
                          onPressed: () {
                            selectImage();
                          },
                          icon: Icon(Icons.add_a_photo, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _userName,
                    decoration: InputDecoration(
                      hintText: 'UserName',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(height: 10),
                  TextField(
                    controller: _pass,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(height: 10),
                  TextField(
                    controller: _bio,
                    decoration: InputDecoration(
                      hintText: 'Bio',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // calling signup method to register user and store data
                        signUp();
                      },
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : Text(
                              'SignUp',
                              style: TextStyle(fontSize: 17),
                            ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
