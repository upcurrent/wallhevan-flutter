import '../search_response/Meta.dart';
import '../search_response/picture_info.dart';

class Collections {
  Collections({
      this.data, 
      this.meta,});

  Collections.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PictureInfo.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
  List<PictureInfo>? data;
  Meta? meta;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    return map;
  }

}