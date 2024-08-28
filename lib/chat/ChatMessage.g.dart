// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChatMessage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 4;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      messageText: fields[0] as String?,
      timestamp: fields[1] as DateTime?,
      whoSent: fields[2] as String?,
      isMe: fields[3] as bool?,
      whoReceived: fields[4] as String?,
      chatId: fields[5] as String?,
      wasRead: fields[6] as bool?
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.messageText)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.whoSent)
      ..writeByte(3)
      ..write(obj.isMe)
      ..writeByte(4)
      ..write(obj.whoReceived)
      ..writeByte(5)
      ..write(obj.chatId)
      ..writeByte(6)
      ..write(obj.wasRead);

  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
