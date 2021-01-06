import 'dart:convert';
import 'dart:typed_data';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/AddItems.dart';
import 'package:VRecycle/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

String title = "Drawer";
User currentUser;
bool load = false;
List<String> categories = [];

class _NavDrawerState extends State<NavDrawer> {
  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    FirebaseUser user1 = await FirebaseAuth.instance.currentUser();
    var fireIns = Firestore.instance
        .collection('users')
        .document(user1.phoneNumber.substring(3));
    DocumentSnapshot doc = await fireIns.get();
    User user = User.fromDocument(doc);
    await getDrawer();
    setState(() {
      currentUser = user;
      load = true;
    });
    return null;
  }

  getDrawer() async {
    await Firestore.instance.collection("Templates").getDocuments().then((ds) {
      if (ds != null) {
        ds.documents.forEach((value) {
          categories.add(value.documentID);
        });
      }
    });
    ;
  }

  Widget appBarIcon({@required IconData icon}) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.black,
        size: 28.0,
      ),
      onPressed: () {},
    );
  }

  Widget mainWidget = Home();

  @override
  Widget build(BuildContext context) {
    return load == false
        ? Loader()
        : Scaffold(
            backgroundColor: Colors.blue,
            appBar: AppBar(
              backgroundColor: Utils.getColor(primaryColor),
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                '$title',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
            drawer: Drawer(
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 8,
                  ),
                  color: Colors.white,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipPath(
                          clipper: MyClipper(),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(top: 80),
                            decoration: BoxDecoration(
                                color: Utils.getColor(primaryColor),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 50,
                                      offset: Offset(0, 0))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, top: 10, right: 10.0),
                                    child: GestureDetector(
                                      child: Hero(
                                        tag: 'hiHero',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10, top: 10, bottom: 10),
                                          child: CircularImage(
                                            currentUser.imageUrl != null
                                                ? MemoryImage(
                                                    base64.decode(
                                                        currentUser.imageUrl),
                                                  )
                                                : AssetImage(
                                                    "assets/blank_profile.jpg"),
                                            width: 96,
                                            height: 96,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          mainWidget = Home();
                                          title = "Profile";
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    // Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(bottom: 10.0),
                                    //   child: Text(
                                    //     "Hi",
                                    //     style: new TextStyle(
                                    //         fontSize: 30.0,
                                    //         color: Colors.white,
                                    //         fontWeight: FontWeight.w400),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 50.0),
                                      child: Text(
                                        currentUser.name,
                                        style: new TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Pacifico',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: ListTile(
                              leading: Icon(
                                Icons.person_pin,
                                color: Utils.getColor(
                                    Utils.getColor(primaryColor)),
                                size: 30,
                              ),
                              title: Text(
                                "Profile",
                                style: TextStyle(
                                    color: Utils.getColor(primaryColor),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                setState(() {
                                  mainWidget = Home();
                                  title = "Profile";
                                });
                                Navigator.pop(context);
                              }),
                        ),
                        Container(
                          child: ListTile(
                              leading: Icon(
                                Icons.person_pin,
                                color: Utils.getColor(
                                    Utils.getColor(primaryColor)),
                                size: 30,
                              ),
                              title: Text(
                                "Add items ",
                                style: TextStyle(
                                    color: Utils.getColor(primaryColor),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                setState(() {
                                  mainWidget = AddItems();
                                  title = "Profile";
                                });
                                Navigator.pop(context);
                              }),
                        ),
                        // Container(
                        //   child: ListTile(
                        //       leading: Icon(
                        //         Icons.person_pin,
                        //         color: Utils.getColor(
                        //             Utils.getColor(primaryColor)),
                        //         size: 30,
                        //       ),
                        //       title: Text(
                        //         "Request Collection ",
                        //         style: TextStyle(
                        //             color: Utils.getColor(primaryColor),
                        //             fontSize: 20,
                        //             fontWeight: FontWeight.bold),
                        //       ),
                        //       onTap: () {
                        //         setState(() {
                        //           mainWidget = Home();
                        //           title = "Profile";
                        //         });
                        //         Navigator.pop(context);
                        //       }),
                        // ),
                      ]),
                )),
            body: mainWidget);
  }
}

class CircularImage extends StatelessWidget {
  final double _width, _height;
  final ImageProvider image;
  Uint8List bytes;

  CircularImage(this.image, {double width = 50, double height = 50})
      : _width = width,
        _height = height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
  }
}
