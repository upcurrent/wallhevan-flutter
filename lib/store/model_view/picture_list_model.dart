import 'package:redux/redux.dart';

import '../index.dart';
import '../search_response/picture_info.dart';

class PictureListModel {
  final List<PictureInfo> pictures;
  final Function loadMore;
  final Function preview;
  final Function updatePic;
  final Function setParams;
  final int currentIndex;
  final int pictureCount;
  PictureListModel(this.pictures, this.pictureCount,
      this.currentIndex, this.loadMore, this.preview, this.updatePic,this.setParams);
  static PictureListModel formStore(Store<MainState> store) {
    MainState state = store.state;
    var query = PictureQuery.getQuery(state);
    List<PictureInfo> list = [];
    list.addAll(query.list);
    void loadMore() {
      var loading = query.loading;
      if (loading) {
        return;
      }
      store.dispatch(
          {'type': StoreActions.loadMore}); // loadMore
    }
    Future<void> setParams(String q,{bool init = false}) async {
      // state.search.params.addAll(args);
      query.q = q;
      if(init){
        query.total = 0;
        query.pageNum = 1;
        query.list.clear();
      }
      await store.dispatch({'type': StoreActions.searchChange});
      if (init) {
        store.dispatch({'type': StoreActions.init});
      }
    }
    void preview(int index) {
      store.dispatch({
        'type': StoreActions.preview,
        'currentIndex': index,
        'url': list[index].path
      });
    }

    void updatePic(int index) {
      store.dispatch({'type': StoreActions.updatePic, 'url': list[index].path});
    }

    return PictureListModel(list, list.length, state.currentIndex,
        loadMore, preview, updatePic,setParams);
  }

  @override
  bool operator ==(Object other) {
    if (other is PictureListModel) {
      if (pictureCount == other.pictureCount) {
        if (pictureCount != 0 &&
            pictures[0].hashCode != other.pictures[0].hashCode) {
          return false;
        }
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  int get hashCode => pictureCount.hashCode;
}
