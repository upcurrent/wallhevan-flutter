class Avatar {
  Avatar({
      required this.p200,
      required this.p128,
      required this.p32,
      required this.p20,});

  factory Avatar.fromJson(dynamic json) {
    return Avatar(
      p200 : json['200px'],
      p128 : json['128px'],
      p32:  json['32px'],
      p20:  json['20px'],
    );
  }
  String p200;
  String p128;
  String p32;
  String p20;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['200px'] = p200;
    map['128px'] = p128;
    map['32px'] =  p32;
    map['20px'] =  p20;
    return map;
  }

}