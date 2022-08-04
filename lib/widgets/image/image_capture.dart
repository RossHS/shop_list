import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

/// Виджет для загрузки фотографии пользователя
/// Данный виджет следует обязательно использовать в поддереве,
/// где проинициализирован контроллер UserPhotoController
class ImageCapture extends StatelessWidget {
  const ImageCapture({
    required this.userInfoUpdateController,
    super.key,
  });
  final UserInfoUpdateController userInfoUpdateController;

  @override
  Widget build(BuildContext context) {
    return ThemeDepFloatingActionButton(
      onPressed: () => userInfoUpdateController.pickImage(ImageSource.gallery),
      child: ThemeDepIcon.file_upload,
    );
  }
}
