import 'collection_list_data.dart';

class CollectionList {
  CollectionList({
      this.collectionListData,});

  CollectionList.fromJson(dynamic json) {
    if (json['data'] != null) {
      collectionListData = [];
      json['data'].forEach((v) {
        collectionListData!.add(CollectionListData.fromJson(v));
      });
    }
  }
  List<CollectionListData>? collectionListData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (collectionListData != null) {
      map['data'] = collectionListData!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}