import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';
import 'package:wallhevan/store/search_response/search_result.dart';
import '../../generated/l10n.dart';

import '../api/api.dart';

class StoreController {

  var cachePic = <String>{}.obs;
  final ScrollController homeScrollCtrl =
      ScrollController(keepScrollOffset: false);

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

class SearchQuery extends GetxController{
  final List<Map> topRangeBtn = [
    {'value':'1d','name':S.current.t_1d},
    {'value':'3d','name':S.current.t_3d},
    {'value':'1w','name':S.current.t_1w},
    {'value':'1M','name':S.current.t_1M},
    {'value':'3M','name':S.current.t_3M},
    {'value':'6M','name':S.current.t_6M},
    {'value':'1y','name':S.current.t_1y},
  ];
  final List<Map> sortingBtn = [
    {'value':'toplist','name':S.current.topList},
    {'value':'hot','name':S.current.hot},
    {'value':'random','name':S.current.random},
    {'value':'date_added','name':S.current.latest},
    {'value':'views','name':S.current.views},
    {'value':'favorites','name':S.current.favorites},
    {'value':'relevance','name':S.current.relevance},
  ];
  final List<Map> cateBtn = [
    {'value':'general','name':S.current.general},
    {'value':'anime','name':S.current.anime},
    {'value':'people','name':S.current.people},
  ];
  final Map<String, String> params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
  };
  final List<Map> ptyMap = [
    {'name':'SFW','type':'1'},
    {'name':'Sketchy','type':'2'},
    {'name':'NSFW','type':'3'},
  ];
  final Map<String, String> categoriesMap = {
    'general': '1',
    'anime': '0',
    'people': '0',
  };

  final Map<String, String> purityMap = {
    'SFW': '1',
    'Sketchy': '0',
    'NSFW': '0',
  };

  void setCategories(String key) {
    categoriesMap[key] = categoriesMap[key] == '0' ? '1' : '0';
    List<String> cateStr = [];
    cateStr.addAll(categoriesMap.values);
    params.addAll({'categories': cateStr.join('')});
    update();
  }

  void setPurity(String key) {
    purityMap[key] = purityMap[key] == '0' ? '1' : '0';
    List<String> purityStr = [];
    purityStr.addAll(purityMap.values);
    params.addAll({'purity': purityStr.join('')});
    update();
  }
  void setParams(Map<String,String> data){
    params.addAll(data);
    update();
  }
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
