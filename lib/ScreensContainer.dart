import 'package:expensemanager/AnalyticsScreen.dart';
import 'package:expensemanager/AppConstants.dart';
import 'package:expensemanager/DashboardScreen.dart';
import 'package:expensemanager/HistoryScreen.dart';
import 'package:flutter/material.dart';

class ScreensContainer extends StatefulWidget {
  final String userID;
  const ScreensContainer(this.userID, {super.key});

  @override
  State<ScreensContainer> createState() => _ScreensContainer();
}

class _ScreensContainer extends State<ScreensContainer> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  print("History");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HistoryScreen(widget.userID)),
                  );
                },
                child: const Icon(
                  Icons.history,
                  size: 26.0,
                ),
              )),
        ],
        leading: GestureDetector(
            onTap: () {
              AppConstants.constantsInstance.showAlertDialogWithButton(context,
                  "Logout", "Do you want to logout?", DialogforEnum.dashboard);
            },
            child: const Icon(Icons.logout)),
        title: Text("Welcome ${widget.userID}"),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber[800],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          //First
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          //Second
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          //Can Add New
        ],
      ),
      body: <Widget>[
        //First
        DashboardScreen(widget.userID),
        //Second
        AlalyticsScreen(widget.userID)
        //Can Add Third
      ][currentPageIndex],
    );
  }
}
