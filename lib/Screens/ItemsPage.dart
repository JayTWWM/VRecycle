import 'package:VRecycle/Components/AuthButton.dart';
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
    itemName = '';
    serialNo = 1;
  }

  String itemName;
  int serialNo;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
          child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.375,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextField(
                          onChanged: (text) {
                            itemName = text;
                          },
                          textCapitalization: TextCapitalization.characters,
                          obscureText: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(width: 10),
                            ),
                            fillColor: Colors.deepOrange,
                            labelText: 'ItemName',
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.125,
                  child: AuthButton(
                    btnText: 'Add Item',
                    onTap: () {
                      Item item =
                          new Item(serialNo: serialNo, itemName: itemName);
                      addItem(item);
                    },
                    isOutlined: true,
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }

  void addItem(Item item) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    
    serialNo++;
    itemName = '';
  }

  void clearCart() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
  }
}
