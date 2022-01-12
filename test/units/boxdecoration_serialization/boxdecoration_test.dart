import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/models.dart';

/// Тесты функций сериализации [BoxDecoration] используемых классом [GlassmorphismThemeDataWrapper]
void main() {
  final storage = GetStorage();
  // Не использую просто Colors.blue, т.к. это Material обертка над обычным Color,
  // из-за чего тест не будет пройден - т.к. при десериализации создается обычный объект Color.
  // Но это является позволительным допущением, ведь данные цвета выглядят одинаковыми, что для меня самое главное
  _test(
    msg: 'JustColor BoxDecoration test',
    decoration: BoxDecoration(
      color: Colors.blue.shade400,
    ),
    toJson: ThemeWrapperUtils.justColorToJson,
    fromJson: ThemeWrapperUtils.justColorFromJson,
    storage: storage,
  );

  _test(
    msg: 'LinearGradient BoxDecoration test',
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0, 0.5, 1],
        colors: [Colors.white, Colors.black, Colors.green.shade50],
        tileMode: TileMode.mirror,
      ),
    ),
    fromJson: ThemeWrapperUtils.linearGradientFromJson,
    toJson: ThemeWrapperUtils.linearGradientToJson,
    storage: storage,
  );

  _test(
    msg: 'RadialGradient BoxDecoration test',
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.bottomRight,
        focalRadius: 0.32,
        radius: 0.2,
        stops: const [0, 0.2, 1],
        focal: const Alignment(0.2, 0.33),
        colors: [Colors.white, Colors.black, Colors.green.shade50],
        tileMode: TileMode.clamp,
      ),
    ),
    toJson: ThemeWrapperUtils.radialGradientToJson,
    fromJson: ThemeWrapperUtils.radialGradientFromJson,
    storage: storage,
  );

  _test(
    msg: 'RadialGradient BoxDecoration test with null focal and stops',
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        focalRadius: 0.12,
        radius: 0.55,
        colors: [Colors.white, Colors.black, Colors.green.shade50],
        tileMode: TileMode.mirror,
      ),
    ),
    toJson: ThemeWrapperUtils.radialGradientToJson,
    fromJson: ThemeWrapperUtils.radialGradientFromJson,
    storage: storage,
  );
}

typedef ToJson = Map<String, dynamic> Function(BoxDecoration decoration);
typedef FromJson = BoxDecoration Function(Map<String, dynamic> json);

/// Для уменьшения дублирующегося кода,
/// 1) Прямая проверка операций сериализации и десериализации
/// 2) Проверка при наличии записи в хранилище GetStorage
void _test({
  required String msg,
  required BoxDecoration decoration,
  required ToJson toJson,
  required FromJson fromJson,
  required GetStorage storage,
}) {
  test(msg, () async {
    var json = toJson(decoration);
    var parsedDecoration = fromJson(json);
    expect(decoration == parsedDecoration, true, reason: 'without GetStorage');

    await storage.write('COMPARE_TEST_RND', json);
    json = storage.read<Map<String, dynamic>>('COMPARE_TEST_RND')!;
    parsedDecoration = fromJson(json);
    expect(decoration == parsedDecoration, true, reason: 'with GetStorage');
  });
}
