// ignore_for_file: unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/controllers/info_overlay_controller.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/utils/text_validators.dart' as text_validation;

/// Бизнес-логика управления состоянием аутентификации пользователя
class AuthenticationController extends GetxController {
  static final _log = Logger('AuthenticationController');

  // Ссылка на сам объект контроллера аутентификации,
  // чтобы не искать каждый раз данный объект в менеджере состояний
  // через Getx. Достаточно найти нужный нам объект 1 раз и возвращать ссылку
  // при необходимости. Можем так поступить т.к. данный контроллер
  // инициализируется еще до запуска приложения
  static final AuthenticationController instance = Get.find();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// База данных firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Модель пользователя, которая идет с библиотекой FirebaseAuthentication
  final firebaseUser = Rxn<User>();
  final firestoreUser = Rxn<UserModel>();

  /// Сообщение об ошибке аутентификации
  final authErrorMessage = Rxn<String>();

  @override
  void onReady() {
    // Запускаем каждый раз обработку изменений по событию в стриме firebaseUser
    ever(firebaseUser, _handleFirebaseUserStateEvent);
    firebaseUser.bindStream(_auth.authStateChanges());
    super.onReady();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Функция выхода из профиля
  Future<void> signOut() async {
    _log.fine('${firestoreUser.value?.name} - SignOut');
    nameController.clear();
    emailController.clear();
    passwordController.clear();

    // Удаление токена пользователя из БД
    if (firebaseUser.value?.uid != null) {
      _deleteDeviceToken(firebaseUser.value!.uid).catchError((e) {
        _log.shout('error while deleting device token, error - $e');
      });
    }

    try {
      await _auth.signOut();
      // Очищение ресурсов пользователя,
      // чтобы при выходе из системы не
      // висели данные прошлого пользователя
      firebaseUser.value = null;
      firestoreUser.value = null;
    } catch (e) {
      _log.shout(e);
    }
  }

  /// Реакция на изменения в потоке FirebaseUser
  void _handleFirebaseUserStateEvent(User? user) {
    if (user?.uid != null) {
      // Загрузка модели пользователя из базы данных firestore Users
      firestoreUser.bindStream(streamFirestoreUser);
      // Сохранение токена устройства
      _saveDeviceToken(user!.uid);
    }

    if (user == null) {
      Get.offAllNamed('/signIn');
    } else {
      Get.offAllNamed('/home');
    }
  }

  /// Вход в сервис firebase при помощи почты и пароля
  void signInWithEmail(BuildContext context) async {
    // Валидация входных значений пароля и почты
    if (!validatePasswordAndEmail()) {
      authErrorMessage.value = 'Non valid email/password';
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Если аутентификация прошла успешно, то обнуляем сообщение об ошибке
      authErrorMessage.value = null;
    } on FirebaseAuthException catch (error) {
      _handleFirebaseAuthException(error.code);
      _log.shout(error);
    }
  }

  /// Метод парсинга приходящего кода ошибки от сервиса FirebaseAuth,
  /// и запаковка данного кода в специальное сообщение об ошибке [authErrorMessage]
  void _handleFirebaseAuthException(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        authErrorMessage.value = 'Invalid email';
        break;
      case 'user-disabled':
        authErrorMessage.value = 'User disabled';
        break;
      case 'user-not-found':
        authErrorMessage.value = 'User not found';
        break;
      case 'wrong-password':
        authErrorMessage.value = 'Wrong password';
        break;
    }
  }

  /// Метод валидации пароля и почты через regEx
  bool validatePasswordAndEmail() =>
      text_validation.email(emailController.text.trim()) && text_validation.password(passwordController.text.trim());

  /// Создание пользователя в firestore коллекции пользователей users
  void _createUserFirestore(UserModel user, User firebaseUser) {
    _db.doc('/users/${firebaseUser.uid}').set(user.toJson());
    update();
  }

  /// Обновление данных пользователя на основании новый данных из контроллеров
  void updateUserInfo(UserInfoUpdateController userInfoUpdateController,
      FirebaseStorageUploaderController firebaseStorageUploader) async {
    final currentUserModel = firestoreUser.value!;

    // Если была выбрана другой аватар, то сначала следует его загрузить на сервис Firebase Storage
    final userAvatarBytes = userInfoUpdateController.userPhotoBytes.value;
    // Ссылка на загруженный аватар в сервис fireStore
    String? userPickUrl;
    if (userAvatarBytes != null) {
      final storageUploader = firebaseStorageUploader;
      userPickUrl = await storageUploader.startUpload(userAvatarBytes, currentUserModel);
      // Сброс файла аватара в контроллере
      userInfoUpdateController.clearUserPhotoFile();
    }

    // Создание нового объекта пользователя на основании новый данных и текущей модели
    final updatedUserModel = currentUserModel.copyWith(
      name: userInfoUpdateController.nameController.text,
      photoUrl: userPickUrl,
    );

    // Обновляем только при наличии различий между текущей моделью пользователя и новой
    if (updatedUserModel != currentUserModel) {
      _updateUserFirestore(
        updatedUserModel,
        firebaseUser.value!,
      );
    }
  }

  /// Обновление пользователя в firestore коллекции пользователей users
  void _updateUserFirestore(UserModel user, User firebaseUser) async {
    const snackBarTitle = 'Данные пользователя';
    await _db.doc('/users/${firebaseUser.uid}').update(user.toJson());
    CustomInfoOverlay.show(title: snackBarTitle, msg: 'Обновлено!');
    update();
  }

  /// После авторизации в приложении, в документе пользователя создается/обновляется коллекция tokens,
  /// где хранятся документы со всеми токенами сервиса Firebase Cloud Messaging.
  /// Данные токены необходимы, чтобы корректно отсылать оповещения по всем
  /// необходимым устройствам на стороне java сервера
  Future<void> _saveDeviceToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    _db.collection('/users/$uid/tokens').doc(token).set({
      'token': token,
      'platform': _parsePlatform(),
      'createdTimestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// После выхода из аккаунта - данный токен необходимо удалить.
  /// Чтобы не приходили оповещения на устройства не с авторизированным пользователем
  Future<void> _deleteDeviceToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    _db.collection('/users/$uid/tokens').doc(token).delete();
  }

  /// Поток загрузки модели пользователя из базы данных firestore users
  Stream<UserModel> get streamFirestoreUser {
    _log.fine('streamFirestoreUser()');

    return _db
        .doc('/users/${firebaseUser.value!.uid}')
        .snapshots()
        .map((snapshot) => UserModel.fromJson(snapshot.data()!));
  }
}

String _parsePlatform() {
  if (GetPlatform.isAndroid) {
    return 'android';
  } else if (GetPlatform.isIOS) {
    return 'ios';
  } else if (GetPlatform.isWeb) {
    return 'web';
  }
  return 'unknown';
}
