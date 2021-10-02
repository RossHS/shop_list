/// Валидация пароля пользователя
String? password(String? value) {
  if (_regexMatch(value!, r'^.{6,}$')) {
    return 'Не корректный пароль';
  } else {
    return null;
  }
}

/// валидация корректности email адреса
String? email(String? value) {
  if (_regexMatch(value!, r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')) {
    return 'Не правильно указан Email адрес';
  } else {
    return null;
  }
}

bool _regexMatch(String value, String pattern) {
  var regex = RegExp(pattern);
  return !regex.hasMatch(value);
}
