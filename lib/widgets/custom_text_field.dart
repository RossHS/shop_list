import 'package:flutter/material.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';

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
  }) : super(key: key);

  final String? hint;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool obscureText;
  final Function? onChanged;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  @override
  Widget build(BuildContext context) {
    return AnimatedPainterLine90s(
      paintSide: PaintSide.bottom,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          obscureText: widget.obscureText,
          controller: widget.controller,
          decoration: InputDecoration(
            prefixIcon: const AnimatedIcon90s(iconsList: CustomIcons.create),
            labelText: widget.hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
