import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_drawer.dart';

final adminCategoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getCategories();
});

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  void _showCreateCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final slugController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: slugController,
                decoration: const InputDecoration(
                  labelText: 'Slug (e.g., footwear)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final slug = slugController.text.trim();
              final description = descriptionController.text.trim();

              if (name.isEmpty || slug.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and slug are required')),
                );
                return;
              }

              try {
                final repository = ref.read(adminRepositoryProvider);
                await repository.createCategory(
                  name: name,
                  slug: slug,
                  description: description.isEmpty ? null : description,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(adminCategoriesProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Category created successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create category: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Scaffold(
      appBar: AdminAppBar(
        title: 'Category Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCategoryDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminCategoriesProvider),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      backgroundColor: const Color(0xFFF1F5F9),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminCategoriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No categories found'),
                  SizedBox(height: 8),
                  Text('Tap + to create a new category'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminCategoriesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryCard(
                  category: category,
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Category'),
                        content: Text(
                            'Are you sure you want to delete "${category['name']}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        final repository = ref.read(adminRepositoryProvider);
                        await repository.deleteCategory(category['id']);
                        if (context.mounted) {
                          ref.invalidate(adminCategoriesProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Category deleted')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete: $e')),
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = category['is_active'] == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.grey,
          child: const Icon(Icons.category, color: Colors.white),
        ),
        title: Text(
          category['name'] ?? 'Unnamed',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slug: ${category['slug'] ?? 'N/A'}'),
            if (category['description'] != null)
              Text(
                category['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            Text('Order: ${category['display_order'] ?? 0}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                isActive ? 'Active' : 'Inactive',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: isActive ? Colors.green : Colors.grey,
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
