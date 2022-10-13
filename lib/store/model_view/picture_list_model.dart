import 'package:redux/redux.dart';

import '../index.dart';
import '../search_response/picture_info.dart';

class PictureListModel {
  final List<PictureInfo> pictures;
  final Function loadMore;
  final Function preview;
  final Function updatePic;
  final StoreActions viewType;
  final int currentIndex;
  final int pictureCount;
  PictureListModel(this.pictures, this.pictureCount, this.viewType,
      this.currentIndex, this.loadMore, this.preview, this.updatePic);
  static PictureListModel formStore(
      Store<MainState> store, StoreActions viewType) {
    MainState state = store.state;

    List<PictureInfo> list = [];
    list.addAll(viewType == StoreActions.viewList
        ? state.imageDataList
        : state.favPictureList);

    void loadMore() {
      var loading = state.loading;
      if(viewType == StoreActions.viewFav){
        loading = state.favLoading;
      }
      if(loading){
        return;
      }
      store.dispatch(
          {'type': StoreActions.loadMore, 'viewType': viewType}); // loadMore
    }

    void preview(int index) {
      store.dispatch({
        'type': StoreActions.preview,
        'viewType': viewType,
        'currentIndex': index,
        'url': list[index].path
      });
    }

    void updatePic(int index) {
      store.dispatch({'type': StoreActions.updatePic, 'url': list[index].path});
    }

    return PictureListModel(list, list.length, viewType, state.currentIndex,
        loadMore, preview, updatePic);
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
