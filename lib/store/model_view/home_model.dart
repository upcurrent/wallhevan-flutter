import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:wallhevan/store/index.dart';

class HomeModel {
  final ScrollController homeScrollCtrl;
  final Map params;
  final Function setParams;
  HomeModel(
    this.params,
    this.homeScrollCtrl,
    this.setParams,
  );

  static HomeModel fromStore(Store<MainState> store) {

    MainState state = store.state;
    SearchParams search = state.search;

    void setParams(Map<String, String> args, {bool init = false}) {
      search.params.addAll(args);
      store.dispatch({'type': StoreActions.initHomePage});
      // if (init) {
      //   store.dispatch({'type': StoreActions.init});
      // }
    }

    return HomeModel(search.params, state.homeScrollCtrl, setParams);
  }
}
