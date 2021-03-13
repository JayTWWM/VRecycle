import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Order.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/HandleAuth.dart';
import 'package:VRecycle/Screens/OrderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool hasLoaded = false;
  User currentUser;
  Firestore _db = Firestore.instance;
  List<Order> ordersArray = [];

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
            ? Container(
                color: Utils.getColor(primaryColor),
                child: Column(children: [
                  Flexible(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: ordersArray.length,
                          itemBuilder: (context, i) {
                            return Dismissible(
                              background: Container(color: Colors.red),
                              key: Key(ordersArray[i].timestamp.toString()),
                              child: OrderWidget(
                                order: ordersArray[i],
                              ),
                            );
                          },
                        )),
                  ),
                ]),
              )
            : Loader());
  }
}
