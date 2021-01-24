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
        color: Colors.white,
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Text('${widget.item.itemName}'),
            Text('${widget.item.desc}'),
            Text('${widget.item.quantity}'),
          ],
        ),
      ),
    );
  }
}
