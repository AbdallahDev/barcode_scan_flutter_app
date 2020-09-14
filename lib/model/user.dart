import 'package:meta/meta.dart';

class User {
  String _userName;
  int _userTypeId;

  User({
    @required userName,
    @required userTypeId,
  })  : _userTypeId = userTypeId,
        _userName = userName;

  String get userName => _userName;

  int get userTypeId => _userTypeId;

  User.fromMap(Map map) {
    _userName = map["user_name"];
    _userTypeId = map["userType_id"];
  }
}
