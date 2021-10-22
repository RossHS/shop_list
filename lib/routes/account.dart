import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/avatar.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.yellow;
    final authController = AuthenticationController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Obx(() {
            final userModel = authController.firestoreUser.value;
            return userModel == null
                ? const CircularProgressIndicator()
                : Column(
                    children: <Widget>[
                      AnimatedPainterCircleWithBorder90s(
                        boxColor: backgroundColor,
                        child: Avatar(user: userModel),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(userModel.uid),
                        ],
                      )
                    ],
                  );
          }),
        ),
      ),
    );
  }
}
