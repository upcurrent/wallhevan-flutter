import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallhevan/pages/picture_list.dart';
import 'package:wallhevan/store/store.dart';

class SearchBarPage extends StatelessWidget {
  final String keyword;
  final String tag;

  const SearchBarPage({super.key, required this.keyword, required this.tag});

  @override
  Widget build(BuildContext context) {
    final LoadResult load = Get.find(tag: tag);
    void init(String value) {
      load.q = value;
      load.init(renderer: true);
      getPictureList(load);
    }
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
        title:
           GetBuilder<LoadResult>(
            init:load,
            builder: (_) {
              return TextField(
                controller: TextEditingController(
                  text: load.q,
                ),
                textInputAction: TextInputAction.search,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  init(value);
                },
                decoration: const InputDecoration(
                    hintText: 'Search....',
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
              );
            },
          ),

      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: PictureList(tag: tag),
      ),
    );
  }
}
