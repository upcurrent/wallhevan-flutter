import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:wallhevan/store/index.dart';

class MainModel {
  final ScrollController homeScrollCtrl;
  final Function scrollTop;
  MainModel(
    this.homeScrollCtrl,
    this.scrollTop,
  );

  static MainModel fromStore(Store<MainState> store) {
    MainState state = store.state;

    void scrollTop() {
      store.dispatch({'type': StoreActions.homeScrollTop});
    }

    return MainModel(state.homeScrollCtrl, scrollTop);
  }
}
