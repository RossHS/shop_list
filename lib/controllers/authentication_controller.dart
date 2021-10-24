import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/utils/text_validators.dart' as text_validation;

/// Бизнес-логика управления состоянием аутентификации пользователя
class AuthenticationController extends GetxController {
  // Ссылка на сам объект контроллера аутентификации,
  // чтобы не искать каждый раз данный объект в менеджере состояний
  // через Getx. Достаточно найти нужный нам объект 1 раз и возвращать ссылку
  // при необходимости. Можем так поступить т.к. данный контроллер
  // инициализируется еще до запуска приложения
  static final AuthenticationController instance = Get.find();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// База данных firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Модель пользователя, которая идет с библиотекой FirebaseAuthentication
  final firebaseUser = Rxn<User>();
  final firestoreUser = Rxn<UserModel>();

  /// Сообщение об ошибке аутентификации
  final authErrorMessage = Rxn<String>();
  final _isAdmin = false.obs;

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
  Future<void> signOut() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    return _auth.signOut();
  }

  /// Реакция на изменения в потоке FirebaseUser
  void _handleFirebaseUserStateEvent(User? user) {
    if (user?.uid != null) {
      // Загрузка модели пользователя из базы данных firestore Users
      firestoreUser.bindStream(streamFirestoreUser);
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
      print(error);
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
  void _createUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/users/${_firebaseUser.uid}').set(user.toJson());
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
  void _updateUserFirestore(UserModel user, User _firebaseUser) {
    const snackBarTitle = 'Update User data';
    _db.doc('/users/${_firebaseUser.uid}').update(user.toJson());
    Get.snackbar(snackBarTitle, 'Updated');
    update();
  }

  /// Поток загрузки модели пользователя из базы данных firestore users
  Stream<UserModel> get streamFirestoreUser {
    print('streamFirestoreUser()');

    return _db
        .doc('/users/${firebaseUser.value!.uid}')
        .snapshots()
        .map((snapshot) => UserModel.fromJson(snapshot.data()!));
  }
}
