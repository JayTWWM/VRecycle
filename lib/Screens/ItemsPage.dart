import 'dart:convert';
import 'package:VRecycle/Components/AuthButton.dart';
import 'package:VRecycle/Components/ItemWidget.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Item.dart';
import 'package:VRecycle/Screens/CheckOut.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    getPrefs();
    counter = 0;
    cart = [];
    itemTiles = [];
    isLoaded = true;
  }

  void getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey('Items')) {
      setState(() {
        List<String> temp = _prefs.getStringList('Items');
        for (int i = 0; i < temp.length; i++) {
          String a = temp[i];
          Map<String, dynamic> mapper = json.decode(a);
          Item item = new Item(
              itemName: mapper['itemName'],
              desc: mapper['desc'],
              quantity: mapper['quantity']);
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
      });
    }
    // if (_prefs.containsKey('Serial')) {
    //   serialNo = _prefs.getInt('Serial');
    //   setState(() {
    //     for (int i = 0; i < serialNo; i++) {
    //       if (_prefs.containsKey('$i')) {
    //         print(_prefs.getString('$i'));
    //         Map<String, dynamic> temp = json.decode(_prefs.getString('$i'));
    // Item item = new Item(
    //     serialNo: temp['serialNo'],
    //     itemName: temp['itemName'],
    //     desc: temp['desc'],
    //     quantity: temp['quantity']);
    // cart.add(item);
    //         itemTiles.add(Dismissible(
    //           background: Container(color: Colors.red),
    //           key: Key(item.itemName),
    //           onDismissed: (direction) {
    //             deleteItem(i);
    //             Scaffold.of(context).showSnackBar(
    //                 SnackBar(content: Text("${item.itemName} deleted")));
    //           },
    //           child: ItemWidget(
    //             item: item,
    //           ),
    //         ));
    //   }
    // }
    // isLoaded = false;
    //   });
    setState(() {
      isLoaded = false;
    });
  }

  bool isLoaded;
  List<Item> cart;
  List<Widget> itemTiles;
  SharedPreferences _prefs;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  // String itemName;
  // String itemDesc;
  int counter;

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Loader()
        : Container(
            child: Column(
              children: [
                Flexible(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      color: Utils.getColor(primaryColor),
                      child: ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, i) {
                          return Dismissible(
                            background: Container(color: Colors.red),
                            key: Key(cart[i].itemName),
                            onDismissed: (direction) {
                              deleteItem(i);
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content:
                                      Text("${cart[i].itemName} deleted")));
                            },
                            child: ItemWidget(
                              item: cart[i],
                            ),
                          );
                        },
                      )),
                ),
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: TextField(
                                controller: nameController,
                                // onChanged: (text) {
                                //   itemName = text;
                                // },
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                controller: descController,
                                // onChanged: (text) {
                                //   itemDesc = text;
                                // },
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                    width: 2,
                                    color: Utils.getColor(primaryColor)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Enter Item Quantity'),
                                  Padding(padding: EdgeInsets.all(15)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2,
                                              color:
                                                  Utils.getColor(primaryColor)),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (counter > 0) {
                                                  counter--;
                                                }
                                              });
                                            },
                                            child: Icon(
                                              Icons.remove,
                                              color:
                                                  Utils.getColor(primaryColor),
                                              size: 18,
                                            )),
                                      ),
                                      Padding(padding: EdgeInsets.all(8)),
                                      Text(
                                        '$counter',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Padding(padding: EdgeInsets.all(8)),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2,
                                              color:
                                                  Utils.getColor(primaryColor)),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                counter++;
                                              });
                                            },
                                            child: Icon(
                                              Icons.add,
                                              color:
                                                  Utils.getColor(primaryColor),
                                              size: 18,
                                            )),
                                      ),
                                    ],
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
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: AuthButton(
                              btnText: 'Add Item',
                              onTap: () async {
                                Item item = new Item(
                                    itemName: nameController.text.trim(),
                                    desc: descController.text.trim(),
                                    quantity: counter);
                                addItem(item);
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: Utils.getColor(primaryColor),
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: AuthButton(
                              isOutlined: true,
                              btnText: 'Place an Order',
                              onTap: () {
                                // clearCart();
                                cart.length == 0
                                    ? Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("Your cart is empty/")))
                                    : Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: CheckOutPage(cart: cart)));
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
          );
  }

  void addItem(Item item) {
    setState(() {
      isLoaded = true;
    });
    setState(() {
      List<String> temp;
      if (_prefs.containsKey('Items')) {
        temp = _prefs.getStringList('Items');
      } else {
        temp = [];
      }
      int ind = temp.length;
      temp.add(item.toJson());
      _prefs.setStringList('Items', temp);
      cart.add(item);
      itemTiles.add(Dismissible(
        background: Container(color: Colors.red),
        key: Key(item.itemName),
        onDismissed: (direction) {
          deleteItem(ind);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("${item.itemName} deleted")));
        },
        child: ItemWidget(
          item: item,
        ),
      ));
      counter = 0;
      nameController.clear();
      descController.clear();
      FocusManager.instance.primaryFocus.unfocus();
      isLoaded = false;

      print(cart.length);
      print(itemTiles.length);
    });

    // setState(() {
    // itemTiles.add(Dismissible(
    //   background: Container(color: Colors.red),
    //   key: Key(item.itemName),
    //   onDismissed: (direction) {
    //     deleteItem(serialNo);
    //     Scaffold.of(context).showSnackBar(
    //         SnackBar(content: Text("${item.itemName} deleted")));
    //   },
    //   child: ItemWidget(
    //     item: item,
    //   ),
    // ));
    //   print(item.toJson());
    //   _prefs.setString('$serialNo', item.toJson());
    //   serialNo++;
    //   _prefs.setInt('Serial', serialNo);
    // counter = 0;
    // nameController.clear();
    // descController.clear();
    // FocusManager.instance.primaryFocus.unfocus();
    //   // itemDesc = '';
    //   // itemName = '';
    // });
  }

  void clearCart() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
    setState(() {
      cart.clear();
      itemTiles.clear();
    });
  }

  void deleteItem(int ind) {
    List<String> temp = _prefs.getStringList('Items');
    temp.removeAt(ind);
    cart.removeAt(ind);
    itemTiles.removeAt(ind);
    _prefs.setStringList('Items', temp);
    setState(() {
      print(cart.length);
      print(itemTiles.length);
    });
  }
}
