// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variable.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VariableDataAdapter extends TypeAdapter<VariableData> {
  @override
  final int typeId = 0;

  @override
  VariableData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VariableData(
      value: fields[0] as dynamic,
      isConst: fields[1] as bool,
      expiry: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VariableData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.isConst)
      ..writeByte(2)
      ..write(obj.expiry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
