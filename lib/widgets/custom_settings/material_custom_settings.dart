// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/custom_settings/base_custom_settings.dart';

/// Виджет настройки кастомных элементов (радиус тени, цвет, расположение) в теме [MaterialThemeDataWrapper]
class MaterialCustomSettings extends StatelessWidget {
  const MaterialCustomSettings({
    super.key,
    required this.controller,
  });

  final MaterialCustomSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final themeWrapper = controller.proxyDataWrapper.value;
        return Column(
          children: [
            // Виджет для демонстрации настроек
            _OffsetSelector(
              themeWrapper: themeWrapper,
              onPositionChange: (offset) {
                controller.proxyDataWrapper.value = controller.proxyDataWrapper.value.copyWith(shadowOffset: offset);
              },
            ),
            const SizedBox(height: 20),
            ColorPicker(
              enableAlpha: false,
              displayThumbColor: false,
              colorPickerWidth: 300,
              paletteType: PaletteType.hueWheel,
              labelTypes: const [],
              pickerColor: themeWrapper.shadowColor,
              onColorChanged: (color) {
                controller.proxyDataWrapper.value = controller.proxyDataWrapper.value.copyWith(
                  shadowColor: color,
                );
              },
            ),
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

/// Виджет настройки позиции тени
class _OffsetSelector extends StatefulWidget {
  const _OffsetSelector({
    required this.themeWrapper,
    required this.onPositionChange,
    this.offset = 15,
    this.width = 200,
    this.height = 200,
  });

  final MaterialThemeDataWrapper themeWrapper;

  /// Минимальное и максимальное значение отступа тени
  final double offset;

  /// Размеры виджета
  final double width;
  final double height;

  /// Обратный вызов на изменение координат
  final void Function(Offset offset) onPositionChange;

  @override
  State<_OffsetSelector> createState() => _OffsetSelectorState();
}

class _OffsetSelectorState extends State<_OffsetSelector> {
  /// Коэффициенты преобразования локальной координаты нажатия
  /// на экран из (0; width/height) в абстрактный диапазон (-offset; +offset)
  late double _factorX;
  late double _factorY;

  @override
  void initState() {
    super.initState();
    _factorX = _calcFactor(widget.width, widget.offset);
    _factorY = _calcFactor(widget.height, widget.offset);
  }

  @override
  void didUpdateWidget(_OffsetSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width) {
      _factorX = _calcFactor(widget.width, widget.offset);
    }
    if (oldWidget.height != widget.height) {
      _factorY = _calcFactor(widget.height, widget.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        _gestureCallback(details.localPosition);
      },
      onPanUpdate: (details) {
        _gestureCallback(details.localPosition);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: widget.themeWrapper.buildDefaultBoxDecoration(context),
        child: Align(
          alignment: Alignment(
            -widget.themeWrapper.shadowOffset.dx / widget.offset,
            -widget.themeWrapper.shadowOffset.dy / widget.offset,
          ),
          child: _OffsetIndicator(
            indicatorColor: widget.themeWrapper.shadowColor,
          ),
        ),
      ),
    );
  }

  void _gestureCallback(Offset localPosition) {
    widget.onPositionChange(
      Offset(
        _lerpCoordinate(widget.width, localPosition.dx, _factorX),
        (_lerpCoordinate(widget.height, localPosition.dy, _factorY)),
      ),
    );
  }

  double _calcFactor(double side, double offset) => (side / 2) / offset;

  /// Преобразование из локальных координат в значения, с которыми может работать пользователь
  double _lerpCoordinate(double side, double localCoordinate, double ratio) {
    // Защита, чтобы не выходить на границы допустимые величиной offset
    if (localCoordinate < 0) localCoordinate = 0;
    if (localCoordinate > side) localCoordinate = side;
    return ((side / 2) - localCoordinate) / ratio;
  }
}

/// Индикатор смещения тени
class _OffsetIndicator extends StatelessWidget {
  const _OffsetIndicator({super.key, this.indicatorColor = Colors.black});

  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.canvasColor.calcTextColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          Icons.lightbulb,
          color: indicatorColor,
        ),
      ),
    );
  }
}

/// Контроллер тонкой настройки темы [MaterialThemeDataWrapper], содержащий в себе временные изменения темы.
/// Для принятия изменений следует вызывать метод [acceptChanges]
class MaterialCustomSettingsController extends CustomSettingsController {
  MaterialCustomSettingsController({
    required MaterialThemeDataWrapper proxyThemeWrapper,
  }) : proxyDataWrapper = proxyThemeWrapper.obs;

  final Rx<MaterialThemeDataWrapper> proxyDataWrapper;

  @override
  void acceptChanges() {
    final themeController = Get.find<ThemeController>();
    final proxy = proxyDataWrapper.value;
    themeController.updateMaterialThemeData(
      shadowBlurRadius: proxy.shadowBlurRadius,
      shadowColor: proxy.shadowColor,
      shadowOffset: proxy.shadowOffset,
    );
  }
}
