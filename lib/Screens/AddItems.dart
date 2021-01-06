import 'dart:convert';
import 'package:VRecycle/Components/AuthButton.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Constants/UserProperties.dart';
import 'package:VRecycle/Model/Items.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/HandleAuth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class AddItems extends StatefulWidget {
  @override
  _AddItemsState createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool hasLoaded = false;
  User currentUser;
  Firestore _db = Firestore.instance;
  final itemsRef = Firestore.instance.collection('items');
  List<Items> items = [];
  TextEditingController numberController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  List<String> documentID = [];
  String option = '';
  void getUser() async {
    User user = await UserProperties.getUser();
    setState(() {
      currentUser = user;
    });

    getItemsofUser();
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getItemsofUser() async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("items").getDocuments();
    var list = querySnapshot.documents;
    for (var i = 0; i < list.length; i++) {
      DocumentSnapshot ds = list[i];
      Items d = Items.fromDocument(ds);
      print(d.name + " " + d.option + " " + currentUser.name);
      if (d.name == currentUser.name) {
        items.add(d);
        documentID.add(ds.documentID);
      }
    }
    setState(() {
      hasLoaded = true;
    });
  }

  Future<void> addItemsinFirestore() async {
    await itemsRef.document().setData({
      "category": option,
      "number of samples": int.parse(numberController.text.trim()),
      "weight": int.parse(weightController.text.trim()),
      "user": currentUser.name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: hasLoaded
            ? Column(
                children: [
                  new DropdownButton<String>(
                    items: <String>['Batteries', 'Monitors', 'Disks']
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (String val) {
                      setState(() {
                        option = val;
                      });
                    },
                  ),
                  new Row(
                    children: <Widget>[
                      Expanded(
                          child: SizedBox(
                        height: 200.0,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(prefixIcon: Text("How many?")),
                          controller: numberController,
                        ),
                      )),
                      Expanded(
                          child: SizedBox(
                        height: 40.0,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              prefixIcon: Text("Approximate weight")),
                          controller: weightController,
                        ),
                      ))
                    ],
                  ),
                  AuthButton(
                    btnText: 'Add Item',
                    onTap: () async {
                      await addItemsinFirestore();
                    },
                    isOutlined: false,
                  ),
                  new ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          child: InkWell(
                            // onTap: () => print("ciao"),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch, // add this
                              children: <Widget>[
                                SizedBox(
                                  height: 15,
                                ),
                                ClipRRect(
                                  // borderRadius: BorderRadius.only(
                                  //   topLeft: Radius.circular(8.0),
                                  //   topRight: Radius.circular(8.0),
                                  // ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Text(
                                                      "${items[index].option}",
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 17),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 8),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Firestore.instance
                                                            .collection("items")
                                                            .document(
                                                                documentID[
                                                                    index])
                                                            .delete();
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red[500],
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Text(
                                                    "Number of samples:${items[index].number}",
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    "Weight:${items[index].weight}",
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                ],
              )
            : Loader());
  }
}
