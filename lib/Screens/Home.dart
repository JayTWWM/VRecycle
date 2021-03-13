import 'dart:convert';
import 'package:VRecycle/Components/CircularImage.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/ItemsPage.dart';
import 'package:VRecycle/Screens/OrdersPage.dart';
import 'package:VRecycle/Screens/Profile.dart';
import 'package:VRecycle/Screens/OrderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    getUser();
  }

  String title = 'Profile';
  User currentUser;
  bool load = false;
  List<String> categories = [];
  Firestore _db = Firestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> getUser() async {
    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    var userDoc = await _db
        .collection('Users')
        .document(firebaseUser.phoneNumber.substring(3))
        .get();
    if (userDoc.exists) {
      var fireIns = _db
          .collection('Users')
          .document(firebaseUser.phoneNumber.substring(3));
      DocumentSnapshot doc = await fireIns.get();
      User user = User.fromDocument(doc);
      setState(() {
        currentUser = user;
        print(currentUser.address + " " + currentUser.email);
        load = true;
      });
    } else {
      var fireIns = _db
          .collection('Collectors')
          .document(firebaseUser.phoneNumber.substring(3));
      DocumentSnapshot doc = await fireIns.get();
      print(doc.data);
      User user = User.fromDocument(doc);
      setState(() {
        currentUser = user;
        print(currentUser.address + " " + currentUser.email);
        load = true;
      });
    }
    return null;
  }

  // getDrawer() async {
  //   await Firestore.instance.collection("Templates").getDocuments().then((ds) {
  //     if (ds != null) {
  //       ds.documents.forEach((value) {
  //         categories.add(value.documentID);
  //       });
  //     }
  //   });
  //   ;
  // }

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

  Widget mainWidget = Profile();

  @override
  Widget build(BuildContext context) {
    return load == false
        ? Loader()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Utils.getColor(appBarColor),
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
                          // clipper: MyClipper(),
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                                  mainWidget = Profile();
                                  title = "Profile";
                                });
                                Navigator.pop(context);
                              }),
                        ),
                        Container(
                          child: ListTile(
                              leading: Icon(
                                Icons.shopping_bag,
                                color: Utils.getColor(
                                    Utils.getColor(primaryColor)),
                                size: 30,
                              ),
                              title: Text(
                                "Add items",
                                style: TextStyle(
                                    color: Utils.getColor(primaryColor),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                setState(() {
                                  mainWidget = ItemsPage();
                                  title = "Items Page";
                                });
                                Navigator.pop(context);
                              }),
                        ),
                        Container(
                          child: ListTile(
                              leading: Icon(
                                Icons.store_mall_directory_sharp,
                                color: Utils.getColor(
                                    Utils.getColor(primaryColor)),
                                size: 30,
                              ),
                              title: Text(
                                "Orders Page",
                                style: TextStyle(
                                    color: Utils.getColor(primaryColor),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                setState(() {
                                  mainWidget = OrdersPage();
                                  title = "Orders Page";
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
