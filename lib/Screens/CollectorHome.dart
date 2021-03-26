import 'dart:convert';
import 'package:VRecycle/Components/CircularImage.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Components/NoData.dart';
import 'package:VRecycle/Components/CollectorDrawer.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/ItemsPage.dart';
import 'package:VRecycle/Screens/OrderDetails.dart';
import 'package:VRecycle/Screens/OrderStatuses.dart';
import 'package:VRecycle/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectorHome extends StatefulWidget {
  @override
  _CollectorHomeState createState() => _CollectorHomeState();
}

class _CollectorHomeState extends State<CollectorHome>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  var uselessVariable;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    getUser();
  }

  String title = 'Your Orders';
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

  Widget mainWidget;

  @override
  Widget build(BuildContext context) {
    return load == false
        ? Loader()
        : DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Text("Offered")),
                    Tab(icon: Text("Accepted")),
                    Tab(icon: Text("Completed")),
                  ],
                ),
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
              drawer: CollectorDrawer(currentUser: currentUser),
              body: TabBarView(
                children: [
                  FutureBuilder<List>(
                      future: getOfferedOrders(),
                      builder:
                          (BuildContext context, AsyncSnapshot<List> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text('Waiting to start');
                          case ConnectionState.waiting:
                            return new NoData(text: "Loading...");
                          default:
                            if (snapshot.data.length == 0) {
                              return NoData(
                                  text:
                                      "No offers for you at the moment.\nPlease Try again later...");
                            }

                            return new ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Card(
                                    margin: EdgeInsets.all(12),
                                    elevation: 4,
                                    color: Colors.blue.shade200,
                                    // color: Color.fromARGB(125, 0, 200, 255),
                                    child: InkWell(
                                        onTap: () => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OrderDetails(
                                                              order: snapshot
                                                                  .data[index],
                                                              parent: this,
                                                              mode: "offered")))
                                            },
                                        child:
                                            getCardContents(snapshot, index)));
                              },
                            );
                        }
                      }),
                  FutureBuilder<List>(
                      future: getAcceptedOrders(),
                      builder:
                          (BuildContext context, AsyncSnapshot<List> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text('Waiting to start');
                          case ConnectionState.waiting:
                            return new NoData(text: "Loading...");
                          default:
                            if (snapshot.data.length == 0) {
                              return NoData(text: "No Orders Accepted ");
                            }

                            return new ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Card(
                                    margin: EdgeInsets.all(12),
                                    elevation: 4,
                                    // color: Color.fromARGB(125, 255, 165, 0),
                                    color: Colors.yellow.shade800,
                                    child: InkWell(
                                        onTap: () => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OrderDetails(
                                                              order: snapshot
                                                                  .data[index],
                                                              parent: this,
                                                              mode:
                                                                  "accepted")))
                                            },
                                        child:
                                            getCardContents(snapshot, index)));
                              },
                            );
                        }
                      }),
                  FutureBuilder<List>(
                      future: getCompletedOrders(),
                      builder:
                          (BuildContext context, AsyncSnapshot<List> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text('Waiting to start');
                          case ConnectionState.waiting:
                            return new NoData(text: "Loading...");
                          default:
                            if (snapshot.data.length == 0) {
                              return NoData(text: "No Orders Completed");
                            }

                            return new ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Card(
                                    margin: EdgeInsets.all(12),
                                    elevation: 4,
                                    // color: Color.fromARGB(125, 248, 63, 154),
                                    color: Colors.pink.shade200,
                                    child: InkWell(
                                        onTap: () => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OrderDetails(
                                                              order: snapshot
                                                                  .data[index],
                                                              parent: this,
                                                              mode:
                                                                  "completed")))
                                            },
                                        child:
                                            getCardContents(snapshot, index)));
                              },
                            );
                        }
                      })
                ],
              ),
            ),
          );
  }

  getOrderTimeDetails(dateTimeObj) {
    DateTime dt =
        DateTime.fromMicrosecondsSinceEpoch(dateTimeObj.microsecondsSinceEpoch)
            .toLocal();

    return Text(
        "🕒 " +
            DateFormat('d MMMM y').format(dt) +
            "\n      " +
            DateFormat("jm").format(dt),
        style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)));
  }

  getCardContents(snapshot, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(snapshot.data[index]["address"],
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 255, 255, 1))),
              SizedBox(height: 8),
              getOrderTimeDetails(snapshot.data[index]["timestamp"]),
            ],
          ),
          Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.memory(base64Decode(snapshot.data[index]["proof"]),
                height: 80, width: 80, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> getOfferedOrders() async {
    List final_ray = [];

    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    var userDoc = await _db
        .collection('Orders')
        .where("phoneNumberCollector",
            isEqualTo: firebaseUser.phoneNumber.substring(3))
        .where('status', isEqualTo: 'Order Placed')
        .getDocuments();

    for (var docRef in userDoc.documents) {
      Map final_data = new Map.from(docRef.data);

      final_data.addAll({"id": docRef.documentID});
      final_ray.add(final_data);
    }

    return final_ray;
  }

  Future<List<dynamic>> getAcceptedOrders() async {
    List final_ray = [];

    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    var userDoc = await _db
        .collection('Orders')
        .where("phoneNumberCollector",
            isEqualTo: firebaseUser.phoneNumber.substring(3))
        .where('status', isEqualTo: 'Order Accepted')
        .getDocuments();

    for (var docRef in userDoc.documents) {
      Map final_data = new Map.from(docRef.data);

      final_data.addAll({"id": docRef.documentID});
      final_ray.add(final_data);
    }

    return final_ray;
  }

  Future<List<dynamic>> getCompletedOrders() async {
    List final_ray = [];

    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    var userDoc = await _db
        .collection('Orders')
        .where("phoneNumberCollector",
            isEqualTo: firebaseUser.phoneNumber.substring(3))
        .where('status', isEqualTo: 'Order Completed')
        .getDocuments();

    for (var docRef in userDoc.documents) {
      Map final_data = new Map.from(docRef.data);

      final_data.addAll({"id": docRef.documentID});
      final_ray.add(final_data);
    }

    return final_ray;
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }
}
