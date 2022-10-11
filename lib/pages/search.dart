import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:wallhevan/store/index.dart';

import '../generated/l10n.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:const BoxConstraints.expand(),
        child:StoreConnector<MainState, HandleActions>(
      converter: (store) => HandleActions(store),
      builder: (context, hAction) {
        void setSorting(String value) {
          hAction.setParams({'sorting': value});
        }

        bool sortingSelected(String value) {
          return hAction.store.state.search.params['sorting'] == value;
        }

        bool cateSelected(String key) {
          return hAction.store.state.search.categoriesMap[key] == '1';
        }

        bool puritySelected(String key) {
          return hAction.store.state.search.purityMap[key] == '1';
        }

        void setTopRang(String value) {
          hAction.setParams({'topRange': value});
        }

        bool topRangSel(String value) {
          return hAction.store.state.search.params['topRange'] == value;
        }

        bool disableTopRange() {
          return hAction.store.state.search.params['sorting'] != 'toplist';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           SizedBox(
              height: 80,
              child:
              TextField(
                controller: TextEditingController(
                  text: '',
                ),
                textInputAction: TextInputAction.search,
                cursorColor: Colors.white,
                style:const TextStyle(
                    color: Colors.white
                ),
                onSubmitted: (value){
                  hAction.setParams({'q':value},search:true);
                  // setKeyword(value);
                },
                decoration:const InputDecoration(
                  // pri: Text('Search...'),
                    hintText: 'Search....',
                    suffixIcon: Icon(Icons.search,color: Colors.white,)),
              ),
              // TextField(
              //   // onChanged: handleActions.userNameChanged,
              //   decoration: InputDecoration(
              //     // pri: Text('Search...'),
              //       helperText: 'Search....',
              //       suffix: Icon(Icons.search)),
              // ),
            ),
            Wrap(
              spacing: 2,
              children: [
            HGFButton(
                value: "toplist",
                text: S.current.topList,
                selected: sortingSelected('toplist'),
                onSelected: setSorting),
            HGFButton(
                value: "hot",
                text: S.current.hot,
                selected: sortingSelected('hot'),
                onSelected: setSorting),
            HGFButton(
                value: "random",
                text: S.current.random,
                selected: sortingSelected('random'),
                onSelected: setSorting),
            HGFButton(
                value: "date_added",
                text: S.current.latest,
                selected: sortingSelected('date_added'),
                onSelected: setSorting),
            HGFButton(
                value: "views",
                text: S.current.views,
                selected: sortingSelected('views'),
                onSelected: setSorting),
            HGFButton(
                value: "favorites",
                text: S.current.favorites,
                selected: sortingSelected('favorites'),
                onSelected: setSorting),
            HGFButton(
                value: "relevance",
                text: S.current.relevance,
                selected: sortingSelected('relevance'),
                onSelected: setSorting),
              ],
            ),
            Wrap(
              spacing: 2,
              children: [
            HGFButton(
                text: S.current.general,
                value: "general",
                selected: cateSelected('general'),
                onSelected: hAction.setCategories),
            HGFButton(
                text: S.current.anime,
                value: "anime",
                selected: cateSelected('anime'),
                onSelected: hAction.setCategories),
            HGFButton(
                text: S.current.people,
                value: "people",
                selected: cateSelected('people'),
                onSelected: hAction.setCategories),
              ],
            ),
            Wrap(
              spacing: 2,
              children: [
            HGFButton(
                text: S.current.t_1d,
                value: "1d",
                disabled: disableTopRange(),
                selected: topRangSel('1d'),
                onSelected: setTopRang),
            HGFButton(
                text: S.current.t_3d,
                value: "3d",
                disabled: disableTopRange(),
                selected: topRangSel('3d'),
                onSelected: setTopRang),
            HGFButton(
                text: S.current.t_1w,
                value: "1w",
                disabled: disableTopRange(),
                selected: topRangSel('1w'),
                onSelected: setTopRang),
            HGFButton(
                text: S.current.t_1M,
                value: "1M",
                disabled: disableTopRange(),
                selected: topRangSel('1M'),
                onSelected: setTopRang),
            HGFButton(
                text: S.current.t_3M,
                value: "3M",
                disabled: disableTopRange(),
                selected: topRangSel('3M'),
                onSelected: setTopRang),
            HGFButton(
                text: S.current.t_6M,
                value: "6M",
                disabled: disableTopRange(),
                selected: topRangSel('6M'),
                onSelected: setTopRang),
            HGFButton(
                text: S.current.t_1y,
                value: "1y",
                disabled: disableTopRange(),
                selected: topRangSel('1y'),
                onSelected: setTopRang),
              ],
            ),
            Wrap(
              spacing: 2,
              children: [
            HGFButton(
                type: '1',
                text: "SFW",
                selected: puritySelected('SFW'),
                onSelected: hAction.setPurity),
            HGFButton(
                type: '2',
                text: "Sketchy",
                selected: puritySelected('Sketchy'),
                onSelected: hAction.setPurity),
            HGFButton(
                type: '3',
                text: "NSFW",
                selected: puritySelected('NSFW'),
                onSelected: hAction.setPurity),
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
                  hAction.store.dispatch({'type': StoreActions.init});
                },
                child: const Text('search'),
              )),
            ),
          ],
        );
      },
    ));
  }
}

class HGFButton extends StatelessWidget {
  const HGFButton(
      {super.key,
      required this.text,
      required this.onSelected,
      required this.selected,
      this.type = '0',
      this.value = '',
      this.disabled = false});
  final String text;
  final String value;
  final bool selected;
  final Function onSelected;
  final String type;
  final bool disabled;
  List<Color> getColor() {
    switch (type) {
      case '1':
        return [const Color(0xff99ff99), const Color(0xff447744)];
      case '2':
        return [const Color(0xffffff99), const Color(0xff777744)];
      case '3':
        return [const Color(0xffff9999), const Color(0xff774444)];
      default:
        return [const Color(0xffffffff), const Color(0xff5e5e5e)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return selected
        ? GFButton(
            onPressed: disabled
                ? null
                : () {
                    onSelected(value.isEmpty ? text : value);
                  },
            textColor: getColor()[0],
            disabledColor: const Color(0x1e1e1e80),
            color: getColor()[1],
            text: text,
            shape: GFButtonShape.standard,
          )
        : GFButton(
            onPressed: disabled
                ? null
                : () {
                    onSelected(value.isEmpty ? text : value);
                  },
            textColor: const Color(0xffaaaaaa),
            color: const Color(0xff353535),
            disabledColor: const Color(0x1e1e1e80),
            text: text,
            shape: GFButtonShape.standard,
          );
  }
}
