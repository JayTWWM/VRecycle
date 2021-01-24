import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Item.dart';
import 'package:flutter/material.dart';

class ItemWidget extends StatefulWidget {
  Item item;

  ItemWidget({@required this.item});

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        color: Colors.white,
        margin: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '${widget.item.itemName}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Utils.getColor(primaryColor),
                      size: 24.0,
                    ),
                    Text(
                      '${widget.item.quantity}',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '${widget.item.desc}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
