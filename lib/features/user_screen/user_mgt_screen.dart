import 'package:flutter/material.dart';
import 'package:stockflow/core/constant.dart';

class UserManagementScreen extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final VoidCallback onAddUser;

  const UserManagementScreen({
    super.key,
    required this.users,
    required this.onAddUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('User Management')),
      body: users.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => UserTile(user: users[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddUser,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add User'),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user['role'] == 'admin';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isAdmin
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.success.withOpacity(0.12),
            child: Text(
              user['name'][0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isAdmin ? AppColors.primary : AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user['email'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAdmin ? 'Admin' : 'Staff',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isAdmin ? AppColors.primary : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No users found',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddUserDialog({super.key, required this.onSubmit});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String role = 'staff';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new user'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'staff', child: Text('Staff')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => role = v!),
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
          onPressed: () {
            widget.onSubmit({
              'name': nameCtrl.text,
              'email': emailCtrl.text,
              'password': passCtrl.text,
              'role': role,
            });
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
