import 'package:flutter/material.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';
import 'package:shop_list/widgets/themes_factories/material_theme_factory.dart';

import 'animated90s/animated_90s_painter_line.dart';

/// https://stackoverflow.com/questions/61819226/how-to-create-custom-textfield-class
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    Key? key,
    this.hint,
    required this.controller,
    this.onChanged,
    this.inputType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.errorColor = Colors.red,
    this.successColor = Colors.green,
    this.inputValidator,
    this.maxLines,
    this.minLines,
    this.drawUnderLine = true,
    this.decoration,
  }) : super(key: key);

  final String? hint;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool obscureText;
  final Function? onChanged;
  final Widget? prefixIcon;
  final Color errorColor;
  final Color successColor;
  final bool Function(String)? inputValidator;
  final int? maxLines;
  final int? minLines;

  /// Отображать ли нижнюю волнистую линию
  final bool drawUnderLine;
  final InputDecoration? decoration;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // после валидации входной строки через regEx устанавливается цвет
  // который используется для нижней линии
  Color? _currentColor;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = widget.decoration ??
        InputDecoration(
          prefixIcon: widget.prefixIcon,
          labelText: widget.hint,
          border: InputBorder.none,
        );

    return Stack(
      children: <Widget>[
        if (widget.drawUnderLine)
          Positioned.fill(
            bottom: 10,
            child: AnimatedPainterLine90s(
              paintSide: PaintSide.bottom,
              config: Paint90sConfig(outLineColor: _currentColor),
              child: const SizedBox(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: RepaintBoundary(
            child: TextFormField(
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              obscureText: widget.obscureText,
              controller: widget.controller,
              onChanged: (value) {
                if (widget.inputValidator == null) return;
                setState(() {
                  if (widget.inputValidator!(value)) {
                    _currentColor = widget.successColor;
                  } else {
                    _currentColor = widget.errorColor;
                  }
                });
              },
              decoration: inputDecoration,
            ),
          ),
        ),
      ],
    );
  }
}

/// Поле ввода созданное для абстрактной фабрики [MaterialThemeFactory]
class MaterialCustomTextField extends StatefulWidget {
  const MaterialCustomTextField({
    Key? key,
    required this.controller,
    this.inputValidator,
    this.hint,
    this.maxLines,
    this.minLines,
    this.prefixIcon,
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController controller;
  final bool Function(String p1)? inputValidator;
  final String? hint;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final bool obscureText;

  @override
  State<MaterialCustomTextField> createState() => _MaterialCustomTextFieldState();
}

class _MaterialCustomTextFieldState extends State<MaterialCustomTextField> {
  /// Индикация валидации ввода пароля
  Widget? _suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: (value) {
        if (widget.inputValidator == null) return;
        setState(() {
          if (widget.inputValidator!(value)) {
            _suffixIcon = const Icon(Icons.check, color: Colors.green);
          } else {
            _suffixIcon = const Icon(Icons.error, color: Colors.red);
          }
        });
      },
      decoration: InputDecoration(
        suffixIcon: _suffixIcon,
        prefixIcon: widget.prefixIcon,
        labelText: widget.hint,
      ),
    );
  }
}
