import 'package:flutter/material.dart';

class FormDialog extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String? saveText;
  final String? cancelText;

  const FormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.onSave,
    this.onCancel,
    this.saveText,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fields,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(cancelText ?? 'Cancelar'),
        ),
        FilledButton(
          onPressed: onSave ?? () => Navigator.of(context).pop(),
          child: Text(saveText ?? 'Guardar'),
        ),
      ],
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(cancelText ?? 'Cancelar'),
        ),
        FilledButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
          child: Text(confirmText ?? 'Confirmar'),
        ),
      ],
    );
  }
}
