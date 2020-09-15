import 'dart:convert';

import 'package:barcode_scan_flutter_app/model/checked.dart';
import 'package:barcode_scan_flutter_app/model/user.dart';
import 'package:barcode_scan_flutter_app/static/staticVars.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowUserChecked extends StatefulWidget {
  @override
  _ShowUserCheckedState createState() => _ShowUserCheckedState();
}

class _ShowUserCheckedState extends State<ShowUserChecked> {
  int selectedId = 0;
  List<Checked> _checked = [
    Checked(
        userName: "username",
        locationName: "locationName",
        dateTime: "dateTime")
  ];
  List<User> _distributorList;
  User _selectedDistributor;

  @override
  void initState() {
    super.initState();
    _distributorList = [
      User(userId: 0, userName: "Choose a distributor", userTypeId: 0)
    ];
    _selectedDistributor = _distributorList[0];
    _fillDistributorList();
  }

  _fillDistributorList() async {
    var url = StaticVars.url + "get_all_distributor.php";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      list.forEach((map) {
        _distributorList.add(User.fromMap(map));
      });
      setState(() {});
    }
  }

  Widget _buildDistributorDropDownButton() {
    return DropdownButton<User>(
      underline: Container(
        height: 3,
        color: Colors.white,
      ),
      dropdownColor: Color(0xFF73AEF5),
      value: _selectedDistributor,
      icon: Icon(
        Icons.arrow_drop_down_circle,
        color: Colors.white,
      ),
      items: _distributorList.map((User distributor) {
        return DropdownMenuItem(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                distributor.userName,
                style: TextStyle(color: Colors.white),
              ),
            ),
            value: distributor);
      }).toList(),
      onChanged: (User distributor) {
        setState(() {
          _selectedDistributor = distributor;
          _fillCheckedList(userId: _selectedDistributor.userId);
        });
      },
    );
  }

  _fillCheckedList({@required userId}) async {
    selectedId = userId;
    var url = StaticVars.url + "show_checked.php?userId=$userId";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      _checked = [Checked(userName: "", locationName: "", dateTime: "")];
      list.forEach((map) {
        _checked.add(Checked.fromMap(map));
      });
      setState(() {});
    }
  }

  Widget buildListView() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 11, right: 11),
        itemCount: _checked.length,
        itemBuilder: (context, position) {
          if (selectedId != 0) {
            if (position != 0) {
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: Card(
                  elevation: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Name: ",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _checked[position].userName,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Location: ",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _checked[position].locationName,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Date: ",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _checked[position].dateTime,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF73AEF5),
                  Color(0xFF61A4F1),
                  Color(0xFF478DE0),
                  Color(0xFF398AE5),
                ],
                stops: [
                  0.1,
                  0.4,
                  0.7,
                  0.9,
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.only(bottom: 500),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildDistributorDropDownButton()],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.only(top: 210, bottom: 90),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [buildListView()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
