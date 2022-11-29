import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallhevan/pages/picture_list.dart';
import 'package:wallhevan/store/store.dart';

class SearchBarPage extends StatefulWidget {
  final String keyword;
  const SearchBarPage({super.key, required this.keyword});
  @override
  State<StatefulWidget> createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  final LoadResult load = LoadResult();
  String q = '';
  @override
  void initState() {
    super.initState();
    q = widget.keyword;
    load.q = q.obs;
    load.sort = 'relevance'.obs;
  }

  void init(String value){
    load.q = q.obs;
    load.init();
    getPictureList(load);
  }

  @override
  Widget build(BuildContext context) {
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
            text: q,
          ),
          textInputAction: TextInputAction.search,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          onSubmitted: (value) {
            setState(() {
              q = value;
            });
            init(value);
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: PictureList(load:load),
      ),
    );
  }
}
