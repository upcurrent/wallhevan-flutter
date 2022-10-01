import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/store/index.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child:
              StoreConnector<MainState,HandleActions>(
                converter: (store) => HandleActions(store),
                builder: (context,hAction){
                  UserAccount account = hAction.store.state.account;
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                        ),
                        height: 200,
                        width: double.infinity,
                        child: const Text('avatar'),
                      ),
                      Container(
                        height: 100,
                          child:GestureDetector(
                            onTap: (){
                              // hAction.test();
                            },
                            child: Text(account.username),
                          )
                      ),
                      Container(
                          height: 100,
                          child:GestureDetector(
                            onTap: (){
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('提示'),
                                    content:  SingleChildScrollView(
                                      child:  ListBody(
                                        children: const <Widget>[
                                          Text('是否退出登录?'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      RawMaterialButton(
                                        onPressed:()=>{Navigator.of(context).pop()},
                                        child: const Text("取消"),
                                      ),
                                      RawMaterialButton(
                                        onPressed:(){Navigator.of(context).pop(); hAction.logOut();},
                                        child: const Text("确定"),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('退出登录'),
                          )
                      ),
                    ],
                  );
                },
              )

        )))
     ;
  }
}
