import 'dart:convert';
import 'package:VRecycle/Components/CircularImage.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Components/MyClipper.dart';
import 'package:VRecycle/Components/NoData.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/ItemsPage.dart';
import 'package:VRecycle/Screens/OrderDetails.dart';
import 'package:VRecycle/Screens/OrderStatuses.dart';
import 'package:VRecycle/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectorHome extends StatefulWidget {
  @override
  _CollectorHomeState createState() => _CollectorHomeState();
}

class _CollectorHomeState extends State<CollectorHome> with SingleTickerProviderStateMixin{
  TabController tabController;
  var uselessVariable;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    getUser();

  }

  String title = 'Collector Home Page';
  User currentUser;
  bool load = false;
  List<String> categories = [];
  Firestore _db = Firestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> getUser() async {
    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
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
          load = true;
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
          load = true;
        });
      }

    print("Hello");
    getOfferedOrders();
    return null;
  }

  Widget appBarIcon({@required IconData icon}) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.black,
        size: 28.0,
      ),
      onPressed: () {},
    );
  }

  Widget mainWidget;

  @override
  Widget build(BuildContext context) {
    return load == false
        ? Loader()
        :MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Text("Offered")),
                Tab(icon: Text("Completed")),
                Tab(icon: Text("Accepted")),
              ],
            ),
            backgroundColor: Utils.getColor(primaryColor),
            elevation: 0.0,
            centerTitle: true,
            title: Text(
                '$title',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'VarelaRound',
                ),
              ),
          ), drawer: Drawer(
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 8,
                  ),
                  color: Colors.white,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipPath(
                          clipper: MyClipper(),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(top: 80),
                            decoration: BoxDecoration(
                                color: Utils.getColor(primaryColor),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 50,
                                      offset: Offset(0, 0))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, top: 10, right: 10.0),
                                    child: GestureDetector(
                                      child: Hero(
                                        tag: 'hiHero',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10, top: 10, bottom: 10),
                                          child: CircularImage(
                                            currentUser.imageUrl != null
                                                ? MemoryImage(
                                                    base64.decode(
                                                        currentUser.imageUrl),
                                                  )
                                                : AssetImage(
                                                    "assets/blank_profile.jpg"),
                                            width: 96,
                                            height: 96,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          mainWidget = CollectorHome();
                                          title = "Profile";
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 50.0),
                                      child: Text(
                                        currentUser.name,
                                        style: new TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Pacifico',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: ListTile(
                              leading: Icon(
                                Icons.person_pin,
                                color: Utils.getColor(
                                    Utils.getColor(primaryColor)),
                                size: 30,
                              ),
                              title: Text(
                                "Profile",
                                style: TextStyle(
                                    color: Utils.getColor(primaryColor),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                setState(() {
                                  mainWidget = Profile();
                                  title = "Profile";
                                });
                                Navigator.pop(context);
                              }),
                        ),
                        Container(
                          child: ListTile(
                              leading: Icon(
                                Icons.person_pin,
                                color: Utils.getColor(
                                    Utils.getColor(primaryColor)),
                                size: 30,
                              ),
                              title: Text(
                                "Add items ",
                                style: TextStyle(
                                    color: Utils.getColor(primaryColor),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                setState(() {
                                  mainWidget = ItemsPage();
                                  title = "Items Page";
                                });
                                Navigator.pop(context);
                              }),
                        ),
                      ]),
                )),
            
          body: TabBarView(
            children: [
              FutureBuilder<List>(
                future: getOfferedOrders(),
                builder:
                  (BuildContext context, AsyncSnapshot<List> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return new Text('Waiting to start');
                      case ConnectionState.waiting:
                        return new Text('Loading...');
                      default:
                            
                            if(snapshot.data.length == 0){
                              return NoData(text: "No offers for you at the moment.\nPlease Try again later...");
                  
                            }


                            return new ListView.builder(
                              itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                return Card(
                                    margin: EdgeInsets.all(12),
                                    elevation: 4,
                                    color: Color.fromARGB(255, 190, 154, 255),
                                    child: InkWell(
                                      onTap: ()=>{
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OrderDetails(order: snapshot.data[index], parent: this)
                                            )
                                        )
                                      },
                                      child: getCardContents(snapshot, index)
                                    )
                                  );
              },
            )
            ;}})
            ,
              NoData(text: "No Orders Completed"),
              NoData(text: "No Orders Accepted ")
            ],
          ),
        ),
      ),
    );
  }

  getOrderTimeDetails(dateTimeObj){
    DateTime dt = DateTime
          .fromMicrosecondsSinceEpoch(dateTimeObj.microsecondsSinceEpoch)
          .toLocal();
    
    return Text(
      "🕒 " + DateFormat('d MMMM y').format(dt) + "\n      " + DateFormat("jm").format(dt),      
      style: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 1)
        )
      );
  }

  getCardContents(snapshot, index) {
    return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(snapshot.data[index]["address"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(255, 255, 255, 1))),
                    SizedBox(height: 8),
                    getOrderTimeDetails(snapshot.data[index]["timestamp"]),
                  ],
                ),
                Spacer(),
                Image.memory(base64Decode(snapshot.data[index]["proof"]), height: 80, width:80, fit: BoxFit.fill),
              ],
            ),
          );
  }

  Future<List<dynamic>> getOfferedOrders () async  {
    List final_ray = [];

    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    var userDoc = await _db
          .collection('Orders')
          .where("offered_to", isEqualTo: firebaseUser.phoneNumber.substring(3))
          .where('status'    , isEqualTo: 'Order Placed')
          .getDocuments();

    for(var docRef in userDoc.documents){
      Map final_data = new Map.from(docRef.data);
      
      final_data.addAll({"id": docRef.documentID});
      final_ray.add(final_data);
    }

    print(final_ray);

    return final_ray;
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }
}
