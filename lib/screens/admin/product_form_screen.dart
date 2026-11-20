import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/category_providers.dart';
import '../../providers/product_providers.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/product_image.dart';
import '../../widgets/state_views.dart';

/// Add / edit product (admin only). In edit mode the form is pre-filled
/// with the product's current values.
class ProductFormScreen extends ConsumerWidget {
  /// null = add a new product.
  final int? productId;
  final Product? initial;

  const ProductFormScreen({super.key, this.productId, this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = productId != null;
    final title = Text(isEdit ? 'Edit Product' : 'Add Product');
    final categories = ref.watch(categoriesProvider);

    // Edit opened by URL: load the product first.
    if (isEdit && initial == null) {
      final product = ref.watch(productByIdProvider(productId!));
      return GradientScaffold(
        title: title,
        body: AsyncValueView<Product>(
          value: product,
          onRetry: () => ref.invalidate(productByIdProvider(productId!)),
          data: (p) => _withCategories(ref, categories, p),
        ),
      );
    }

    return GradientScaffold(
      title: title,
      body: _withCategories(ref, categories, initial),
    );
  }

  Widget _withCategories(
    WidgetRef ref,
    AsyncValue<List<ProductCategory>> categories,
    Product? product,
  ) {
    return AsyncValueView<List<ProductCategory>>(
      value: categories,
      onRetry: () => ref.invalidate(categoriesProvider),
      isEmpty: (list) => list.isEmpty,
      empty: const MessageView(
        icon: Icons.category_outlined,
        title: 'No categories yet',
        message: 'Add a category first (Categories tab), then add products to it.',
      ),
      data: (list) => _ProductForm(product: product, categories: list),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  final Product? product;
  final List<ProductCategory> categories;

  const _ProductForm({required this.product, required this.categories});

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  int? _categoryId;

  PickedImage? _newImage;
  bool _removeImage = false;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p == null ? '' : _num(p.price));
    _stock = TextEditingController(text: p == null ? '' : '${p.stock}');
    _categoryId = p?.categoryId;
    if (_categoryId != null && !widget.categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 5 * 1024 * 1024) {
        showMessage(context, 'Image is larger than 5 MB.', error: true);
        return;
      }
      setState(() {
        _newImage = PickedImage(bytes: bytes, fileName: file.name, mimeType: file.mimeType);
        _removeImage = false;
      });
    } catch (e) {
      if (mounted) showMessage(context, "Couldn't open the image: $e", error: true);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final saved = await ref.read(productActionsProvider).save(
            existing: widget.product,
            name: _name.text,
            description: _description.text,
            price: double.parse(_price.text.trim()),
            stock: int.parse(_stock.text.trim()),
            categoryId: _categoryId!,
            newImage: _newImage,
            removeImage: _removeImage,
          );
      if (!mounted) return;
      showMessage(context, _isEdit ? '"${saved.name}" updated.' : '"${saved.name}" added.');
      _close();
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Back to the product list (also works when opened directly by URL).
  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/admin/products');
    }
  }

  // ---------------- Validation ----------------

  static String? _validateName(String? v) =>
      (v ?? '').trim().isEmpty ? 'Name is required' : null;

  static String? _validatePrice(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return 'Price is required';
    final value = double.tryParse(text);
    if (value == null || !value.isFinite) return 'Price must be a number';
    if (value < 0) return 'Price must be 0 or more';
    return null;
  }

  static String? _validateStock(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return 'Stock is required';
    final value = int.tryParse(text);
    if (value == null) return 'Stock must be a whole number';
    if (value < 0) return 'Stock must be 0 or more';
    if (value > 32767) return 'Stock can be at most 32767';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _imagePicker(),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _name,
                      enabled: !_saving,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Name *'),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _description,
                      enabled: !_saving,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _price,
                            enabled: !_saving,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Price *',
                              prefixText: '₱ ',
                            ),
                            validator: _validatePrice,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stock,
                            enabled: !_saving,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                            ],
                            decoration: const InputDecoration(labelText: 'Stock *'),
                            validator: _validateStock,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(labelText: 'Category *'),
                      items: [
                        for (final c in widget.categories)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: _saving ? null : (v) => setState(() => _categoryId = v),
                      validator: (v) => v == null ? 'Choose a category' : null,
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _saving ? 'Saving…' : (_isEdit ? 'Save changes' : 'Add product'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _saving ? null : _close,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePicker() {
    final existing = widget.product;
    final hasExisting = existing?.imageUrl != null && !_removeImage;

    Widget preview;
    if (_newImage != null) {
      preview = Image.memory(_newImage!.bytes, fit: BoxFit.contain);
    } else if (hasExisting) {
      preview = ProductImage(product: existing!);
    } else {
      preview = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 48),
          SizedBox(height: 6),
          Text('No image'),
        ],
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _saving ? null : _pickImage,
          child: Container(
            height: 180,
            width: 180,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: preview,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickImage,
              icon: const Icon(Icons.image_rounded),
              label: Text(_newImage != null || hasExisting ? 'Change image' : 'Choose image'),
            ),
            if (_newImage != null || hasExisting)
              TextButton.icon(
                onPressed: _saving
                    ? null
                    : () => setState(() {
                          _newImage = null;
                          _removeImage = true;
                        }),
                icon: const Icon(Icons.hide_image_outlined),
                label: const Text('Remove'),
              ),
          ],
        ),
      ],
    );
  }
}
