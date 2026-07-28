import 'package:flutter/material.dart';

/// Visual configuration for the checkout sheet shown by
/// `NotchPay.checkout`.
///
/// Every color defaults to sensible values that adapt to the app's current
/// [Brightness] when not overridden, so most integrations never need to
/// touch this class at all.
@immutable
class NotchPayThemeData {
  /// Creates a checkout theme. Every field falls back to a sensible default
  /// when omitted; see [resolve] for how the ambient [Brightness] fills in
  /// the rest.
  const NotchPayThemeData({
    this.primaryColor = const Color(0xFF5B2A86),
    this.onPrimaryColor = Colors.white,
    this.surfaceColor,
    this.onSurfaceColor,
    this.mutedColor,
    this.successColor = const Color(0xFF16A34A),
    this.errorColor = const Color(0xFFDC2626),
    this.borderRadius = 20,
    this.fontFamily,
  });

  // ---------------------------------------------------------------------------
  // Ready-made presets
  // ---------------------------------------------------------------------------

  /// A sleek dark theme with NotchPay's signature violet accent.
  ///
  /// ```dart
  /// theme: NotchPayThemeData.darkMode()
  /// ```
  factory NotchPayThemeData.darkMode() => const NotchPayThemeData(
        primaryColor: Color(0xFF5B2A86),
        onPrimaryColor: Colors.white,
        surfaceColor: Color(0xFF17181D),
        onSurfaceColor: Colors.white,
        mutedColor: Color(0xFF9CA3AF),
      );

  /// A fresh emerald-green theme — great for eco / fintech brands.
  ///
  /// ```dart
  /// theme: NotchPayThemeData.emerald()
  /// ```
  factory NotchPayThemeData.emerald() => const NotchPayThemeData(
        primaryColor: Color(0xFF059669),
        onPrimaryColor: Colors.white,
        surfaceColor: Colors.white,
        onSurfaceColor: Color(0xFF14151A),
        mutedColor: Color(0xFF6B7280),
        successColor: Color(0xFF047857),
      );

  /// A deep-purple premium theme — elegant and modern.
  ///
  /// ```dart
  /// theme: NotchPayThemeData.purple()
  /// ```
  factory NotchPayThemeData.purple() => const NotchPayThemeData(
        primaryColor: Color(0xFF7C3AED),
        onPrimaryColor: Colors.white,
        surfaceColor: Color(0xFF0F0A1E),
        onSurfaceColor: Colors.white,
        mutedColor: Color(0xFFA78BFA),
      );

  /// A deep-ocean blue theme — ideal for tech and fintech products.
  ///
  /// ```dart
  /// theme: NotchPayThemeData.ocean()
  /// ```
  factory NotchPayThemeData.ocean() => const NotchPayThemeData(
        primaryColor: Color(0xFF0284C7),
        onPrimaryColor: Colors.white,
        surfaceColor: Color(0xFF0C1A2E),
        onSurfaceColor: Colors.white,
        mutedColor: Color(0xFF7DD3FC),
      );

  // ---------------------------------------------------------------------------
  // Static constants
  // ---------------------------------------------------------------------------

  /// The default light-mode theme, using NotchPay's signature purple.
  static const NotchPayThemeData light = NotchPayThemeData(
    surfaceColor: Colors.white,
    onSurfaceColor: Color(0xFF14151A),
    mutedColor: Color(0xFF6B7280),
  );

  /// The default dark-mode theme, using NotchPay's signature purple.
  static const NotchPayThemeData dark = NotchPayThemeData(
    surfaceColor: Color(0xFF17181D),
    onSurfaceColor: Colors.white,
    mutedColor: Color(0xFF9CA3AF),
  );

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// The brand / primary color used for buttons, selected states and
  /// highlights.
  final Color primaryColor;

  /// The color of text and icons drawn on top of [primaryColor].
  final Color onPrimaryColor;

  /// Background color of the checkout sheet. Defaults to the ambient
  /// [Theme]'s card color when null.
  final Color? surfaceColor;

  /// Default text/icon color on top of [surfaceColor].
  final Color? onSurfaceColor;

  /// Color used for secondary, less important text (helper text, labels).
  final Color? mutedColor;

  /// Color used to indicate a successful payment.
  final Color successColor;

  /// Color used to indicate a failed or cancelled payment.
  final Color errorColor;

  /// Corner radius applied to the sheet, cards and buttons.
  final double borderRadius;

  /// Optional font family override. Defaults to the ambient [Theme]'s font.
  final String? fontFamily;

  // ---------------------------------------------------------------------------
  // Methods
  // ---------------------------------------------------------------------------

  /// Resolves this theme against the ambient [context], falling back to
  /// [light]/[dark] and the surrounding [ThemeData] for any unset field.
  NotchPayThemeData resolve(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final base = brightness == Brightness.dark ? dark : light;
    return NotchPayThemeData(
      primaryColor: primaryColor,
      onPrimaryColor: onPrimaryColor,
      surfaceColor: surfaceColor ?? base.surfaceColor,
      onSurfaceColor: onSurfaceColor ?? base.onSurfaceColor,
      mutedColor: mutedColor ?? base.mutedColor,
      successColor: successColor,
      errorColor: errorColor,
      borderRadius: borderRadius,
      fontFamily: fontFamily,
    );
  }

  /// Returns a copy of this theme with the given fields replaced.
  NotchPayThemeData copyWith({
    Color? primaryColor,
    Color? onPrimaryColor,
    Color? surfaceColor,
    Color? onSurfaceColor,
    Color? mutedColor,
    Color? successColor,
    Color? errorColor,
    double? borderRadius,
    String? fontFamily,
  }) {
    return NotchPayThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      onSurfaceColor: onSurfaceColor ?? this.onSurfaceColor,
      mutedColor: mutedColor ?? this.mutedColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      borderRadius: borderRadius ?? this.borderRadius,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotchPayThemeData &&
        other.primaryColor == primaryColor &&
        other.onPrimaryColor == onPrimaryColor &&
        other.surfaceColor == surfaceColor &&
        other.onSurfaceColor == onSurfaceColor &&
        other.mutedColor == mutedColor &&
        other.successColor == successColor &&
        other.errorColor == errorColor &&
        other.borderRadius == borderRadius &&
        other.fontFamily == fontFamily;
  }

  @override
  int get hashCode => Object.hash(
        primaryColor,
        onPrimaryColor,
        surfaceColor,
        onSurfaceColor,
        mutedColor,
        successColor,
        errorColor,
        borderRadius,
        fontFamily,
      );
}

/// Makes the resolved [NotchPayThemeData] available to every widget under
/// the checkout sheet.
class NotchPayTheme extends InheritedWidget {
  /// Creates a scope providing [data] to descendant widgets.
  const NotchPayTheme({super.key, required this.data, required super.child});

  /// The resolved theme made available to descendants via [of].
  final NotchPayThemeData data;

  /// Returns the nearest enclosing [NotchPayThemeData].
  static NotchPayThemeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NotchPayTheme>();
    assert(scope != null,
        'NotchPayTheme.of() called outside of the checkout sheet');
    return scope!.data;
  }

  @override
  bool updateShouldNotify(NotchPayTheme oldWidget) => data != oldWidget.data;
}
