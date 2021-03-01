import 'package:flutter/material.dart';

class OrderStatuses extends StatefulWidget {
  @override
  _OrderStatusesState createState() => _OrderStatusesState();
}

class _OrderStatusesState extends State<OrderStatuses> with SingleTickerProviderStateMixin{
  TabController tabController;
  
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
  }

  Widget getTabBar() {
  return TabBar(controller: tabController, tabs: [
    Tab(text: "Offered"),
    Tab(text: "Accepted"),
    Tab(text: "Completed"),
    ]);
  }

  Widget getTabBarPages() {
    return TabBarView(controller: tabController, children: [
              ListView.builder(
                itemBuilder: (context, position) {
                return Card(
                margin: EdgeInsets.all(12),
                elevation: 4,
                color: Color.fromRGBO(136, 14, 79, 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Jumping", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(255, 255, 255, 1))),
                          SizedBox(height: 4),
                          Text("03-08-19", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      Spacer(),
                      Image(image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'), height: 80, width: 80),
                    ],
                  ),
                ),
              );
            },
            ),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            flexibleSpace: SafeArea(
              child: getTabBar(),
            ),
          ),
          body: getTabBarPages()
      );
  }
}
