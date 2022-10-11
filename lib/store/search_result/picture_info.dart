import 'thumbs.dart';

class PictureInfo {
  PictureInfo({
    required this.id,
    required this.url,
    required this.shortUrl,
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
  });

  factory PictureInfo.fromJson(dynamic json) {
    return PictureInfo(
        id: json['id'],
        url: json['url'],
        shortUrl: json['short_url'],
        views: json['views'],
        favorites: json['favorites'],
        source: json['source'],
        purity: json['purity'],
        category: json['category'],
        dimensionX: json['dimension_x'],
        dimensionY: json['dimension_y'],
        resolution: json['resolution'],
        ratio: json['ratio'],
        fileSize: json['file_size'],
        fileType: json['file_type'],
        createdAt: json['created_at'],
        colors: json['colors'] != null ? json['colors'].cast<String>() : [],
        path: json['path'],
        thumbs:
        json['thumbs'] != null ? Thumbs.fromJson(json['thumbs']) : Thumbs(large: '', original: '', small: ''));
  }
  final String id;
  final String url;
  final String shortUrl;
  final int views;
  final int favorites;
  final String source;
  final String purity;
  final String category;
  final int dimensionX;
  final int dimensionY;
  final String resolution;
  final String ratio;
  final int fileSize;
  final String fileType;
  final String createdAt;
  final List<String> colors;
  final String path;
  final Thumbs thumbs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['url'] = url;
    map['short_url'] = shortUrl;
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
    map['thumbs'] = thumbs.toJson();
    return map;
  }
}
