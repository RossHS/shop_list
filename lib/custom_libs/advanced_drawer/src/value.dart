part of '../flutter_advanced_drawer.dart';

/// AdvancedDrawer state value.
class AdvancedDrawerValue {
  const AdvancedDrawerValue({
    this.visible = false,
  });

  /// Create a value with hidden state.
  factory AdvancedDrawerValue.hidden() {
    return const AdvancedDrawerValue();
  }

  /// Create a value with visible state.
  factory AdvancedDrawerValue.visible() {
    return const AdvancedDrawerValue(
      visible: true,
    );
  }

  /// Indicates whether drawer visible or not.
  final bool visible;
}
