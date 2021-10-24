import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';

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
    return AnimatedCircleButton90s(
      onPressed: () => userInfoUpdateController.pickImage(ImageSource.gallery),
      child: const Icon(Icons.file_upload),
    );
  }
}
