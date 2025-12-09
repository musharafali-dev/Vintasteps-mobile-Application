import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_drawer.dart';

final adminUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getUsers();
});

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _searchController = TextEditingController();
  List<dynamic>? _searchResults;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }

    try {
      final repository = ref.read(adminRepositoryProvider);
      final results = await repository.searchUsers(query);
      setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final repository = ref.read(adminRepositoryProvider);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await repository.createUser(email: email, password: password);
                if (mounted) {
                  navigator.pop();
                  ref.invalidate(adminUsersProvider);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('User created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to create user: $e')),
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
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final displayUsers = _searchResults ?? usersAsync.value;

    return Scaffold(
      appBar: AdminAppBar(
        title: 'User Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateUserDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _searchResults = null);
              _searchController.clear();
              ref.invalidate(adminUsersProvider);
            },
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email or user ID...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = null);
                        },
                      )
                    : null,
              ),
              onSubmitted: _searchUsers,
            ),
          ),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (_) {
                if (displayUsers == null || displayUsers.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _searchResults = null);
                    ref.invalidate(adminUsersProvider);
                  },
                  child: ListView.builder(
                    itemCount: displayUsers.length,
                    itemBuilder: (context, index) {
                      final user = displayUsers[index];
                      return _UserListItem(user: user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (user['email'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
          ),
        ),
        title: Text(user['email'] ?? 'N/A'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['full_name'] != null) Text('Name: ${user['full_name']}'),
            Text('Rating: ${user['rating'] ?? 'N/A'}'),
            Text(
              'Verified: ${user['is_phone_verified'] == 1 ? 'Yes' : 'No'}',
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            'ID: ${(user['id'] as String?)?.substring(0, 8) ?? ''}',
            style: const TextStyle(fontSize: 10),
          ),
        ),
        onTap: () {
          // Navigate to user detail page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View details for ${user['email']}')),
          );
        },
      ),
    );
  }
}
