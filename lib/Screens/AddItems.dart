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
  Widget otherHandler;
  final itemsRef = Firestore.instance.collection('items');
  List<Items> items = [];
  TextEditingController itemController =
      TextEditingController(text: 'Batteries');
  TextEditingController numberController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  List<String> documentID = [];
  String option = 'Batteries';
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
    otherHandler = Container();
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
    DocumentReference docRef = await itemsRef.add({
      "category": itemController.text,
      "number of samples": int.parse(numberController.text.trim()),
      "weight": int.parse(weightController.text.trim()),
      "user": currentUser.name
    });
    setState(() {
      Items itemsAdded = Items(
          option: itemController.text,
          name: currentUser.name,
          number: int.parse(numberController.text.trim()),
          weight: int.parse(weightController.text.trim()));
      items.add(itemsAdded);
      option = "Batteries";
      itemController.text = "Batteries";
      numberController.clear();
      weightController.clear();
      otherHandler = Container();
      documentID.add(docRef.documentID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: hasLoaded
            ? Column(
                children: [
                  Padding(padding: EdgeInsets.all(10)),
                  new DropdownButton<String>(
                    hint: Text("Select Your Item"),
                    value: option,
                    items: <String>['Batteries', 'Monitors', 'Disks', 'Other']
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (String val) {
                      setState(() {
                        option = val;
                        itemController.text = val;
                        if (val == 'Other') {
                          otherHandler = Expanded(
                              child: SizedBox(
                            height: 40.0,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: "Mention your item"),
                              controller: itemController,
                            ),
                          ));
                        } else {
                          otherHandler = Container();
                        }
                      });
                    },
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  new Row(
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      otherHandler,
                      Padding(padding: EdgeInsets.all(10)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  new Row(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(10)),
                      Expanded(
                          child: SizedBox(
                        height: 40.0,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "How many?",
                          ),
                          controller: numberController,
                        ),
                      )),
                      Padding(padding: EdgeInsets.all(10)),
                      Expanded(
                          child: SizedBox(
                        height: 40.0,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Approximate weight"),
                          controller: weightController,
                        ),
                      )),
                      Padding(padding: EdgeInsets.all(10)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(10)),
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
                                                        setState(() {
                                                          items.removeAt(index);
                                                          documentID
                                                              .removeAt(index);
                                                        });
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
