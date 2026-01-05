import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:education_app/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:education_app/features/upload/presentation/bloc/upload_event.dart';
import 'package:education_app/features/upload/presentation/bloc/upload_state.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadPage extends StatelessWidget {
  const ImageUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadBloc>(),
      child: const _ImageUploadView(),
    );
  }
}

class _ImageUploadView extends StatefulWidget {
  const _ImageUploadView();

  @override
  State<_ImageUploadView> createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<_ImageUploadView> {
  int _selectedEntityTypeId = 1; // Default: Question
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _altTextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    _altTextController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<UploadBloc>().add(SearchEntitiesEvent(
          _selectedEntityTypeId,
          searchText: _searchController.text,
        ));
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.read<UploadBloc>().add(PickImageEvent(image));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('آپلود تصویر'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state.status == UploadStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تصویر با موفقیت آپلود شد'),
                backgroundColor: AppColors.success,
              ),
            );
            _altTextController.clear();
            _searchController.clear();
          } else if (state.status == UploadStatus.error || state.status == UploadStatus.searchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'خطای ناشناخته'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Entity Type Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedEntityTypeId,
                  decoration: const InputDecoration(
                    labelText: 'نوع محتوا',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('سوال (Question)')),
                    DropdownMenuItem(value: 2, child: Text('پاسخ تشریحی (Detailed Answer)')),
                    DropdownMenuItem(value: 3, child: Text('محتوای آموزشی (Education Content)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedEntityTypeId = value;
                      });
                      // Reset search when type changes
                      context.read<UploadBloc>().add(ResetUploadEvent());
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Search Field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'جستجو (شناسه یا متن)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Results or Selected Entity
                if (state.selectedEntityId != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'محتوای انتخاب شده:',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.selectedEntityTitle ?? '',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<UploadBloc>().add(ResetUploadEvent());
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('تغییر انتخاب'),
                        ),
                      ],
                    ),
                  ),
                ] else if (state.status == UploadStatus.searching) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (state.searchResults.isNotEmpty) ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      itemCount: state.searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = state.searchResults[index];
                        return ListTile(
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('ID: ${item.id}'),
                          trailing: item.existingImageUrl != null
                              ? const Icon(Icons.image, color: Colors.green)
                              : null,
                          onTap: () {
                            context.read<UploadBloc>().add(SelectEntityEvent(item.id, item.title));
                          },
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Image Picker
                if (state.selectedImage != null) ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(state.selectedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(state.selectedImage!.path), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تغییر تصویر'),
                  ),
                ] else ...[
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 48, color: colorScheme.primary),
                          const SizedBox(height: 8),
                          Text('انتخاب تصویر', style: textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                TextField(
                  controller: _altTextController,
                  decoration: const InputDecoration(
                    labelText: 'متن جایگزین (Alt Text)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Upload Button
                FilledButton.icon(
                  onPressed: state.status == UploadStatus.uploading || state.selectedEntityId == null || state.selectedImage == null
                      ? null
                      : () {
                          context.read<UploadBloc>().add(UploadImageEvent(
                                entityTypeId: _selectedEntityTypeId,
                                entityId: state.selectedEntityId!,
                                altText: _altTextController.text,
                              ));
                        },
                  icon: state.status == UploadStatus.uploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: const Text('آپلود تصویر'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
