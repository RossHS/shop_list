import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/avatar.dart';
import 'package:shop_list/widgets/image/image_capture.dart';
import 'package:shop_list/widgets/image/image_selected_indicator.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = AuthenticationController.instance;
    Get.put(UserInfoUpdateController());
    Get.put(FirebaseStorageUploaderController());
    return GetX<ThemeController>(
      builder: (themeController) => Scaffold(
        appBar: ThemeFactory.instance(themeController.appTheme.value).appBar(
          title: const Text('Аккаунт'),
        ),
        body: Center(
          child: Obx(() {
            final userModel = authController.firestoreUser.value;
            return userModel == null ? const CircularProgressIndicator() : _Body(userModel: userModel);
          }),
        ),
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
  final userUpdateController = Get.find<UserInfoUpdateController>();
  final ThemeFactory themeFactory = ThemeFactory.instance(ThemeController.to.appTheme.value);

  @override
  void initState() {
    super.initState();
    userUpdateController.nameController.text = widget.userModel.name;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        // Виджет аватара
                        child: themeFactory.buildWidget(
                          animated90s: (child, factory) => AnimatedPainterCircleWithBorder90s(
                            config: factory.themeWrapper.paint90sConfig,
                            boxColor: backgroundColor,
                            child: child!,
                          ),
                          material: (child, _) => Material(
                            elevation: 10,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(300),
                            // shape: ,
                            child: ClipOval(
                              child: Container(
                                child: child,
                              ),
                            ),
                          ),
                          child: Avatar(
                            diameter: 280,
                            user: widget.userModel,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                            alignment: Alignment.topRight,
                            child: ImageSelectedIndicator(userInfoUpdateController: userUpdateController)),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: ImageCapture(userInfoUpdateController: userUpdateController),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: themeFactory.textField(
                      maxLines: 1,
                      controller: userUpdateController.nameController,
                      hint: 'User Name',
                      prefixIcon: themeFactory.icons.user,
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: themeFactory.button(
                      onPressed: _updateUserInfo,
                      child: const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Обновление информации пользователя в сервисе firebase
  void _updateUserInfo() async {
    final auth = AuthenticationController.instance;
    auth.updateUserInfo(Get.find<UserInfoUpdateController>(), Get.find<FirebaseStorageUploaderController>());
  }
}
