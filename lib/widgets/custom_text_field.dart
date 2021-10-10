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
    this.errorColor,
  }) : super(key: key);

  final String? hint;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool obscureText;
  final Function? onChanged;
  final Widget? prefixIcon;
  final Color? errorColor;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPainterLine90s(
      paintSide: PaintSide.bottom,
      config: Paint90sConfig(outLineColor: widget.errorColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          obscureText: widget.obscureText,
          controller: widget.controller,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            labelText: widget.hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
