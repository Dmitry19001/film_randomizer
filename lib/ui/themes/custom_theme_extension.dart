import 'package:flutter/material.dart';

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? chipColor;
  final TextStyle? textStyle;

  CustomThemeExtension({this.chipColor, this.textStyle});

  @override
  CustomThemeExtension copyWith({Color? chipColor, TextStyle? textStyle}) {
    return CustomThemeExtension(
      chipColor: chipColor ?? this.chipColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }

    return CustomThemeExtension(
      chipColor: Color.lerp(chipColor, other.chipColor, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}

extension CustomThemeExtensionMethods on ThemeData {
  CustomThemeExtension get customExtension => extension<CustomThemeExtension>() ?? CustomThemeExtension();
}
