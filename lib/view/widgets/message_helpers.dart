import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade700,
    ),
  );
}

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  IconData icon = Icons.help_outline,
  Color? confirmColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF133E28) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: confirmColor ?? Colors.green, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(
            color: isDark
                ? const Color(0xFF86EFAC).withValues(alpha: 0.8)
                : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              cancelLabel,
              style: TextStyle(
                color: isDark ? const Color(0xFF86EFAC) : Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}

Future<void> showInformationDialog(
  BuildContext context, {
  required String title,
  required String content,
  String buttonLabel = 'OK',
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF133E28) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
            fontSize: 18,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: isDark
                ? const Color(0xFF86EFAC).withValues(alpha: 0.8)
                : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              buttonLabel,
              style: TextStyle(
                color: isDark ? const Color(0xFF86EFAC) : Colors.green.shade700,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String content,
  String buttonLabel = 'OK',
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF133E28) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
            fontSize: 18,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: isDark
                ? const Color(0xFF86EFAC).withValues(alpha: 0.8)
                : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              buttonLabel,
              style: TextStyle(
                color: isDark ? const Color(0xFF86EFAC) : Colors.red.shade700,
              ),
            ),
          ),
        ],
      );
    },
  );
}
