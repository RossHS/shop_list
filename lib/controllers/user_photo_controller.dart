import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

/// Новые данные информации пользователя. Логика загрузки и обработки фотографии
class UserInfoUpdateController extends GetxController {
  /// Объект выбранной фотографии
  final userPhotoBytes = Rxn<Uint8List>();

  /// Контроллер поля ввода нового имени пользователя
  TextEditingController nameController = TextEditingController();

  /// Состояние процесса выбора фотографии
  final photoSelectedState = Rx<PhotoSelectionState>(PhotoSelectionState.nonSelected);

  /// Метод загрузки файла из источника [source] (галерея). После чего преобразование
  /// загруженного файла в бинарный вид, а для не веб платформы добавляется шаг с обрезанием фотографии
  Future<void> pickImage(ImageSource source) async {
    photoSelectedState.value = PhotoSelectionState.loading;

    try {
      final userPhotoFile = await ImagePicker().pickImage(source: source);
      // Если платформа не вэб, то запускаем плагин обрезки фотографии https://pub.dev/packages/image_cropper
      if (!kIsWeb) {
        var croppedFile = await ImageCropper.cropImage(sourcePath: userPhotoFile!.path, aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ]);
        userPhotoBytes.value = await croppedFile?.readAsBytes();
      } else {
        userPhotoBytes.value = await userPhotoFile?.readAsBytes();
      }

      // Согласование статуса загруженной картинки с наличием объекта по ссылке
      userPhotoBytes.value == null
          ? photoSelectedState.value = PhotoSelectionState.nonSelected
          : photoSelectedState.value = PhotoSelectionState.loaded;
    } catch (e) {
      e.printError();
      photoSelectedState.value = PhotoSelectionState.error;
    }
  }

  /// метод сброса загруженной фотографии
  void clearUserPhotoFile() {
    userPhotoBytes.value = null;
    photoSelectedState.value = PhotoSelectionState.nonSelected;
  }
}

/// Текущий статус процесса выбора фотографии в приложении
enum PhotoSelectionState { nonSelected, loading, error, loaded }
