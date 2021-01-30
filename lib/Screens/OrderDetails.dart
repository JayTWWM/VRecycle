import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
  
  var order;
  var parent;

  OrderDetails({Key key, @required this.order, @required this.parent}): super(key: key);
}

class _OrderDetailsState extends State<OrderDetails>{
  GoogleMapController mapController;
  String username = "";
  LatLng _center;
  Map<MarkerId, Marker> markers;

  Firestore _db = Firestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    var user_doc = _db
                  .collection('Users')
                  .document(widget.order["phoneNumberUser"])
                  .get();

    print("YEAAAAAAH");
    print(widget.order["phoneNumberUser"]);

    user_doc.then((value) => {
      setState(()=>{
        username = value.data["name"]
      })
    });
  }

 void setMapLocation(){
    _center = LatLng(widget.order["location"].latitude, widget.order["location"].longitude);

    markers = <MarkerId, Marker>{MarkerId('marker_id_1'):Marker(
    markerId: MarkerId(widget.order["address"]),
    position: _center,
    infoWindow: InfoWindow(title: widget.order["address"], snippet: 'Customer: '+widget.order["phoneNumberUser"]),
    
     )};
 }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {

    setMapLocation();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.getColor(primaryColor),
        title: Text("Order Details"),
        centerTitle: true,
      ),
      body: getBody(),
    ); 
  }

  Widget getOrderImage(){
    return Image.memory(base64Decode(widget.order["proof"]), width: 380, fit: BoxFit.fill);
  }

  getMap(){
    return SizedBox(
              width: MediaQuery.of(context).size.width -32,  // or use fixed size like 200
              height: MediaQuery.of(context).size.height/2,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                ),
                markers: Set<Marker>.of(markers.values),
              ),
            );
  }

  Widget getScrollablePage(){
    return SingleChildScrollView(
      child: Column(
        children:[
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.black,
                size: 40
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.left,),
                  Text(widget.order["phoneNumberUser"], textAlign: TextAlign.left)
                ],
              )
            ],
          ),
          getOrderImage(),
          getMap()
      ])
    );
  }

  Widget getBody(){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Stack(
          children: <Widget>[
            getScrollablePage(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 60,
                  child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                              new RaisedButton(
                                color: Color.fromARGB(255, 255, 0, 0),
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                child: new Text('Decline', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                                onPressed: ()=>{
                                  handleDecline()
                                },
                              ),
                              new RaisedButton(
                                color: Color.fromARGB(255, 0, 255, 0),
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                child: new Text('Accept', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                                onPressed: ()=>{
                                  handleAccept()
                                },
                              ),
                          ]
                  ),
                ),
              ],
            )
          ],
        )
      );}
       final AlertDialog accepted = AlertDialog(
      title: Text('Accepted', style:TextStyle(color:Colors.green),  textAlign: TextAlign.center,),
      content:
      CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  
              ),
      
    );
    final AlertDialog declined = AlertDialog(
      title: Text('Declined', style:TextStyle(color:Colors.red),  textAlign: TextAlign.center,),
      content:
      CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red,
                child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  
              ),
      
    );
    
  

  handleAccept() {
    _db
    .collection('Orders')
    .document(widget.order["id"])
    .updateData({"status": "Order Accepted"})
    .whenComplete(() => {
      print("Updated"),
      widget.parent.setState(()=>{}),
      showDialog<void>(context: context, builder: (ctxt) { Future.delayed(Duration(seconds: 3), () {
          Navigator.of(ctxt).pop(true);
          Navigator.pop(context);
        }); return accepted;}),
    });
  }
  
  handleDecline() {
    _db
    .collection('Orders')
    .document(widget.order["id"])
    .updateData({"status": "Order Declined"})
    .whenComplete(() => {
      print("Updated"),
      widget.parent.setState(()=>{}),
      showDialog<void>(context: context, builder: (ctxt) { Future.delayed(Duration(seconds: 3), () {
            Navigator.of(ctxt).pop(true);
            Navigator.pop(context);
        }); return declined;}), 
    });
  }
}