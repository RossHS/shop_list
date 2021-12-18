import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// TODO 27.11.2021 пока что оставил абстрактным классом, дабы сконцентрироваться на двух других темах
// ignore: deprecated_member_use_from_same_package
abstract class ModernThemeFactory extends ThemeFactory {
  ModernThemeFactory(ThemeDataWrapper themeDataWrapper) : super(themeDataWrapper);
}
