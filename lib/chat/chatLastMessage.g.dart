// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatLastMessage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatlastmessageAdapter extends TypeAdapter<Chatlastmessage> {
  @override
  final int typeId = 5;

  @override
  Chatlastmessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chatlastmessage(
      messageText: fields[0] as String,
      timestamp: fields[1] as DateTime,
      senderId: fields[2] as String,
      isMe: fields[3] as bool,
      otherUser: fields[4] as String,
      newMessageExists: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Chatlastmessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.messageText)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.isMe)
      ..writeByte(4)
      ..write(obj.otherUser)
      ..writeByte(5)
      ..write(obj.newMessageExists);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatlastmessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
