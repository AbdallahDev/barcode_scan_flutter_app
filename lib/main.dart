import 'package:barcode_scan_flutter_app/model/checked.dart';
import 'package:barcode_scan_flutter_app/static/staticVars.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner',
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String productName = "";
  String selectedValue = "Choose a product";
  List<String> barCodes = [
    "00000",
  ];
  String result = "";
  final blackTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );
  final whiteTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );
  final blueTextStyle = TextStyle(
    color: Colors.blueAccent,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  Widget buildListView() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 11, right: 11),
        itemCount: barCodes.length,
        itemBuilder: (context, position) {
          if (barCodes[position] != "00000") {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  barCodes[position],
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                buildDeleteButton(position),
              ],
            );
          } else {
            return Text("");
          }
        });
  }

  Widget buildDeleteButton(int position) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Column(
        children: [
          Container(
            child: RaisedButton(
              elevation: 5,
              onPressed: () {
                barCodes.removeAt(position);
                setState(() {});
              },
              child: Text(
                "Delete",
                style: blueTextStyle,
              ),
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.white,
            ),
            padding: EdgeInsets.only(top: 5, bottom: 5),
          ),
        ],
      ),
    );
  }

  void _callSaveBarCodesFunction() {
    for (var i = 0; i < barCodes.length; i++) {
      _saveToken(barCodes[i], productName);
    }
  }

  Future _scanQR() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult.rawContent;
        productName = selectedValue;
        barCodes.add(qrResult.rawContent);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result = "Camera Permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything!";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  void _saveToken(String barCode, String productName) async {
    // var ipLocal = "192.168.0.29";
    var ipServer = "193.188.88.148";
    var url =
        "http://$ipServer/apps/test/BarcodeScan/apis/events_insert.php?barcode=$barCode&productName=$productName";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        result = "good";
      });
    } else {
      // If the server did not return a 200 OK response,
      setState(() {
        result = "error";
      });
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
                  children: [
                    DropdownButton<String>(
                      underline: Container(
                        height: 3,
                        color: Colors.white,
                      ),
                      dropdownColor: Color(0xFF73AEF5),
                      value: selectedValue,
                      icon: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.white,
                      ),
                      items: <String>[
                        "Choose a product",
                        'Cell phones',
                        'Laptops',
                        'Smart watches'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              value,
                              style: whiteTextStyle,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(top: 210, bottom: 90),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildListView(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            onPressed: _callSaveBarCodesFunction,
            label: Text("Submit"),
            icon: Icon(Icons.radio_button_on_outlined),
            heroTag: "submit",
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton.extended(
            onPressed: _scanQR,
            label: Text("Scan"),
            icon: Icon(Icons.camera_alt),
            heroTag: "scan",
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final kHintTextStyle = TextStyle(
    color: Colors.white54,
    fontFamily: 'OpenSans',
  );
  final kLabelStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );
  final kBoxDecorationStyle = BoxDecoration(
    color: Color(0xFF6CA8F1),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  Widget buildUsernameTf() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Username",
          style: kLabelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60,
          child: TextField(
            controller: usernameController,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: "User Name",
              hintStyle: kHintTextStyle,
            ),
          ),
        )
      ],
    );
  }

  Widget buildPasswordTf() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: kLabelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: "Password",
              hintStyle: kHintTextStyle,
            ),
          ),
        )
      ],
    );
  }

  Widget buildLoginButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5,
        onPressed: () {
          StaticVars.userId = int.parse(usernameController.text);
          if (usernameController.text == "1" &&
              passwordController.text == "123") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShowUserChecked()),
            );
          } else if (usernameController.text == "2" &&
              passwordController.text == "123") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SaveChecked()),
            );
          }
        },
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.white,
        child: Text(
          "LOGIN",
          style: TextStyle(
              color: Color(0xFF527DAA),
              letterSpacing: 1.5,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans'),
        ),
      ),
    );
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
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 120,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'OpenSans',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  buildUsernameTf(),
                  SizedBox(
                    height: 30,
                  ),
                  buildPasswordTf(),
                  buildLoginButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowUserChecked extends StatefulWidget {
  @override
  _ShowUserCheckedState createState() => _ShowUserCheckedState();
}

