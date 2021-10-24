import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Новые данные информации пользователя. Логика загрузки и обработки фотографии
class UserInfoUpdateController extends GetxController {
  /// Объект выбранной фотографии
  final userPhoto = Rxn<XFile>();

  /// Контроллер поля ввода нового имени пользователя
  TextEditingController nameController = TextEditingController();

  /// Состояние процесса выбора фотографии
  final photoSelectedState = Rx<PhotoSelectionState>(PhotoSelectionState.nonSelected);

  Future<void> pickImage(ImageSource source) async {
    photoSelectedState.value = PhotoSelectionState.loading;
    try {
      userPhoto.value = await ImagePicker().pickImage(source: source);
      photoSelectedState.value = PhotoSelectionState.loaded;
    } catch (e) {
      e.printError();
      photoSelectedState.value = PhotoSelectionState.error;
    }
  }

  /// метод сброса загруженной фотографии
  void clearUserPhotoFile() {
    userPhoto.value = null;
    photoSelectedState.value = PhotoSelectionState.nonSelected;
  }
}

/// Текущий статус процесса выбора фотографии в приложении
enum PhotoSelectionState { nonSelected, loading, error, loaded }
