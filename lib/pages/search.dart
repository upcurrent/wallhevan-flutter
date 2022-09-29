import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/store/index.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        body:Container(
            child: StoreConnector<MainState,HandleActions>(
              converter: (store) => HandleActions(store),
            builder: (context,hAction){
              return Column(
                children: [
                  Container(
                    child: GestureDetector(
                      onTap: (){

                      },
                      child: Text('topList'),
                    ),
                  )
                ],
              );
            },
        )
        )
    ));
  }
}
