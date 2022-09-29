import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/store/index.dart';

import '../generated/l10n.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                child: StoreConnector<MainState, HandleActions>(
      converter: (store) => HandleActions(store),
      builder: (context, hAction) {
        void setSorting(String value){
          hAction.setParams('sorting',value);
        }
        void setCategories(String value){
          hAction.setParams('sorting',value);
        }
        return Column(
          children: [
            Wrap(
              children: [
                LabelText(callback: setSorting, value: 'toplist', text: S.current.topList),
                LabelText(callback: setSorting, value: 'hot', text: S.current.hot),
                LabelText(callback: setSorting, value: 'random', text: S.current.random),
                LabelText(callback: setSorting, value: 'date_added', text: S.current.latest),
                LabelText(callback: setSorting, value: 'views', text: S.current.views),
                LabelText(callback: setSorting, value: 'favorites', text: S.current.favorites),
                LabelText(callback: setSorting, value: 'relevance', text: S.current.relevance),
              ],
            ),
            Wrap(
              children: [
                LabelText(callback: setCategories, value: 'toplist', text: S.current.topList),
                LabelText(callback: setCategories, value: 'hot', text: S.current.hot),
                LabelText(callback: setCategories, value: 'random', text: S.current.random),
                LabelText(callback: setCategories, value: 'date_added', text: S.current.latest),
                LabelText(callback: setCategories, value: 'views', text: S.current.views),
                LabelText(callback: setCategories, value: 'favorites', text: S.current.favorites),
                LabelText(callback: setCategories, value: 'relevance', text: S.current.relevance),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: RawMaterialButton(
                    onPressed: () {
                      hAction.store.dispatch({'type':StoreActions.init});
                    },
                    child: const Text('search'),
                  )),
            )
          ],
        );
      },
    ))));
  }
}

class LabelText extends StatelessWidget {
  const LabelText({super.key,required this.value, required this.text, required this.callback});
  final String value;
  final String text;
  final Function callback;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
          padding: const EdgeInsets.all(0.5),
          child: RawMaterialButton(
            onPressed: () {
              callback(value);
            },
            child: Text(text),
          )),
    );
  }
}
