import 'dart:async';
import 'package:hive/hive.dart';


part 'variable.g.dart';

class Variable extends HiveObject  {
  dynamic _value;

  bool isConst;

  DateTime? expiry; 
  
  final StreamController<dynamic>  _controller = StreamController.broadcast();
  bool _locked = false;

  Variable(this._value, {this.isConst = false, this.expiry});

  Future<void> set(dynamic newValue) async {
    while (_locked) {
      await Future.delayed(Duration(milliseconds: 1));
    }
    _locked = true;

    if (isConst) {
      _locked = false;
      return;
    }

    if (!isConst && _value != newValue) {
      _value = newValue;
      _controller.add(_value);
    }

    _locked = false;
  }

  dynamic get() => _value;
  
  Stream<dynamic> get stream => _controller.stream;
}

@HiveType(typeId: 0)
class VariableData {
  @HiveField(0)
  final dynamic value;

  @HiveField(1)
  final bool isConst;

  @HiveField(2)
  final DateTime? expiry;

  VariableData({
    required this.value,
    required this.isConst,
    required this.expiry,
  });
}
