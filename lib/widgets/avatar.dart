import 'package:flutter/material.dart';
import 'package:shop_list/models/models.dart';

/// Аватар пользователя
class Avatar extends StatelessWidget {
  const Avatar({
    required this.user,
    this.diameter = 160.0,
    Key? key,
  })  : assert(diameter > 0, 'incorrect diameter $diameter'),
        super(key: key);

  final UserModel? user;

  /// Диаметр аватара пользователя
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheDiameter = (diameter * devicePixelRatio).round();
    // Если нет такого пользователя или у него отсутствует аватар, то используем стандартную картинку
    return user == null || user!.photoUrl == ''
        ? Image.asset(
            'assets/img/avatar.png',
            fit: BoxFit.cover,
            width: diameter,
            height: diameter,
          )
        : Image.network(
            user!.photoUrl,
            fit: BoxFit.cover,
            width: diameter,
            height: diameter,
            cacheWidth: cacheDiameter,
            cacheHeight: cacheDiameter,
            // Обработка процесса загрузки аватара пользователя
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              } else {
                return _PlaceHolder(
                  user: user!,
                  diameter: diameter,
                );
              }
            },
          );
  }
}

/// PlaceHolder процесса загрузки аватара пользователя из сети
/// В нем отображается первая буква имени пользователя с цветным фоном
class _PlaceHolder extends StatelessWidget {
  const _PlaceHolder({
    required this.user,
    required this.diameter,
    Key? key,
  }) : super(key: key);

  final UserModel user;

  /// Диаметр PlaceHolder
  final double diameter;

  @override
  Widget build(BuildContext context) {
    // Первая буква имени пользователя
    final firstChar = user.name != '' ? user.name[0] : '?';

    return Container(
      height: diameter,
      width: diameter,
      color: Colors.yellow,
      child: Center(
        child: Text(
          firstChar,
          style: TextStyle(fontSize: diameter),
        ),
      ),
    );
  }
}
