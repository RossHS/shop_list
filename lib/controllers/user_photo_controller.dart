import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Логика загрузки и обработки фотографии для последующей загрузки в Firebase Storage
class UserPhotoController extends GetxController {
  /// Объект выбранной фотографии
  final userPhoto = Rxn<XFile>();

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

    print('${photoSelectedState.value}');
  }
}

/// Текущий статус процесса выбора фотографии в приложении
enum PhotoSelectionState { nonSelected, loading, error, loaded }
