import 'Avatar.dart';

class Uploader {
  Uploader({
    required this.username,
    required this.group,
    required this.avatar,
  });

  factory Uploader.fromJson(dynamic json) {
    return Uploader(
      username: json['username'],
      group: json['group'],
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
    );
  }
  String username;
  String group;
  Avatar? avatar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['group'] = group;
    if (avatar != null) {
      map['avatar'] = avatar!.toJson();
    }
    return map;
  }
}
