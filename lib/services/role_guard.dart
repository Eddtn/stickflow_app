// lib/widgets/role_guard.dart
//
// Wraps any widget — shows it only if the condition is met,
// otherwise shows a "no access" message or nothing.

import 'package:flutter/material.dart';
import '../services/seller_session.dart';

class RoleGuard extends StatelessWidget {
  final bool condition;
  final Widget child;
  final bool showDenied; // show a denial UI instead of hiding

  const RoleGuard({
    super.key,
    required this.condition,
    required this.child,
    this.showDenied = false,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) return child;
    if (showDenied) return const _AccessDenied();
    return const SizedBox.shrink();
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFFE53935),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Access Restricted',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This section is only available\nto the store owner.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A5568),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Logged in as: ${SellerSession.instance.sellerName}',
                style: const TextStyle(color: Color(0xFF8892A4), fontSize: 12),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0057FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
