import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: size.height,
        width: size.width,
        color: Colors.white.withOpacity(0.01),
        child: Center(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 200,
                        spreadRadius: 2000,
                        color: Colors.black38)
                  ]),
              padding: EdgeInsets.all(5),
              child: FlatButton.icon(
                  onPressed: () {},
                  icon: CupertinoActivityIndicator(radius: 12),
                  label: Text('  Please wait...'))),
        ),
      ),
    );
  }
}
