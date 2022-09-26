import 'package:flutter/material.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                ),
                height: 200,
                width: double.infinity,
                child: Text('avatar'),
              ),
              Container(
                height: 100,
                child: Text('username'),
              ),
              Container(
                height: 100,
                child: Text('Favorites'),
              ),
            ],
          ),
        )))
     ;
  }
}
