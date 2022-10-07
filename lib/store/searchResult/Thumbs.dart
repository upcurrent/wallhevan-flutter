class Thumbs {
  Thumbs({
    this.large,
    this.original,
    this.small,});

  Thumbs.fromJson(dynamic json) {
    large = json['large'];
    original = json['original'];
    small = json['small'];
  }
  String? large;
  String? original;
  String? small;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['large'] = large;
    map['original'] = original;
    map['small'] = small;
    return map;
  }

}