import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan_flutter_app/model/product.dart';
import 'package:barcode_scan_flutter_app/screen/login.dart';
import 'package:barcode_scan_flutter_app/screen/saveChecked.dart';
import 'package:barcode_scan_flutter_app/static/staticVars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ScanProduct extends StatefulWidget {
  ScanProduct({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ScanProductState createState() => _ScanProductState();
}

class _ScanProductState extends State<ScanProduct> {
  String productName = "";
  String selectedValue = "Choose a product";
  List<String> _barcodeList = [
    "00000",
  ];
  List<Product> _productList;
  Product _selectedProduct;
  Product _product =
      Product(productId: 0, productName: "", productPrice: "0.0");
  String _result = "";
  double _price = 0.0;
  double _total = 0.0;
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

  @override
  void initState() {
    super.initState();
    _productList = [
      Product(
          productId: 0, productName: "Choose a product", productPrice: "0.0")
    ];
    _selectedProduct = _productList[0];
    _fillProductList();
  }

  void _fillProductList() async {
    var url = StaticVars.url + "get_all_products.php";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      list.forEach((map) {
        _productList.add(Product.fromMap(map));
      });
      setState(() {});
    }
  }

  Widget _buildProductDropDownButton() {
    return DropdownButton<Product>(
        underline: Container(
          height: 3,
          color: Colors.white,
        ),
        dropdownColor: Color(0xFF73AEF5),
        icon: Icon(
          Icons.arrow_drop_down_circle,
          color: Colors.white,
        ),
        items: _productList.map((Product product) {
          return DropdownMenuItem(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                product.productName,
                style: TextStyle(color: Colors.white),
              ),
            ),
            value: product,
          );
        }).toList(),
        value: _selectedProduct,
        onChanged: (value) {
          _selectedProduct = value;
          _getProductPrice(_selectedProduct.productId);
          setState(() {});
        });
  }

  Widget buildListView() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 11, right: 11),
        itemCount: _barcodeList.length,
        itemBuilder: (context, position) {
          if (_barcodeList[position] != "00000") {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _barcodeList[position],
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
                _barcodeList.removeAt(position);
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

  Future _scanQR() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      setState(() {
        _result = "";
        _total += _price;
        _barcodeList.add(qrResult.rawContent);
      });
      _barcodeList.forEach((element) {
        print(element);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          _result = "Camera Permission was denied";
        });
      } else {
        setState(() {
          _result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        _result = "You pressed the back button before scanning anything!";
      });
    } catch (ex) {
      setState(() {
        _result = "Unknown Error $ex";
      });
    }
  }

  void _callSaveBarCodesFunction() {
    for (var i = 1; i < _barcodeList.length; i++) {
      _saveBarcode(_barcodeList[i], _selectedProduct.productId);
    }
    setState(() {
      _barcodeList = [
        "00000",
      ];
      buildListView();
    });
  }

  void _saveBarcode(String barCode, int productId) async {
    var url = StaticVars.url +
        "save_barcode.php?barcode=$barCode&productId=$productId";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _result = "Product has been saved successfully";
      });
    } else {
      // If the server did not return a 200 OK response,
      setState(() {
        _result = "Something wrong happened";
      });
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  //this function will get the product price
  void _getProductPrice(int productId) async {
    var url = StaticVars.url + "get_product_price.php?productId=$productId";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _product = Product.fromMap(json.decode(response.body)[0]);
        _price = double.parse(_product.productPrice);
      });
    } else {
      // If the server did not return a 200 OK response,
      setState(() {
        _result = "Something wrong happened";
      });
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  _buildAppBar() {
    return AppBar(
      title: Text("Scan Products"),
      centerTitle: true,
      backgroundColor: Color(0xFF73AEF5),
      leading: GestureDetector(
        child: Icon(Icons.fact_check_outlined),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SaveChecked()));
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.only(bottom: 450),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildProductDropDownButton()],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.5),
            child: Text(
              "Total: $_total JOD",
              style: whiteTextStyle,
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
                  children: [
                    buildListView(),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              _result,
              style: whiteTextStyle,
            ),
          )
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
