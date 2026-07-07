import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// High-contrast text field for login/signup screens (dark gradient background).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.passwordVisible = false,
    this.showPasswordToggle = false,
    this.onTogglePasswordVisibility,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  /// When [isPassword] is true, whether the value is shown in plain text.
  final bool passwordVisible;
  /// Show eye / crossed-eye icon; use the same [onTogglePasswordVisibility] on
  /// linked password fields so one tap toggles all of them.
  final bool showPasswordToggle;
  final VoidCallback? onTogglePasswordVisibility;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  static const Color _fieldFill = Color(0xFFFFFFFF);
  static const Color _textColor = Color(0xFF172235);
  static const Color _hintColor = Color(0xFF6B7C95);
  static const Color _borderColor = Color(0xFFD9E6F8);

  @override
  Widget build(BuildContext context) {
    final obscure = isPassword && !passwordVisible;

    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        color: _textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: AppTheme.primaryColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _hintColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: showPasswordToggle && isPassword
            ? IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _hintColor,
                ),
              )
            : null,
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }
}
