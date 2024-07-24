import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/login.dart';
import 'package:instagram/responsive_layout.dart';
import 'package:instagram/screens/navBar.dart';
import 'package:instagram/screens/webScreen.dart';
import 'package:instagram/signup.dart';

class Main2 extends StatefulWidget {
  const Main2({Key? key}) : super(key: key);

  @override
  State<Main2> createState() => _Main2State();
}

class _Main2State extends State<Main2> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deleteStories();
    updateLastSeen();
  }

  Future<void> updateLastSeen() async
  {
    try{
      // This block will throw error if "lastSeen" field is not present
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
        "lastSeen": DateTime.now(),
      });
    } catch(err){
      print("Last Seen Field is not present for current user, Error got: "+err.toString());
    }
  }

  Future<void> deleteStories() async
  {
    try{
      int iterator=0;
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('stories').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
        //iterating for each document in collection stories
        iterator++;
        if(iterator==1){          //do nothing
          //i will not delete the first document of stories because we have to upload the story when clicked on
          //  first story. thus in firebase db i have named first document as '0000000000' so i can check if it is first document or not to get data
          //  in homeScreen.
        }
        else{
          dynamic datePublished = document.data()['datePublished'].toDate();
          DateTime currentTime = DateTime.now();

          Duration difference = datePublished.difference(currentTime).abs();
          // Duration of 24 hours
          Duration twentyFourHours = Duration(hours: 24);
          bool isGreaterThan24Hours = difference > twentyFourHours;

          if(isGreaterThan24Hours){
            // if stories are there for more than 24hrs then
            //  delete the documents
            document.reference.delete();
          }
        }
      }
    } catch(err){
      print(err.toString());
    }
  }


  @override
  Widget build(BuildContext context) {

    //check is snapshot has data or not and return widget accordingly
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot)
        {
          if(snapshot.connectionState==ConnectionState.active)
            {
              if(snapshot.hasData)
                {
                  //snapshot has data means user is authenticated i.e signedUp
                  return const ResponsiveLayout(
                      mobileScreenLayout: NavBarScreen(),
                      webScreenLayout: WebScreenLayout()
                  );
                }
              else if(snapshot.hasError)
              {
                //user is not authenticated i.e not signedUp
                return SignUpScreen();
              }
            }
          else if(snapshot.connectionState==ConnectionState.waiting)
            {
              //screen is loading
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
          return LoginScreen();
        },
    );
  }
}
