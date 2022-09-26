import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/store/index.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container(
          child: StoreConnector<MainState,MainState>(
            converter: (store) => store.state,
            builder: (context,state){
              return const Text('FavoritesPage');
            },
          )
        )
    );
  }
}
