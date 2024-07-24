
//This class is created to store user data in firebase
class UserModel
{
  String username;
  String email;
  String password;
  String bio;
  List following;
  List followers;
  String photoURL;

  UserModel({required this.username,required this.email,required this.password,required this.bio,required this.following,required this.followers,required this.photoURL});

  Map<String,dynamic> toJson()=>{       //here, toJson is user defined function
    "username":username,
    "email":email,
    "password":password,
    "bio":bio,
    "following":following,
    "followers":followers,
    "photoURL":photoURL,
  };
}