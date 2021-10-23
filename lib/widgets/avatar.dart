import 'package:flutter/material.dart';
import 'package:shop_list/models/models.dart';

/// Аватар пользователя
class Avatar extends StatelessWidget {
  const Avatar({
    required this.user,
    Key? key,
  }) : super(key: key);

  final UserModel user;

  /// Размеры картинки аватара
  final width = 120.0;
  final height = 120.0;

  @override
  Widget build(BuildContext context) {
    // Если у пользователя нет аватара, то используем стандартную картинку
    return user.photoUrl == ''
        ? Image.asset(
            'assets/img/sample.jpg',
            fit: BoxFit.cover,
            width: width,
            height: height,
          )
        : Image.network(
            user.photoUrl,
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
  }
}
