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
  PictureListModel(
      this.pictures, this.viewType,this.currentIndex, this.loadMore, this.preview,this.updatePic);
  static PictureListModel listFromStore(
      Store<MainState> store, StoreActions viewType) {
    MainState state = store.state;
    List<PictureInfo> list = viewType == StoreActions.viewList
        ? state.imageDataList
        : state.favPictureList;
    return PictureListModel(list, viewType,store.state.currentIndex, () {
      store.dispatch({'type': StoreActions.loadMore, 'viewType': viewType}); // loadMore
    }, (int index) { // preview
      store.dispatch({
        'type': StoreActions.preview,
        'viewType': viewType,
        'currentIndex': index,
        'url': list[index].path
      });
    },(int index) { // updatePic
      store.dispatch({
        'type': StoreActions.updatePic,
        'url': list[index].path
      });
    }
    );
  }

  @override
  bool operator == (Object other) {
      print(other);
    if (other is PictureListModel) {
      print(pictures.length);
      print(other.pictures.length);
      return pictures.length == other.pictures.length;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => pictures.length.hashCode;
}
