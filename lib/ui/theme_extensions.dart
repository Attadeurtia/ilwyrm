import 'package:flutter/material.dart';

/// Custom theme extensions for semantic colors not covered by Material 3 standard palette
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color warning;

  const SemanticColors({required this.success, required this.warning});

  @override
  SemanticColors copyWith({Color? success, Color? warning}) {
    return SemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  SemanticColors lerp(SemanticColors? other, double t) {
    if (other is! SemanticColors) {
      return this;
    }
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }

  /// Light mode semantic colors
  static const light = SemanticColors(
    success: Color(0xFF2E7D32), // Green 800
    warning: Color(0xFFF57C00), // Orange 800
  );

  /// Dark mode semantic colors
  static const dark = SemanticColors(
    success: Color(0xFF66BB6A), // Green 400
    warning: Color(0xFFFFB74D), // Orange 300
  );
}

/// Extension to easily access semantic colors from BuildContext
extension SemanticColorsExtension on BuildContext {
  SemanticColors get semanticColors =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}
