import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Виджет для загрузки фотографии пользователя
/// Данный виджет следует обязательно использовать в поддереве,
/// где проинициализирован контроллер UserPhotoController
class ImageCapture extends StatelessWidget {
  const ImageCapture({
    required this.userInfoUpdateController,
    Key? key,
  }) : super(key: key);
  final UserInfoUpdateController userInfoUpdateController;

  @override
  Widget build(BuildContext context) {
    final themeFactory = ThemeFactory.instance(ThemeController.to.appTheme.value);
    return themeFactory.floatingActionButton(
      onPressed: () => userInfoUpdateController.pickImage(ImageSource.gallery),
      child: themeFactory.icons.file_upload,
    );
  }
}
