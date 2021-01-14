import 'package:meta/meta.dart';

class Product {
  int _productId;
  String _productName;
  String _productPrice;

  Product({@required productId, @required productName, @required productPrice})
      : _productId = productId,
        _productName = productName,
        _productPrice = productPrice;

  int get productId => _productId;

  String get productName => _productName;

  String get productPrice => _productPrice;

  Product.fromMap(Map map) {
    _productId = map['product_id'];
    _productName = map['product_name'];
    _productPrice = map['product_price'];
  }
}
