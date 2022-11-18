import 'package:redux/redux.dart';

import '../api/api.dart';
import '../pages/picture_list.dart';
import '../store/index.dart';
import '../store/search_response/search_result.dart';

class PictureViewModel {
  final Map<String, String> params;

  Function dispatch;
  PictureReq? req;
  PictureViewModel( this.params, this.dispatch,this.req,this.homeKey);
  int homeKey;
  static PictureViewModel fromStore(Store<MainState> store) {
    void dispatch(Map<String, dynamic> arg) {
      store.dispatch(arg);
    }
    return PictureViewModel(store.state.search.params, dispatch,null,store.state.homeKey);
  }

  void preview(String path) {
    dispatch({'type': StoreActions.preview, 'url': path});
  }

  void updatePic(String path) {
    dispatch({'type': StoreActions.updatePic, 'url': path});
  }

  Future<void> getPictureList(PictureReq req,Function callback) async {
    if (req.loading) return;
    Map<String, String> params = <String,String>{}..addAll(this.params);
    params['q'] = req.q;
    params['page'] = req.pageNum.toString();
    params['apikey'] ??= await StorageManger.getApiKey();
    params['sorting'] = (req.sort.isEmpty ? params['sorting'] : req.sort)!;
    if (params['sorting'] != 'random') {
      params['seed'] = '';
    }
    req.loading = true;
    dio
        .get(
      '/api/v1/search',
      queryParameters: params,
    )
        .then((response) {
      req.loading = false;
      SearchResult searchResult = SearchResult.fromJson(response.data);
      final meta = searchResult.meta;
      int total = 0;
      if (meta != null) {
        total = meta.total;
        if (params['sorting'] == 'random' && params['seed']?.isEmpty == true) {
          params['seed'] = meta.seed;
        }
      }
      callback(searchResult.data,total);
      // ignore: invalid_return_type_for_catch_error, avoid_print
    }).catchError((error) => {print(error.toString())});
  }

  @override
  bool operator ==(Object other) {
    if (other is PictureViewModel) {
      return homeKey == other.homeKey;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => homeKey.hashCode;
}
