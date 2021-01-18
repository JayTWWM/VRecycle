import 'dart:convert';

import 'package:VRecycle/Components/AuthButton.dart';
import 'package:VRecycle/Components/ItemWidget.dart';
import 'package:VRecycle/Components/Quantity.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    serialNo = 0;
    getPrefs();
    itemName = '';
    itemDesc = '';
    counter = 0;
  }

  void getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey('Serial')) {
      serialNo = _prefs.getInt('Serial');
      for (int i = 0; i < serialNo; i++) {
        if (_prefs.containsKey('$i')) {
          print(_prefs.getString('$i'));
          Map<String, dynamic> temp = json.decode(_prefs.getString('$i'));
          Item item = new Item(
              serialNo: temp['serialNo'],
              itemName: temp['itemName'],
              desc: temp['desc'],
              quantity: temp['quantity']);
          cart.add(item);
          itemTiles.add(Dismissible(
            background: Container(color: Colors.red),
            key: Key(item.itemName),
            onDismissed: (direction) {
              deleteItem(i);
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("${item.itemName} deleted")));
            },
            child: ItemWidget(
              item: item,
            ),
          ));
        }
      }
    }
  }

  List<Item> cart = [];
  List<Widget> itemTiles = [];
  SharedPreferences _prefs;
  String itemName;
  String itemDesc;
  int counter;
  int serialNo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: ListView(
                children: itemTiles,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.325,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: TextField(
                            onChanged: (text) {
                              itemName = text;
                            },
                            textCapitalization: TextCapitalization.sentences,
                            obscureText: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(width: 10),
                              ),
                              fillColor: Utils.getColor(primaryColor),
                              labelText: 'Item Name',
                              prefixIcon: Icon(Icons.description),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: TextField(
                            onChanged: (text) {
                              itemDesc = text;
                            },
                            textCapitalization: TextCapitalization.sentences,
                            obscureText: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(width: 10),
                              ),
                              fillColor: Utils.getColor(primaryColor),
                              labelText: 'Item Description',
                              prefixIcon: Icon(Icons.description),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 2, color: Utils.getColor(primaryColor)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Enter Item Quantity'),
                              Padding(padding: EdgeInsets.all(15)),
                              QuantityWidget(
                                counter: counter,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding: EdgeInsets.all(10),
                        child: AuthButton(
                          btnText: 'Add Item',
                          onTap: () async {
                            Item item = new Item(
                                serialNo: serialNo,
                                itemName: itemName,
                                desc: itemDesc,
                                quantity: counter);
                            addItem(item);
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.1,
                        padding: EdgeInsets.all(10),
                        child: AuthButton(
                          btnText: 'Clear Cart',
                          onTap: () {
                            setState(() {
                              clearCart();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void addItem(Item item) async {
    setState(() {
      itemTiles.add(Dismissible(
        background: Container(color: Colors.red),
        key: Key(item.itemName),
        onDismissed: (direction) {
          deleteItem(serialNo);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("${item.itemName} deleted")));
        },
        child: ItemWidget(
          item: item,
        ),
      ));
      print(item.toJson());
      _prefs.setString('$serialNo', item.toJson());
      serialNo++;
      _prefs.setInt('Serial', serialNo);
      counter = 0;
      itemDesc = '';
      itemName = '';
    });
  }

  void clearCart() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
  }

  void deleteItem(int ind) {}
}
