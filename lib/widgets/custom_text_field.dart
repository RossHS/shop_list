import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';

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

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // после валидации входной строки через regEx устанавливается цвет
  // который используется для нижней линии
  Color? _currentColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
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
          child: TextFormField(
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
            decoration: InputDecoration(
              prefixIcon: widget.prefixIcon,
              labelText: widget.hint,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
