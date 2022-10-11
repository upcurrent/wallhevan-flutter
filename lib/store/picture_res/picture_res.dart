import 'picture_data.dart';

class PictureRes {
  PictureRes({
      this.data,});

  PictureRes.fromJson(dynamic json) {
    data = json['data'] != null ? PictureData.fromJson(json['data']) : null;
  }
  PictureData? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }

}