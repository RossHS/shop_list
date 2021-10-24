import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/avatar.dart';
import 'package:shop_list/widgets/custom_text_field.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = AuthenticationController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Center(
        child: Obx(() {
          final userModel = authController.firestoreUser.value;
          return userModel == null ? const CircularProgressIndicator() : _Body(userModel: userModel);
        }),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.userModel,
    Key? key,
  }) : super(key: key);

  final UserModel userModel;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.userModel.name;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.yellow;
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: AnimatedPainterCircleWithBorder90s(
                boxColor: backgroundColor,
                child: Avatar(user: widget.userModel),
              ),
            ),
            SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: CustomTextField(
                  controller: nameController,
                  hint: 'User Name',
                  prefixIcon: const AnimatedIcon90s(iconsList: CustomIcons.user),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('email - ${widget.userModel.email}'),
                Text('uid - ${widget.userModel.uid}'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _updateUserInfo,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Обновление информации пользователя в сервисе firebase
  void _updateUserInfo() {
    var auth = AuthenticationController.instance;
    final updatedUserModel = widget.userModel.copyWith(name: nameController.text);
    auth.updateUserFirestore(widget.userModel, updatedUserModel, auth.firebaseUser.value!);
  }
}
