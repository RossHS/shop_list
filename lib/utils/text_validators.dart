/// Валидация пароля пользователя
bool password(String value) => _regexMatch(value, r'^.{6,}$');

/// валидация корректности email адреса
bool email(String value) => _regexMatch(value, r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

bool _regexMatch(String value, String pattern) {
  var regex = RegExp(pattern);
  return regex.hasMatch(value);
}
