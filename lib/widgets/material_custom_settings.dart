import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';

/// Виджет настройки кастомных элементов (радиус тени, цвет, расположение) в теме [MaterialThemeDataWrapper]
class MaterialCustomSettings extends StatelessWidget {
  const MaterialCustomSettings({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final MaterialCustomSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final themeWrapper = controller.proxyDataWrapper.value;
        return Column(
          children: [
            // Виджет для демонстрации настроек
            Container(
              width: 200,
              height: 200,
              decoration: themeWrapper.buildDefaultBoxDecoration(context),
            ),
            const SizedBox(height: 20),
            Text('Радиус тени - ${themeWrapper.shadowBlurRadius.toStringAsFixed(2)}'),
            Slider(
              value: themeWrapper.shadowBlurRadius,
              min: 0,
              max: 20,
              onChanged: (double shadowBlurRadius) {
                controller.proxyDataWrapper.value = themeWrapper.copyWith(
                  shadowBlurRadius: shadowBlurRadius,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Контроллер тонкой настройки темы [MaterialThemeDataWrapper], содержащий в себе временные изменения темы.
/// Для принятия изменений следует вызывать метод [acceptChanges]
class MaterialCustomSettingsController extends GetxController {
  MaterialCustomSettingsController({
    required MaterialThemeDataWrapper proxyThemeWrapper,
  }) : proxyDataWrapper = proxyThemeWrapper.obs;

  final Rx<MaterialThemeDataWrapper> proxyDataWrapper;

  void acceptChanges() {
    final themeController = Get.find<ThemeController>();
    final proxy = proxyDataWrapper.value;
    themeController.updateMaterialThemeData(
      shadowBlurRadius: proxy.shadowBlurRadius,
    );
  }
}
