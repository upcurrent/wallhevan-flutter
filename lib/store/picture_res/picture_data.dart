import 'uploader.dart';
import '../search_result/thumbs.dart';
import 'tags.dart';

class PictureData {
  PictureData({
      required this.id,
      required this.url,
      required this.shortUrl,
      required this.uploader,
      required this.views,
      required this.favorites,
      required this.source,
      required this.purity,
      required this.category,
      required this.dimensionX,
      required this.dimensionY,
      required this.resolution,
      required this.ratio,
      required this.fileSize,
      required this.fileType,
      required this.createdAt,
      required this.colors,
      required this.path,
      required this.thumbs,
      required this.tags,});

  factory PictureData.fromJson(dynamic json) {
    List<Tags> tags = [];
    if (json['tags'] != null) {
      json['tags'].forEach((v) {
        tags.add(Tags.fromJson(v));
      });
    }
    return PictureData(
      id : json['id'],
      url : json['url'],
      shortUrl : json['short_url'],
      uploader : json['uploader'] != null ? Uploader.fromJson(json['uploader']) : null,
      views : json['views'],
      favorites : json['favorites'],
      source : json['source'],
      purity : json['purity'],
      category : json['category'],
      dimensionX : json['dimension_x'],
      dimensionY : json['dimension_y'],
      resolution : json['resolution'],
      ratio : json['ratio'],
      fileSize : json['file_size'],
      fileType : json['file_type'],
      createdAt : json['created_at'],
      colors : json['colors'] != null ? json['colors'].cast<String>() : [],
      path : json['path'],
      thumbs : json['thumbs'],
      tags:tags,
    );
  }
  String id;
  String url;
  String shortUrl;
  Uploader? uploader;
  int views;
  int favorites;
  String source;
  String purity;
  String category;
  int dimensionX;
  int dimensionY;
  String resolution;
  String ratio;
  int fileSize;
  String fileType;
  String createdAt;
  List<String> colors;
  String path;
  Thumbs? thumbs;
  List<Tags> tags;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['url'] = url;
    map['short_url'] = shortUrl;
    if (uploader != null) {
      map['uploader'] = uploader!.toJson();
    }
    map['views'] = views;
    map['favorites'] = favorites;
    map['source'] = source;
    map['purity'] = purity;
    map['category'] = category;
    map['dimension_x'] = dimensionX;
    map['dimension_y'] = dimensionY;
    map['resolution'] = resolution;
    map['ratio'] = ratio;
    map['file_size'] = fileSize;
    map['file_type'] = fileType;
    map['created_at'] = createdAt;
    map['colors'] = colors;
    map['path'] = path;
    if (thumbs != null) {
      map['thumbs'] = thumbs!.toJson();
    }
    map['tags'] = tags.map((v) => v.toJson()).toList();
    return map;
  }

}