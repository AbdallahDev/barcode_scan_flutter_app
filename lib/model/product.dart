import 'package:meta/meta.dart';

class Product {
  int _productId;
  String _productName;

  Product({@required productId, @required productName})
      : _productId = productId,
        _productName = productName;

  int get productId => _productId;

  String get productName => _productName;

  Product.fromMap(Map map) {
    _productId = map['product_id'];
    _productName = map['product_name'];
  }
}
