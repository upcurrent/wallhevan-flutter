import 'package:redux/redux.dart';
import 'package:wallhevan/store/index.dart';

import '../collections/fav_data.dart';

class FavoritesModel {
  final int favId;
  final List<FavData> favList;
  final Function init;
  FavoritesModel(
      this.favId,
      this.favList,
      this.init,
      );

  static FavoritesModel fromStore(Store<MainState> store) {
    MainState state = store.state;

    void init(int value) {
      store.dispatch({
        'type': StoreActions.init,
        'viewType': StoreActions.viewFav,
        'id': value
      });
    }

    return FavoritesModel(state.favId,state.favList,init);
  }
}
