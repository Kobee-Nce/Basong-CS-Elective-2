import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../providers/category_providers.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/state_views.dart';

/// Admin category management: add, rename, delete.
class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String success,
  ) async {
    try {
      await action();
      if (context.mounted) showMessage(context, success);
    } catch (e) {
      if (context.mounted) showMessage(context, e.toString(), error: true);
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await _askName(context, title: 'Add category');
    if (name == null || !context.mounted) return;
    await _run(
      context,
      () => ref.read(categoryActionsProvider).create(name),
      'Category "$name" added.',
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, ProductCategory c) async {
    final name = await _askName(context, title: 'Rename category', initial: c.name);
    if (name == null || name == c.name || !context.mounted) return;
    await _run(
      context,
      () => ref.read(categoryActionsProvider).rename(c.id, name),
      'Renamed to "$name".',
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ProductCategory c) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete category?',
      message: 'Delete "${c.name}"? Categories that still have products '
          'cannot be deleted.',
    );
    if (!ok || !context.mounted) return;
    await _run(
      context,
      () => ref.read(categoryActionsProvider).delete(c.id),
      '"${c.name}" deleted.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return GradientScaffold(
      title: const Text('Manage Categories'),
      actions: const [AppBarActions()],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-category',
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add category'),
      ),
      body: AsyncValueView<List<ProductCategory>>(
        value: categories,
        onRetry: () => ref.invalidate(categoriesProvider),
        isEmpty: (list) => list.isEmpty,
        empty: const MessageView(
          icon: Icons.category_outlined,
          title: 'No categories yet',
          message: 'Tap "Add category" to create one.',
        ),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final c = list[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.label_rounded),
                title: Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Rename',
                      onPressed: () => _rename(context, ref, c),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _delete(context, ref, c),
                      icon: const Icon(Icons.delete_rounded),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Dialog with a single required text field.
Future<String?> _askName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(title: title, initial: initial),
  );
}

class _NameDialog extends StatefulWidget {
  final String title;
  final String initial;

  const _NameDialog({required this.title, required this.initial});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Category name'),
          validator: (v) => (v ?? '').trim().isEmpty ? 'Name is required' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