class _ShowUserCheckedState extends State<ShowUserChecked> {
  String selectedValue = "Choose a distributor";
  String selectedId = "0";
  List<List> users = [
    ["0", "distributor1", "time2", "date3", "location4"],
    ["1", "Ahmad Ali", "10:00", "9/9/2020", "Amman"],
    ["2", "Mohammad Ali", "11:00", "10/9/2020", "Karak"],
    ["3", "Faris Hassan", "12:00", "11/9/2020", "Aqaba"],
    ["1", "Ahmad Ali", "14:00", "13/8/2020", "Zarqa"],
    ["2", "Mohammad Ali", "11:00", "20/8/2020", "Madaba"],
    ["3", "Faris Hassan", "12:00", "23/7/2020", "Ma'an"],
  ];
  List<Checked> _checked = [
    Checked(
        userName: "username",
        locationName: "locationName",
        dateTime: "dateTime")
  ];

  _fillCheckedList({@required userId}) async {
    userId = int.parse(userId);
    var ipLocal = "192.168.0.29";
    // var ipServer = "193.188.88.148";
    var url =
        "http://$ipLocal/apps/myapps/barcodescan/apis/show_checked.php?userId=$userId";
    var response = await http.get(url);
  }

  Widget buildListView() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 11, right: 11),
        itemCount: users.length,
        itemBuilder: (context, position) {
          if (selectedId == "0") {
            if (users[position][0] != "0") {
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
                              users[position][1],
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
                              users[position][4],
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
                              users[position][3],
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Time: ",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              users[position][2],
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
            if (users[position][0] == selectedId) {
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
                              users[position][1],
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
                              users[position][4],
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
                              users[position][3],
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Time: ",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              users[position][2],
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
                  children: [
                    DropdownButton(
                      underline: Container(
                        height: 3,
                        color: Colors.white,
                      ),
                      dropdownColor: Color(0xFF73AEF5),
                      value: selectedValue,
                      icon: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.white,
                      ),
                      items: <String>[
                        "Choose a distributor",
                        'Ahmad Ali',
                        'Mohammad Ali',
                        'Faris Hassan'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                          if (selectedValue == "Ahmad Ali")
                            selectedId = "1";
                          else if (selectedValue == "Mohammad Ali")
                            selectedId = "2";
                          else if (selectedValue == "Faris Hassan")
                            selectedId = "3";
                          else
                            selectedId = "0";
                        });

                        _fillCheckedList(userId: selectedId);
                      },
                    ),
                  ],
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

class SaveChecked extends StatefulWidget {
  @override
  _SaveCheckedState createState() => _SaveCheckedState();
}

class _SaveCheckedState extends State<SaveChecked> {
  String result = "";

  Future _scanQR() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult.rawContent;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result = "Camera Permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything!";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  void _saveBarcode() async {
    var userId = StaticVars.userId;
    // var ipLocal = "192.168.0.29";
    var ipServer = "193.188.88.148";
    var url =
        "http://$ipServer/apps/myapps/barcodescan/apis/save_checked.php?locationBarcode=$result&userId=$userId";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        result = "You have checked in successfully.";
      });
    } else {
      // If the server did not return a 200 OK response,
      setState(() {
        result = "Something wrong happened.";
      });
      // then throw an exception.
      throw Exception('Failed to load album');
    }
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
            alignment: Alignment.center,
            child: Text(result),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            onPressed: _saveBarcode,
            label: Text("Submit"),
            icon: Icon(Icons.radio_button_on_outlined),
            heroTag: "submit",
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton.extended(
            onPressed: _scanQR,
            label: Text("Scan"),
            icon: Icon(Icons.camera_alt),
            heroTag: "scan",
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
