import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:getwidget/components/toast/gf_toast.dart';

import '../store/index.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: StoreConnector<MainState, HandleActions>(
                // onWillChange: _onReduxChange,
                onInitialBuild: (hAction){
                  hAction.getToken('/login');
                },
                distinct: true,
                converter: (store){
                  var hAction = HandleActions(store);
                  // hAction.getToken();
                  return hAction;
                } ,
                builder: (context, handleActions) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        onChanged: handleActions.userNameChanged,
                        decoration: const InputDecoration(
                            label: Text('帐号'), prefixIcon: Icon(Icons.person)),
                      ),
                      const Padding(padding: EdgeInsets.all(20.0)),
                      TextFormField(
                        onChanged: handleActions.passwordChanged,
                        obscureText: true,
                        decoration: const InputDecoration(
                            label: Text('密码'),
                            prefixIcon: Icon(Icons.password)),
                      ),
                      const Padding(padding: EdgeInsets.all(40.0)),
                      RawMaterialButton(
                        onPressed:()=> handleActions.login(()=>GFToast.showToast(
                          '登录成功！',
                          context,
                        )),
                        child: const Text("登录"),
                      )
                    ],
                  );
                })));
  }
}
