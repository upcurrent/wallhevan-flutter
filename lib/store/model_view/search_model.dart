import 'package:redux/redux.dart';

import '../../generated/l10n.dart';
import '../index.dart';

class SearchModel{

  final Map params;
  final SearchParams search;
  final Function setParams;
  final Function setCategories;
  final Function setPurity;
  final Function init;
  final List<Map> topRangeMap = [
    {'value':'1d','name':S.current.t_1d},
    {'value':'3d','name':S.current.t_3d},
    {'value':'1w','name':S.current.t_1w},
    {'value':'1M','name':S.current.t_1M},
    {'value':'3M','name':S.current.t_3M},
    {'value':'6M','name':S.current.t_6M},
    {'value':'1y','name':S.current.t_1y},
  ];
  final List<Map> sorting = [
    {'value':'toplist','name':S.current.topList},
    {'value':'hot','name':S.current.hot},
    {'value':'random','name':S.current.random},
    {'value':'date_added','name':S.current.latest},
    {'value':'views','name':S.current.views},
    {'value':'favorites','name':S.current.favorites},
    {'value':'relevance','name':S.current.relevance},
  ];
  final List<Map> cateMap = [
    {'value':'general','name':S.current.general},
    {'value':'anime','name':S.current.anime},
    {'value':'people','name':S.current.people},
  ];
  final List<Map> purityMap = [
    {'name':'SFW','type':'1'},
    {'name':'Sketchy','type':'2'},
    {'name':'NSFW','type':'3'},
  ];
  SearchModel(
      this.params,
      this.search,
      this.setParams,
      this.setCategories,
      this.setPurity,
      this.init,
      );

  static SearchModel fromStore(Store<MainState> store) {
    MainState state = store.state;
    SearchParams search = state.search;

    void setParams(Map<String, String> args, {bool init = false}) {
      search.params.addAll(args);
      store.dispatch({'type': StoreActions.searchChange});
      if (init) {
        store.dispatch({'type': StoreActions.init});
      }
    }
    void setCategories(String key) {
      search.categoriesMap[key] = search.categoriesMap[key] == '0' ? '1' : '0';
      List<String> str = [];
      str.addAll(search.categoriesMap.values);
      setParams({'categories': str.join('')});
    }

    void setPurity(String key) {
      search.purityMap[key] = search.purityMap[key] == '0' ? '1' : '0';
      List<String> purityStrs = [];
      purityStrs.addAll(search.purityMap.values);
      setParams({'purity': purityStrs.join('')});
    }
    void init(){
      store.dispatch({'type': StoreActions.init});
    }
    return SearchModel(search.params,search, setParams,setCategories,setPurity,init);
  }
}