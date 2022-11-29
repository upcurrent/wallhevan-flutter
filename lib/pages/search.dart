import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:wallhevan/store/index.dart';

import '../store/model_view/search_model.dart';


class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:const BoxConstraints.expand(),
        child:StoreConnector<MainState, SearchModel>(
      converter: (store) => SearchModel.fromStore(store),
      builder: (context, searchModel) {
        void setSorting(String value) {
          searchModel.setParams({'sorting': value});
        }

        bool sortingSelected(String value) {
          return searchModel.search.params['sorting'] == value;
        }

        bool cateSelected(String key) {
          return searchModel.search.categoriesMap[key] == '1';
        }

        bool puritySelected(String key) {
          return searchModel.search.purityMap[key] == '1';
        }

        void setTopRang(String value) {
          searchModel.setParams({'topRange': value});
        }

        bool topRangSel(String value) {
          return searchModel.search.params['topRange'] == value;
        }

        bool disableTopRange() {
          return searchModel.search.params['sorting'] != 'toplist';
        }

        List<HGFButton> list = [];
        list.addAll(
            searchModel.sorting.map((v )=> HGFButton(
                value: v['value']!,
                text: v['name']!,
                selected: sortingSelected(v['value']!),
                onSelected: setSorting))
        );

        List<HGFButton> categories = [];
        categories.addAll(
            searchModel.cateMap.map((v )=> HGFButton(
                value: v['value']!,
                text: v['name']!,
                selected: cateSelected(v['value']!),
                onSelected: searchModel.setCategories))
        );

        List<HGFButton> topRange = [];
        topRange.addAll(
            searchModel.topRangeMap.map((v )=> HGFButton(
                value: v['value']!,
                text: v['name']!,
                disabled: disableTopRange(),
                selected: topRangSel(v['value']!),
                onSelected: setTopRang))
        );
        List<HGFButton> purity = [];
        purity.addAll(
            searchModel.purityMap.map((v )=> HGFButton(
                type: v['type']!,
                text: v['name']!,
                selected: puritySelected(v['name']!),
                onSelected: searchModel.setPurity))
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 2,
              children: list,
            ),
            Wrap(
              spacing: 2,
              children: categories,
            ),
            Wrap(
              spacing: 2,
              children: topRange,
            ),
            Wrap(
              spacing: 2,
              children: purity,
            ),
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
                  searchModel.setParams({'q':value},init:true);
                  // setKeyword(value);
                  Scaffold.of(context).closeDrawer();
                },
                decoration:const InputDecoration(
                    hintText: 'Search....',
                    suffixIcon: Icon(Icons.search,color: Colors.white,)),
              ),
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
                  searchModel.init();
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
