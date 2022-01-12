/// Класс решающий проблему с передачей null значений в методы по типу copyWith,
/// которые при наличие в аргумента null используют значение из клонируемого объекта
class Optional<T> {
  const Optional(this.value);

  final T? value;
}
