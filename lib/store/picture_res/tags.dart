class Tags {
  Tags({
     required this.id,
     required this.name,
     required this.alias,
     required this.categoryId,
     required this.category,
     required this.purity,
     required this.createdAt,});

  factory Tags.fromJson(dynamic json) {
    return Tags(
        id : json['id'],
        name : json['name'],
        alias : json['alias'],
        categoryId : json['category_id'],
        category : json['category'],
        purity : json['purity'],
        createdAt : json['created_at'],
    );

  }
  final int id;
  final String name;
  final String alias;
  final int categoryId;
  final String category;
  final String purity;
  final String createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['alias'] = alias;
    map['category_id'] = categoryId;
    map['category'] = category;
    map['purity'] = purity;
    map['created_at'] = createdAt;
    return map;
  }

}