import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/custom_text_field.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

class ThemeDepTextField extends ThemeDepWidgetBase {
  const ThemeDepTextField({
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
  final bool Function(String)? inputValidator;
  final String? hint;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final bool obscureText;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return CustomTextField(
      key: key,
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
      controller: controller,
      inputValidator: inputValidator,
      hint: hint,
      maxLines: maxLines,
      minLines: minLines,
      prefixIcon: prefixIcon,
      obscureText: obscureText,
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return MaterialCustomTextField(
      key: key,
      controller: controller,
      inputValidator: inputValidator,
      hint: hint,
      maxLines: maxLines,
      minLines: minLines,
      prefixIcon: prefixIcon,
      obscureText: obscureText,
    );
  }
}
