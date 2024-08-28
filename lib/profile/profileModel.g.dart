// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profileModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 1;

  @override
  ProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileModel(
      nickname: fields[0] as String,
      gender: fields[1] as String,
      rent: fields[2] as String,
      age: fields[3] as int,
      introduction: fields[4] as String,
      selectedOption: fields[5] as String,
      hygieneLevel: fields[6] as String,
      userType: fields[7] as String,
      userId: fields[8] as String,
      photoUrls: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.nickname)
      ..writeByte(1)
      ..write(obj.gender)
      ..writeByte(2)
      ..write(obj.rent)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.introduction)
      ..writeByte(5)
      ..write(obj.selectedOption)
      ..writeByte(6)
      ..write(obj.hygieneLevel)
      ..writeByte(7)
      ..write(obj.userType)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.photoUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
