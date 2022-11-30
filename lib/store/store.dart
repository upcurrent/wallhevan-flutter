import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';
import 'package:wallhevan/store/search_response/search_result.dart';

import '../api/api.dart';

class StoreController {
  var pageNum = 0.obs;
  var load = LoadResult().obs;
  var pages = <String, LoadResult>{}.obs;
  var cachePic = <String>{}.obs;
  final ScrollController homeScrollCtrl =
      ScrollController(keepScrollOffset: false);

  LoadResult getPictures(String key) {
    var pageMap = pages();
    // pageMap.
    if (pageMap.containsKey(key)) {
      return pages()[key]!;
    } else {
      var load = LoadResult();
      pageMap.addAll({DateTime.now().toString(): load});
      return load;
    }
  }

  void updatePic(String path) {
    if (cachePic.contains(path)) return;
    cachePic().add(path);
  }

  void homeScrollTop() {
    homeScrollCtrl.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }
}

String getTag({String q = "", String sort = "toplist"}) {
  String tag = "${DateTime.now().millisecondsSinceEpoch}";
  LoadResult load = LoadResult();
  load.q = q;
  load.sort = sort;
  Get.put(load, tag: tag);
  return tag;
}

class LoadResult extends GetxController {
  // todo
  final Map<String, String> params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
    'page': '1',
    'q': '',
    'seed': '',
  };

  int pageNum = 1;
  int total = 0;
  String q = '';
  String sort = 'toplist';
  bool loading = false;
  var pictures = <PictureInfo>[];

  void init({renderer = false}) {
    pageNum = 1;
    total = 0;
    pictures.clear();
    if (renderer) {
      update();
    }
  }

  void renderer() {
    update();
  }

  void setParams(Map<String, String> args, {bool search = false}) {
    params.addAll(args);
    if (search) {
      init();
    }
  }

  void setPictures(List<PictureInfo>? data, int total) {
    if (data != null) {
      pictures.addAll(data);
      pageNum++;
    }
    this.total = total;
    update();
  }
}

Future<void> getPictureList(LoadResult load) async {
  if (load.loading) return;
  if (load.pageNum != 1 && load.pictures.length >= load.total) return;
  Map<String, String> params = <String, String>{}..addAll(load.params);
  params['q'] = load.q;
  params['page'] = "${load.pageNum}";
  params['apikey'] ??= await StorageManger.getApiKey();
  params['sorting'] = (load.sort.isEmpty ? params['sorting'] : load.sort)!;
  if (params['sorting'] != 'random') {
    params['seed'] = '';
  }
  // print(params);
  load.loading = true;
  dio
      .get(
    '/api/v1/search',
    queryParameters: params,
  )
      .then((response) {
    load.loading = false;
    SearchResult searchResult = SearchResult.fromJson(response.data);
    final meta = searchResult.meta;
    int total = 0;
    if (meta != null) {
      total = meta.total;
      if (params['sorting'] == 'random' && params['seed']?.isEmpty == true) {
        params['seed'] = meta.seed;
        load.setParams({'seed': meta.seed});
      }
    }
    load.setPictures(searchResult.data, total);
    // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}
