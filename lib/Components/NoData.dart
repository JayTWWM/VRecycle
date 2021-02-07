import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String text;

  const NoData({Key key, @required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, 
          children:[
            Icon(Icons.info_outline, color: Color.fromARGB(255, 105, 115, 124)),
            Text(this.text, style: TextStyle(color: Color.fromARGB(255, 105, 115, 124), fontWeight:FontWeight.bold), textAlign: TextAlign.center,)
          ])
    );
  }
}
