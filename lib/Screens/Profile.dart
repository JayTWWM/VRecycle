import 'dart:convert';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Order.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/HandleAuth.dart';
import 'package:VRecycle/Screens/OrderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool hasLoaded = false;
  User currentUser;
  List<Order> ordersArray = [];
  Firestore _db = Firestore.instance;
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
        for (int i = 0; i < user.orders.length; i++) {
          DocumentSnapshot doc = await user.orders[i].get();
          Order ord = Order.fromDocument(doc);
          ordersArray.add(ord);
          print(ord.phoneNumberCollector);
        }
        setState(() {
          currentUser = user;
          hasLoaded = true;
        });
      } else {
        var fireIns = _db
            .collection('Collectors')
            .document(firebaseUser.phoneNumber.substring(3));
        DocumentSnapshot doc = await fireIns.get();
        print(doc.data);
        User user = User.fromDocument(doc);
        for (int i = 0; i < user.orders.length; i++) {
          // ordersArray.add(user.orders[i]);
        }
        print(ordersArray);

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
    return Container(
        child: hasLoaded
            ? SingleChildScrollView(
                child: Column(
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 1.0),
                                    child: new Stack(
                                        fit: StackFit.loose,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Hero(
                                                tag: "hi",
                                                child: AvatarGlow(
                                                  glowColor: Colors.white,
                                                  endRadius: 100,
                                                  child: Material(
                                                    elevation: 50.0,
                                                    shape: CircleBorder(),
                                                    child: Container(
                                                      width: 130,
                                                      height: 130,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image:
                                                              DecorationImage(
                                                                  image:
                                                                      MemoryImage(
                                                                    base64Decode(
                                                                        currentUser
                                                                            .imageUrl),
                                                                  ),
                                                                  fit: BoxFit
                                                                      .cover)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0),
                                                child: new Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      width: 100,
                                                      child: new Text(
                                                        currentUser.name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: new TextStyle(
                                                            fontSize: 26.0,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 150,
                                                      child: new Text(
                                                        currentUser.email,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: new TextStyle(
                                                            fontSize: 14.0,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 40,
                                            width: 200,
                                            child: Divider(
                                              color: Colors.teal.shade700,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ])),
                          ),
                        )),
                    Container(
                      height: 600,
                      child: Column(children: [
                        Flexible(
                          child: Container(
                              padding: EdgeInsets.all(20),
                              color: Utils.getColor(primaryColor),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: ordersArray.length,
                                itemBuilder: (context, i) {
                                  return Dismissible(
                                    background: Container(color: Colors.red),
                                    key: Key(
                                        ordersArray[i].timestamp.toString()),
                                    child: OrderWidget(
                                      order: ordersArray[i],
                                    ),
                                  );
                                },
                              )),
                        ),
                      ]),
                    ),
                  ]))
            : Loader());
  }
}
