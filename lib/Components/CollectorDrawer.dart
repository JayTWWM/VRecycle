import 'dart:convert';

import 'package:VRecycle/Screens/Welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Components/CircularImage.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/CollectorProfile.dart';
import 'package:VRecycle/Screens/CollectorHome.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectorDrawer extends StatelessWidget {
  final User currentUser;

  const CollectorDrawer({Key key, @required this.currentUser})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 10,
        child: Container(
          padding: EdgeInsets.only(
            bottom: 8,
          ),
          color: Colors.white,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
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
                                        base64.decode(currentUser.imageUrl),
                                      )
                                    : AssetImage("assets/blank_profile.jpg"),
                                width: 96,
                                height: 96,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CollectorProfile()
                                )
                            );

                            // Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
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
                    color: Utils.getColor(Utils.getColor(primaryColor)),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CollectorProfile()));

                    // Navigator.pop(context);
                  }),
            ),
            Container(
              child: ListTile(
                  leading: Icon(
                    Icons.person_pin,
                    color: Utils.getColor(Utils.getColor(primaryColor)),
                    size: 30,
                  ),
                  title: Text(
                    "Your Orders",
                    style: TextStyle(
                        color: Utils.getColor(primaryColor),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CollectorHome()));

                    // Navigator.pop(context);
                  }),
            ),
            Container(
              child: ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Utils.getColor(Utils.getColor(primaryColor)),
                    size: 30,
                  ),
                  title: Text(
                    "Log Out",
                    style: TextStyle(
                        color: Utils.getColor(primaryColor),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    SharedPreferences _prefs =
                        await SharedPreferences.getInstance();
                    _prefs.clear();
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade, child: Welcome()));
                  }),
            ),
          ]),
        ));
  }
}
