import 'package:hive/hive.dart';
part 'profileModel.g.dart';

@HiveType(typeId: 1)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String nickname;
  
  @HiveField(1)
  String gender;

  @HiveField(2)
  String rent;

  @HiveField(3)
  int age;

  @HiveField(4)
  String introduction;

  @HiveField(5)
  String selectedOption;

  @HiveField(6)
  String hygieneLevel;

  @HiveField(7)
  String userType;

  @HiveField(8)
  String userId;

  @HiveField(9)
  String photoUrls;

  ProfileModel({
    required this.nickname,
    required this.gender,
    required this.rent,
    required this.age,
    required this.introduction,
    required this.selectedOption,
    required this.hygieneLevel,
    required this.userType,
    required this.userId,
    required this.photoUrls,
  });
}
