import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Item.dart';
import 'package:VRecycle/Model/Order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderWidget extends StatefulWidget {
  final Order order;

  OrderWidget({@required this.order});

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        margin: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Number of Items: ${widget.order.items.length}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text(
              'Time: ${DateFormat('dd-MM-yyyy kk:mm').format(widget.order.timestamp.toDate())}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.order.status == "Order Declined"
                    ? Colors.red[600]
                    : Colors.green[300],
              ),
              child: Text(
                '${widget.order.status}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20,
                    color: widget.order.status == "Order Declined"
                        ? Colors.white
                        : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
