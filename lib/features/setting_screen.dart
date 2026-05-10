import 'package:flutter/material.dart';
import 'package:stockflow/core/constant.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic>? user;
  final String? role;

  final VoidCallback onUserManagement;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.role,
    required this.onUserManagement,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?['name'] ?? 'User';
    final email = user?['email'] ?? '';
    final initial = (name.isNotEmpty ? name : 'U')[0].toUpperCase();

    final isAdmin = role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(name: name, email: email, initial: initial, role: role),
          const SizedBox(height: 20),
          const SectionTitle('App'),
          SettingsTile(
            icon: Icons.business_outlined,
            title: 'Business name',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.attach_money,
            title: 'Currency',
            subtitle: 'Nigerian Naira (₦)',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notification preferences',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          if (isAdmin) ...[
            const SectionTitle('Admin'),
            SettingsTile(
              icon: Icons.people_outline,
              title: 'User management',
              onTap: onUserManagement,
            ),
            SettingsTile(
              icon: Icons.category_outlined,
              title: 'Manage categories',
              onTap: () {},
            ),
          ],
          const SizedBox(height: 16),
          const SectionTitle('Account'),
          SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change password',
            onTap: onChangePassword,
          ),
          SettingsTile(
            icon: Icons.logout,
            title: 'Sign out',
            titleColor: AppColors.danger,
            iconColor: AppColors.danger,
            onTap: onLogout,
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'StockFlow v1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String initial;
  final String? role;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.initial,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (role != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
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
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: titleColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}
