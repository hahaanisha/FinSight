
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:testvjti/Pages/transactionPage.dart';
import 'package:testvjti/Pages/user_list_page.dart';

import 'Colors.dart';
import 'CustomerSupport.dart';
import 'QrCodePage.dart';
import 'TestModel.dart';
import 'add_user_page.dart';
import 'home_page.dart';

class BottomNavBarPage extends StatefulWidget {
  @override
  _BottomNavBarPageState createState() => _BottomNavBarPageState();
}


final FlutterTts _flutterTts = FlutterTts();


class _BottomNavBarPageState extends State<BottomNavBarPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  backgroundColor: appBlue,
  title: InkWell(
    onTap: (){
      _flutterTts.stop();
    },
    child: Row(
      children: [

        Text(
          '⠠⠋⠊⠝⠠⠎⠊⠣⠞ ',
          style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(width: 10,),


        InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddUserPage()),
              );
            },
            child: Icon(Icons.add,color: Colors.white,)),
        SizedBox(width: 10,),


        InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserListPage()),
              );
            },
            child: Icon(Icons.list,color: Colors.white,)),
        SizedBox(width: 10,),


        InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerPage()),
              );
            },
            child: Icon(Icons.list,color: Colors.white,)),
      ],
    ),
  ),

  centerTitle: true,
),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          TestModel(),
          CustomerSupport(),
          TransactionPage(),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Financial Advisor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_rounded),
            label: "Customer Support",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: "Transactions",
          ),
        ],
      ),
    );
  }
}
