import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  // Constants
  static const double _defaultBorderRadius = 8.0;
  static const double _defaultBorderWidth = 1.0;
  static const double _defaultIconSpacing = 8.0;
  static const Duration _defaultAnimationDuration = Duration(milliseconds: 200);

  // Required properties with validation
  final String? buttonText;
  final Widget? child;
  final VoidCallback? onPressed;

  // Optional properties with meaningful defaults
  final double borderRadius;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledBorderColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final TextStyle? disabledTextStyle;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? icon;
  final MainAxisAlignment contentAlignment;
  final double iconSpacing;
  final ButtonType buttonType;
  final Color? borderColor;
  final double borderWidth;
  final Color? shadowColor;
  final double? elevation;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final MouseCursor? mouseCursor;
  final bool enableFeedback;
  final InteractiveInkFeatureFactory? splashFactory;
  final Color? overlayColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? splashColor;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final Offset? highlightOffset;
  final Duration animationDuration;
  final bool enableBorder;

  const AppTextButton({
    super.key,
    this.buttonText,
    this.child,
    this.onPressed,
    this.borderRadius = _defaultBorderRadius,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.disabledBorderColor,
    this.gradient,
    this.padding,
    this.width,
    this.height,
    this.textStyle,
    this.disabledTextStyle,
    this.isLoading = false,
    this.loadingWidget,
    this.icon,
    this.contentAlignment = MainAxisAlignment.center,
    this.iconSpacing = _defaultIconSpacing,
    this.buttonType = ButtonType.text,
    this.borderColor,
    this.borderWidth = _defaultBorderWidth,
    this.shadowColor,
    this.elevation,
    this.materialTapTargetSize,
    this.visualDensity,
    this.mouseCursor,
    this.enableFeedback = true,
    this.splashFactory,
    this.overlayColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.highlightOffset,
    this.animationDuration = _defaultAnimationDuration,
    this.enableBorder = true,
  }) : assert(buttonText != null || child != null,
            'Either buttonText or child must be provided');

  @override
  Widget build(BuildContext context) {
    return _ButtonBuilder(
      context: context,
      config: this,
    ).build();
  }
}

class _ButtonBuilder {
  final BuildContext context;
  final AppTextButton config;
  late final ThemeData _theme;
  late final ColorScheme _colorScheme;
  late final bool _isDisabled;

  _ButtonBuilder({
    required this.context,
    required this.config,
  }) {
    _theme = Theme.of(context);
    _colorScheme = _theme.colorScheme;
    _isDisabled = config.onPressed == null || config.isLoading;
  }

  Widget build() {
    final buttonChild = _buildChild();
    final buttonStyle = _buildButtonStyle();
    Widget button = _buildButtonType(buttonStyle, buttonChild);

    if (config.gradient != null && config.buttonType != ButtonType.text) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          gradient: config.gradient,
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
        child: button,
      );
    }

    return SizedBox(
      width: config.width,
      height: config.height,
      child: button,
    );
  }

  Widget _buildChild() {
    if (config.isLoading) {
      return config.loadingWidget ?? _buildLoadingIndicator();
    }

    if (config.child != null) return config.child!;

    final defaultTextStyle = config.buttonType == ButtonType.text
        ? _theme.textTheme.labelLarge?.copyWith(color: _colorScheme.primary)
        : _theme.textTheme.labelLarge;

    final effectiveTextStyle = config.textStyle ?? defaultTextStyle;
    final textStyle = _isDisabled
        ? (config.disabledTextStyle ??
            effectiveTextStyle?.copyWith(color: _theme.disabledColor))
        : effectiveTextStyle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: config.contentAlignment,
      children: [
        if (config.icon != null) ...[
          config.icon!,
          SizedBox(width: config.iconSpacing),
        ],
        Text(
          config.buttonText!,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: config.width,
      height: config.height,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          config.disabledTextStyle?.color ?? _theme.disabledColor,
        ),
      ),
    );
  }

  Widget _buildButtonType(ButtonStyle style, Widget child) {
    final onPressed = config.isLoading ? null : config.onPressed;

    return switch (config.buttonType) {
      ButtonType.elevated => ElevatedButton(
          style: style,
          onPressed: onPressed,
          child: child,
        ),
      ButtonType.outlined => OutlinedButton(
          style: style,
          onPressed: onPressed,
          child: child,
        ),
      ButtonType.text => TextButton(
          style: style,
          onPressed: onPressed,
          child: child,
        ),
    };
  }

  ButtonStyle _buildButtonStyle() {
    return ButtonStyle(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (_isDisabled) {
          return config.disabledTextStyle?.color ?? _theme.disabledColor;
        }
        if (config.buttonType == ButtonType.text) {
          return config.textStyle?.color ?? _colorScheme.primary;
        }
        return config.textStyle?.color ?? _colorScheme.onPrimary;
      }),
      padding: WidgetStateProperty.all(config.padding),
      minimumSize: WidgetStateProperty.all(Size.zero),
      elevation: WidgetStateProperty.all(
        config.buttonType == ButtonType.text ? 0 : config.elevation,
      ),
      shadowColor: WidgetStateProperty.all(
        config.buttonType == ButtonType.text
            ? Colors.transparent
            : config.shadowColor,
      ),
      shape: WidgetStateProperty.resolveWith(_getShape),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (config.buttonType == ButtonType.text) {
          return config.overlayColor ?? _colorScheme.primary.withOpacity(0.08);
        }
        return config.overlayColor ?? _colorScheme.primary.withOpacity(0.1);
      }),
      mouseCursor: WidgetStateProperty.all(config.mouseCursor),
      visualDensity: config.visualDensity,
      tapTargetSize: config.materialTapTargetSize,
      animationDuration: config.animationDuration,
      enableFeedback: config.enableFeedback,
      splashFactory: config.splashFactory,
    );
  }

  WidgetStateProperty<Color?> _getBackgroundColor() {
    if (config.gradient != null || config.buttonType == ButtonType.text) {
      return const WidgetStatePropertyAll(Colors.transparent);
    }

    return WidgetStateProperty.resolveWith((states) {
      if (_isDisabled) {
        return config.disabledBackgroundColor ?? _colorScheme.surface;
      }
      if (states.contains(WidgetState.pressed)) {
        return config.backgroundColor?.withOpacity(0.8) ??
            _colorScheme.primary.withOpacity(0.8);
      }
      if (states.contains(WidgetState.hovered)) {
        return config.backgroundColor?.withOpacity(0.9) ??
            _colorScheme.primary.withOpacity(0.9);
      }
      return config.backgroundColor ?? _colorScheme.primary;
    });
  }

  OutlinedBorder _getShape(Set<WidgetState> states) {
    final borderColor = _isDisabled
        ? config.disabledBorderColor ?? _colorScheme.onSurface.withOpacity(0.12)
        : config.borderColor ?? _colorScheme.outline;

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(config.borderRadius),
      side: config.enableBorder && config.buttonType != ButtonType.text
          ? BorderSide(
              color: states.contains(WidgetState.pressed)
                  ? borderColor.withOpacity(0.8)
                  : borderColor,
              width: config.borderWidth,
            )
          : BorderSide.none,
    );
  }
}

enum ButtonType { text, elevated, outlined }
