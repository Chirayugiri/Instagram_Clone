import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grid_staggered_lite/grid_staggered_lite.dart';
import 'package:instagram/screens/profileScreen.dart';
import 'package:instagram/screens/viewPostScreen.dart';
import 'package:instagram/utils/utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool isShowing = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search for a user',
          ),
          onChanged: (String value) {
            setState(() {
              isShowing = true; //user is searching someone
            });
          },
        ),
      ),
      body: isShowing == true
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('username',
                      isGreaterThanOrEqualTo: _searchController.text)
                  .get(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          snapshot.data!.docs[index]['photoURL'],
                        ),
                        radius: 16,
                      ),
                      title: Text(snapshot.data!.docs[index]['username']),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                uid: snapshot.data!.docs[index]
                                    ['uid']))); //passing uid
                      },
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return StaggeredGridView.countBuilder(
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  crossAxisCount: 3,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap = snapshot.data!.docs[index]; //getting snapshot(getting access of whole doc data) of currently pointing document
                    return InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewPostScreen(snapshot: snap))),
                      child: Image.network(snapshot.data!.docs[index]['postURL']),
                    );
                  },
                  staggeredTileBuilder: (int index) =>
                      MediaQuery.of(context).size.width > webScreenSize
                          ? StaggeredTile.count(
                              (index % 7 == 0) ? 1 : 1,
                              (index % 7 == 0) ? 1 : 1,
                            )
                          : StaggeredTile.count(
                              (index % 7 == 0) ? 2 : 1,
                              (index % 7 == 0) ? 2 : 1,
                            ),
                );
              },
            ),
    );
  }
}
