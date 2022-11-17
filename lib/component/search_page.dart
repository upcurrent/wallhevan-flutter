import 'package:flutter/material.dart';
import 'package:wallhevan/pages/picture_list.dart';

class SearchBarPage extends StatefulWidget {
  final String keyword;
  const SearchBarPage({super.key, required this.keyword});
  @override
  State<StatefulWidget> createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  String q = '';
  @override
  void initState() {
    super.initState();
    setState(() {
      q = widget.keyword;
    });
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
        child: PictureList(q: q,sort:"relevance"),
      ),
    );
  }
}
