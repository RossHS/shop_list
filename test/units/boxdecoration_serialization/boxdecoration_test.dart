import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_models/theme_utils.dart';

void main() {
  final storage = GetStorage();
  test('JustColor BoxDecoration test', () {
    // Не использую просто Colors.blue, т.к. это Material обертка над обычным Color,
    // из-за чего тест не будет пройден - т.к. при десериализации создается обычный объект Color.
    // Но это является позволительным допущением т.к. данные цвета выглядят одинаковыми, что для меня самое главное
    final decoration = BoxDecoration(color: Colors.blue.shade400);
    var json = ThemeWrapperUtils.justColorToJson(decoration);
    var parsedDecoration = ThemeWrapperUtils.justColorFromJson(json);
    expect(decoration == parsedDecoration, true, reason: 'without GetStorage');
    storage.write('just_color_test', json);
    json = storage.read<Map<String, dynamic>>('just_color_test')!;
    parsedDecoration = ThemeWrapperUtils.justColorFromJson(json);
    expect(decoration == parsedDecoration, true, reason: 'with GetStorage');
  });
}
