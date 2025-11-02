import 'package:flutter/material.dart';

/// A reusable confirmation dialog for deletion operations.
/// 
/// This widget displays a confirmation dialog with a customizable title,
/// message, and entity name to confirm destructive deletion actions.
class DeleteConfirmationDialog extends StatelessWidget {
  /// The name of the entity being deleted (e.g., "task", "category")
  final String entityName;

  /// Optional custom title. If not provided, defaults to "Confirm {entityName} Deletion"
  final String? title;

  /// Optional custom message. If not provided, uses default message.
  final String? message;

  const DeleteConfirmationDialog({
    super.key,
    required this.entityName,
    this.title,
    this.message,
  });

  String get _defaultTitle => 'Confirm ${_capitalizeFirst(entityName)} Deletion';
  String get _defaultMessage =>
      'Are you sure you want to permanently delete this ${entityName}? This action cannot be undone.';

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? _defaultTitle),
      content: Text(message ?? _defaultMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  /// Static method to show the confirmation dialog.
  /// 
  /// Returns `true` if the user confirmed deletion, `false` if cancelled.
  static Future<bool?> show(
    BuildContext context, {
    required String entityName,
    String? title,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        entityName: entityName,
        title: title,
        message: message,
      ),
    );
  }
}
