import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_list/models/models.dart';

/// Контроллер загрузки файла на сервис Firebase Storage
class FirebaseStorageUploaderController extends GetxController {
  /// Ссылка на ресурс Storage
  static const storagePath = 'gs://shop-list-ebddc.appspot.com/';

  /// Загрузка фотографии на сервис Storage, возвращает ссылку на загруженный ресурс
  // TODO детальней проработать метод загрузки файла. Прописать обработку ошибок загрузки и т.п.
  Future<String> startUpload(XFile file, UserModel user) async {
    var filePath = 'user_avatars/${user.uid}_${DateTime.now()}.png';
    var fileByte = await file.readAsBytes();
    var ref = firebase_storage.FirebaseStorage.instance.ref(filePath).putData(fileByte);
    // Ожидание загрузки файла на сервер
    await ref;
    return ref.snapshot.ref.getDownloadURL();
  }
}
