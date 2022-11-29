
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';
import 'package:wallhevan/store/search_response/search_result.dart';

import '../api/api.dart';
class StoreController extends GetxController{
  var pageNum = 0.obs;
  var load = LoadResult().obs;
  var pages = <String,LoadResult>{}.obs;
  var cachePic = <String>{}.obs;
  final ScrollController homeScrollCtrl = ScrollController(keepScrollOffset: false);

  LoadResult getPictures(String key){
    var pageMap = pages();
    // pageMap.
    if(pageMap.containsKey(key)){
      return pages()[key]!;
    }else{
      var load = LoadResult();
      pageMap.addAll({DateTime.now().toString():load});
      return load;
    }
  }
  void updatePic(String path){
    if(cachePic.contains(path))return;
    cachePic().add(path);
    update();
  }
  void homeScrollTop() {
    homeScrollCtrl.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }
}

class LoadResult extends GetxController{
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
  }.obs;

  var pageNum = 1.obs;
  var total = 0.obs;
  var q = ''.obs;
  var sort = 'toplist'.obs;
  var loading = false.obs;
  var pictures = <PictureInfo>[].obs;

  void init({renderer=false}){
    pageNum = 1.obs;
    total = 0.obs;
    pictures.clear();
    if(renderer){
      update();
    }
  }


  void setParams(Map<String, String> args, {bool search = false}) {
    params.addAll(args);
    if (search) {
      init();
    }
  }
  void setPictures(List<PictureInfo>? data,int total){
    if(data != null){
      pictures.addAll(data);
      pageNum++;
      update();
    }
    this.total = total.obs;
    print(pictures.length);
  }

}

Future<void> getPictureList(LoadResult load) async {
  if (load.loading.value) return;
  if (load.pageNum.value != 1 && load.pictures.length >= load.total.value) return;
  Map<String, String> params = <String,String>{}..addAll(load.params);
  params['q'] = load.q.value;
  params['page'] = "${load.pageNum.value}";
  params['apikey'] ??= await StorageManger.getApiKey();
  params['sorting'] = (load.sort.value.isEmpty ? params['sorting'] : load.sort.value)!;
  if (params['sorting'] != 'random') {
    params['seed'] = '';
  }
  load.loading = true.obs;
  dio
      .get(
    '/api/v1/search',
    queryParameters: params,
  )
      .then((response) {
    load.loading = false.obs;
    SearchResult searchResult = SearchResult.fromJson(response.data);
    final meta = searchResult.meta;
    int total = 0;
    if (meta != null) {
      total = meta.total;
      if (params['sorting'] == 'random' && params['seed']?.isEmpty == true) {
        params['seed'] = meta.seed;
        load.setParams({'seed':meta.seed});
      }
    }
    load.setPictures(searchResult.data,total);
    // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}