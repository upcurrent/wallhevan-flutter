import 'fav_data.dart';

class FavoritesRes {
  FavoritesRes({
      this.favData,});

  FavoritesRes.fromJson(dynamic json) {
    if (json['data'] != null) {
      favData = [];
      json['data'].forEach((v) {
        favData!.add(FavData.fromJson(v));
      });
    }
  }
  List<FavData>? favData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (favData != null) {
      map['data'] = favData!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}