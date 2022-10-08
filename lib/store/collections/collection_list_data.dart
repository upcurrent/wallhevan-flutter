class CollectionListData {
  CollectionListData({
      required this.id,
      required this.label,
      required this.views,
      required this.public,
      required this.count,});

  factory CollectionListData.fromJson(dynamic json) {
    return CollectionListData(
    id : json['id'],
    label : json['label'],
    views : json['views'],
    public : json['public'],
    count : json['count']);
  }
  final int id;
  final String label;
  final int views;
  final int public;
  final int count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['label'] = label;
    map['views'] = views;
    map['public'] = public;
    map['count'] = count;
    return map;
  }

}