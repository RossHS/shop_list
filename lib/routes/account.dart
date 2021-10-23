import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  /// Слушатель наличия изменений в имени пользователя,
  /// если есть изменения, появляется кнопка Сохранить
  var isChanged = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    nameController.text = widget.userModel.name;
    nameController.addListener(() {
      if (nameController.text != widget.userModel.name) {
        isChanged.value = true;
      } else {
        isChanged.value = false;
      }
    });
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
            ValueListenableBuilder<bool>(
              valueListenable: isChanged,
              builder: (_, value, __) {
                return value
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Save'),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
