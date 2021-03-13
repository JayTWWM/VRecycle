import 'dart:convert';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Components/CollectorDrawer.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/HandleAuth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class CollectorProfile extends StatefulWidget {
  @override
  _CollectorProfileState createState() => _CollectorProfileState();
}

class _CollectorProfileState extends State<CollectorProfile>
    with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool hasLoaded = false;
  User currentUser;
  Firestore _db = Firestore.instance;
  String phoneNumber;
  @override
  void initState() {
    super.initState();
    getuser();
  }

  getuser() async {
    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    if (firebaseUser == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HandleAuth()));
    } else {
      phoneNumber = firebaseUser.phoneNumber;

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
          hasLoaded = true;
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
          hasLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Utils.getColor(appBarColor),
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
            drawer: CollectorDrawer(currentUser: currentUser),
            body: Container(
                child: hasLoaded
                    ? SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                            ClipPath(
                              clipper: MyClipper(),
                              child: Container(
                                  padding: EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                      color: Utils.getColor(primaryColor),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Utils.getColor(primaryColor),
                                            blurRadius: 50,
                                            offset: Offset(0, 0))
                                      ]),
                                  child: Container(
                                    width: double.infinity,
                                    child: Center(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 1.0),
                                              child: new Stack(
                                                  fit: StackFit.loose,
                                                  children: <Widget>[
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Hero(
                                                          tag: "hi",
                                                          child: AvatarGlow(
                                                            glowColor:
                                                                Colors.white,
                                                            endRadius: 100,
                                                            child: Material(
                                                              elevation: 50.0,
                                                              shape:
                                                                  CircleBorder(),
                                                              child: Container(
                                                                width: 130,
                                                                height: 130,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    image: DecorationImage(
                                                                        image: MemoryImage(
                                                                          base64Decode(
                                                                              currentUser.imageUrl),
                                                                        ),
                                                                        fit: BoxFit.cover)),

                                                                // ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 40,
                                                      width: 0,
                                                      child: Divider(
                                                        color: Colors
                                                            .teal.shade700,
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ]),
                                    ),
                                  )),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: Icon(Icons.person,
                                      color: Colors.black, size: 24),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    currentUser.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Icon(
                                    Icons.email,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    currentUser.email,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: Icon(Icons.near_me,
                                      color: Colors.green, size: 24),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    currentUser.address,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: Icon(Icons.phone,
                                      color: Colors.black, size: 24),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    phoneNumber,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]))
                    : Loader())));
  }
}
