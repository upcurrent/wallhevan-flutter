import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/pages/picture_list.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/store/model_view/search_model.dart';

class SearchBarPage extends StatefulWidget {
  final String keyword;
  const SearchBarPage({super.key, required this.keyword});
  @override
  State<StatefulWidget> createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<MainState, SearchModel>(
        builder: (context, search) {
          // search.setParams({'q':query});
          return Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      });
                },
              ),
              title: TextField(
                controller: TextEditingController(
                  text: widget.keyword,
                ),
                textInputAction: TextInputAction.search,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  search.setParams(
                      value != ''
                          ? {'q': value, 'sorting': "relevance"}
                          : {'q': value},
                      init: true);
                },
                decoration: const InputDecoration(
                    hintText: 'Search....',
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
              ),
              // actions: widget.delegate.buildActions(context),
              // bottom: widget.delegate.buildBottom(context),
            ),
            body: const AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: PictureList(viewType: ListType.viewSearch,back: true,),
            ),
          );

          // const PictureList(viewType: ListType.viewSearch)
        },
        converter: (store) => SearchModel.fromStore(store));
  }
}
