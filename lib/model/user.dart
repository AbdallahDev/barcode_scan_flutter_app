import 'package:meta/meta.dart';

class User {
  int _userId;
  String _userName;
  int _userTypeId;

  User({
    @required userId,
    @required userName,
    @required userTypeId,
  })  : _userId = userId,
        _userName = userName,
        _userTypeId = userTypeId;

  int get userId => _userId;

  String get userName => _userName;

  int get userTypeId => _userTypeId;

  User.fromMap(Map map) {
    _userId = map["user_id"];
    _userName = map["user_name"];
    _userTypeId = map["userType_id"];
  }
}
