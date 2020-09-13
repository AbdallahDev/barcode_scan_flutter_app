import 'package:meta/meta.dart';

class Checked {
  String _userName;
  String _locationName;
  String _transactionDateTime;

  Checked({
    @required userName,
    @required locationName,
    @required dateTime,
  })  : _userName = userName,
        _locationName = locationName,
        _transactionDateTime = dateTime;

  String get userName => _userName;

  String get locationName => _locationName;

  String get dateTime => _transactionDateTime;

  Checked.fromMap(Map map) {
    _userName = map["user_name"];
    _locationName = map["location_name"];
    _transactionDateTime = map["transaction_date_time"];
  }
}
