import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan_flutter_app/screen/login.dart';
import 'package:barcode_scan_flutter_app/screen/scanProduct.dart';
import 'package:barcode_scan_flutter_app/static/staticVars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SaveChecked extends StatefulWidget {
  @override
  _SaveCheckedState createState() => _SaveCheckedState();
}

class _SaveCheckedState extends State<SaveChecked> {
  String result = "";
  String _barcode = "";

  Future _scanQR() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult.rawContent;
        _barcode = qrResult.rawContent;
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
    var url = StaticVars.url +
        "save_checked.php?locationBarcode=" +
        _barcode +
        "&userId=" +
        StaticVars.userId;
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
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

  _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF73AEF5),
      title: Text("Check In"),
      centerTitle: true,
      leading: GestureDetector(
        child: Icon(Icons.qr_code_scanner),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ScanProduct()));
        },
      ),
      actions: [
        GestureDetector(
          child: Icon(Icons.logout),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
