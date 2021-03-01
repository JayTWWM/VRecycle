import 'dart:convert';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/HandleAuth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:VRecycle/Screens/BinCheckOut.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool hasLoaded = false;
  User currentUser;
  Firestore _db = Firestore.instance;
  GoogleMapController mapController;
  final dataKey = new GlobalKey();
  LatLng _center = LatLng(0, 0);
  Map<MarkerId, Marker> markers = new Map();

  List bin_locations = new List();

  double latitude, longitude;

  @override
  void initState() {
    super.initState();
    getuser();
    getBinLocations();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      setState((){
        latitude = position.latitude;
        longitude = position.longitude;
        
        setMapLocation(latitude, longitude);
      });
    } catch (e) {
      print("Unable to get Location.");
    }
  }

  void getBinLocations() async {
    var binDocs = await _db.collection('bins').getDocuments();

    print("LOOOKKKKYYYYY HEREEEE");
    binDocs.documents.forEach((element) {
      bin_locations.add({
        "readable_location": element.data['readable_location'],
        "location"         : LatLng(element.data['location'].latitude, element.data['location'].longitude)
      });
    });

    print(bin_locations);
  }

void setMapLocation(latitude, longitude) {
    _center = LatLng(latitude, longitude);

    int index = 0;
    for(var record in bin_locations){
        
        markers[MarkerId('marker_id_'+index.toString())]= Marker(
        markerId: MarkerId("marker_id_"+index.toString()),
        position: record['location'],
        infoWindow: InfoWindow(
            title: record['readable_location'],
            snippet: 'Bin, Click to Request Pickup',
            onTap: () async {
              
              final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
              
              var docs = await _db.collection("bin_moderator")
              .where('phone_number', isEqualTo: firebaseUser.phoneNumber.substring(3))
              .getDocuments();
              
              if(docs.documents.length >= 1){
                Navigator.push(context, MaterialPageRoute(builder: (context) => BinCheckOutPage(bin_location: record)));
                print(record['readable_location']);
              }else{
    
                showDialog<void>(
                  context: context,
                  builder: (ctxt) {
                    return AlertDialog(
                            title: Text(
                              'You are not allowed to request bin pickups! Please contact the Administrator',
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          );
                  });
     
              }
            }  
        ),
      );
      index++;
    }
  }
  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  
  getMap() {
    return Container(
      width: 400,
      height: 400,
      key: dataKey,
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
  
  getuser() async {
    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    if (firebaseUser == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HandleAuth()));
    } else {
      var userDoc = await _db
          .collection('Users')
          .document(firebaseUser.phoneNumber.substring(3))
          .get();
      if (userDoc.exists) {
        var fireIns = _db
            .collection('Users')
            .document(firebaseUser.phoneNumber.substring(3));
        DocumentSnapshot doc = await fireIns.get();
        User user = User.fromDocument(doc);
        setState(() {
          currentUser = user;
          print(currentUser.address + " " + currentUser.email);
          hasLoaded = true;
        });
      } else {
        var fireIns = _db
            .collection('Collectors')
            .document(firebaseUser.phoneNumber.substring(3));
        DocumentSnapshot doc = await fireIns.get();
        print(doc.data);
        User user = User.fromDocument(doc);
        setState(() {
          currentUser = user;
          print(currentUser.address + " " + currentUser.email);
          hasLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: hasLoaded
            ? SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                    ClipPath(
                      clipper: MyClipper(),
                      child: Container(
                          padding: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              color: Utils.getColor(primaryColor),
                              boxShadow: [
                                BoxShadow(
                                    color: Utils.getColor(primaryColor),
                                    blurRadius: 50,
                                    offset: Offset(0, 0))
                              ]),
                          child: Container(
                            width: double.infinity,
                            child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 1.0),
                                      child: new Stack(
                                          fit: StackFit.loose,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Hero(
                                                  tag: "hi",
                                                  child: AvatarGlow(
                                                    glowColor: Colors.white,
                                                    endRadius: 100,
                                                    child: Material(
                                                      elevation: 50.0,
                                                      shape: CircleBorder(),
                                                      child: Container(
                                                        width: 130,
                                                        height: 130,
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: DecorationImage(
                                                                image: MemoryImage(
                                                                  base64Decode(
                                                                      currentUser
                                                                          .imageUrl),
                                                                ),
                                                                fit: BoxFit.cover)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0),
                                                  child: new Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 100,
                                                        child: new Text(
                                                          currentUser.name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: new TextStyle(
                                                              fontSize: 26.0,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 150,
                                                        child: new Text(
                                                          currentUser.email,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: new TextStyle(
                                                              fontSize: 14.0,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 40,
                                              width: 200,
                                              child: Divider(
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ]),
                            ),
                          )),
                    ),
                    Padding(
                      child: Text("Bins Near You", textAlign: TextAlign.left,),
                      padding: EdgeInsets.all(22),
                    )
                    ,
                    //map here
                    getMap()
                  ]))
            : Loader());
  }
}
