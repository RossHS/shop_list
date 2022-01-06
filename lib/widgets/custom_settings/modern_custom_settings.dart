import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/custom_settings/base_custom_settings.dart';

class ModernCustomSettings extends StatefulWidget {
  const ModernCustomSettings({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final ModernCustomSettingsController controller;

  @override
  State<ModernCustomSettings> createState() => _ModernCustomSettingsState();
}

class _ModernCustomSettingsState extends State<ModernCustomSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ToggleButtons(
        //   children: const <Widget>[
        //     Icon(Icons.ac_unit),
        //     Icon(Icons.call),
        //     Icon(Icons.cake),
        //   ],
        //   isSelected: isSelected,
        // ),
      ],
    );
  }
}

/// Контроллер тонкой настройки темы [ModernThemeDataWrapper], содержащий в себе временные изменения темы.
/// Для принятия изменений следует вызывать метод [acceptChanges]
class ModernCustomSettingsController extends CustomSettingsController {
  ModernCustomSettingsController({
    required ModernThemeDataWrapper proxyThemeWrapper,
  }) : proxyDataWrapper = proxyThemeWrapper.obs;

  final Rx<ModernThemeDataWrapper> proxyDataWrapper;

  @override
  void acceptChanges() {
    final themeController = Get.find<ThemeController>();
    final proxy = proxyDataWrapper.value;
    // themeController.updateMaterialThemeData(
    //   shadowBlurRadius: proxy.shadowBlurRadius,
    //   shadowColor: proxy.shadowColor,
    //   shadowOffset: proxy.shadowOffset,
    // );
  }
}
