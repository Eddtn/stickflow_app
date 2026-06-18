// lib/screens/backup_screen.dart
//
// Data Backup & Export screen.
// • DB info card — file size, last modified
// • Export Database — shares raw .stockflow_backup file
// • Restore Database — file picker to import a backup
// • Export CSV — shares products + sales as CSV
// • Auto-backup reminder setting

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/services/backup_service.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0A0F1E);
const _kSurface = Color(0xFF141B2D);
const _kCard = Color(0xFF1C2539);
const _kAccent = Color(0xFF00E5A0);
const _kAccentDim = Color(0xFF00B87A);
const _kWarning = Color(0xFFFFB547);
const _kDanger = Color(0xFFFF5370);
const _kBlue = Color(0xFF7C9FFF);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _svc = BackupService.instance;

  BackupInfo? _info;
  bool _loadingInfo = true;
  bool _exporting = false;
  bool _restoring = false;
  bool _exportingCsv = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() => _loadingInfo = true);
    final info = await _svc.getBackupInfo();
    setState(() {
      _info = info;
      _loadingInfo = false;
    });
  }

  // ── Export DB ─────────────────────────────────────────────────────────────
  Future<void> _exportDb() async {
    HapticFeedback.mediumImpact();
    setState(() => _exporting = true);
    final ok = await _svc.exportDatabase();
    setState(() => _exporting = false);
    if (!mounted) return;
    _showSnack(
      ok
          ? '✅  Backup ready — share or save it somewhere safe'
          : '❌  Export failed',
      ok ? _kAccent : _kDanger,
    );
    if (ok) _loadInfo();
  }

  // ── Restore DB ────────────────────────────────────────────────────────────
  Future<void> _restoreDb() async {
    // Confirm first — this is destructive
    final confirmed = await _confirmDialog(
      title: 'Restore Database',
      message:
          'This will REPLACE all current data with the selected backup.\n\nThis cannot be undone. Are you sure?',
      confirmLabel: 'Yes, Restore',
      confirmColor: _kDanger,
    );
    if (confirmed != true) return;

    HapticFeedback.mediumImpact();
    setState(() => _restoring = true);
    final result = await _svc.restoreDatabase();
    setState(() => _restoring = false);
    if (!mounted) return;

    if (result.cancelled) return;

    if (result.success) {
      _showSnack(
        '✅  Restored: ${result.productCount} products, ${result.saleCount} sales',
        _kAccent,
        duration: const Duration(seconds: 4),
      );
      _loadInfo();
    } else {
      _showSnack(
        '❌  ${result.errorMessage}',
        _kDanger,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ── Export CSV ────────────────────────────────────────────────────────────
  Future<void> _exportCsv() async {
    HapticFeedback.mediumImpact();
    setState(() => _exportingCsv = true);
    final ok = await _svc.exportCsv();
    setState(() => _exportingCsv = false);
    if (!mounted) return;
    _showSnack(
      ok ? '✅  CSV export ready' : '❌  CSV export failed',
      ok ? _kAccent : _kDanger,
    );
  }

  // ── Confirm dialog ────────────────────────────────────────────────────────
  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(color: _kText, fontWeight: FontWeight.w700),
        ),
        content: Text(
          message,
          style: const TextStyle(color: _kTextDim, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _kTextDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: confirmColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(
    String msg,
    Color color, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: _kBg),
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _kTextDim,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Backup & Export',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: _kTextDim),
              onPressed: _loadInfo,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSectionLabel('BACKUP'),
            const SizedBox(height: 10),
            _buildActionCard(
              icon: Icons.cloud_upload_rounded,
              iconColor: _kAccent,
              title: 'Export Database',
              subtitle:
                  'Save a full backup of all products, sales and settings. Share it via WhatsApp, email, or save to cloud storage.',
              buttonLabel: 'Export Now',
              buttonColor: _kAccent,
              loading: _exporting,
              onTap: _exportDb,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.cloud_download_rounded,
              iconColor: _kBlue,
              title: 'Restore from Backup',
              subtitle:
                  'Pick a .stockflow_backup file to restore. WARNING: This replaces all current data.',
              buttonLabel: 'Choose File',
              buttonColor: _kBlue,
              loading: _restoring,
              onTap: _restoreDb,
              isDestructive: true,
            ),
            const SizedBox(height: 24),
            _buildSectionLabel('EXPORT DATA'),
            const SizedBox(height: 10),
            _buildActionCard(
              icon: Icons.table_chart_rounded,
              iconColor: _kWarning,
              title: 'Export as CSV',
              subtitle:
                  'Export all products and sales history as a CSV file. Open in Excel, Google Sheets, or any spreadsheet app.',
              buttonLabel: 'Export CSV',
              buttonColor: _kWarning,
              loading: _exportingCsv,
              onTap: _exportCsv,
            ),
            const SizedBox(height: 24),
            _buildSectionLabel('HOW IT WORKS'),
            const SizedBox(height: 10),
            _buildHowItWorks(),
          ],
        ),
      ),
    );
  }

  // ── DB info card ───────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kAccent.withOpacity(0.12), _kBlue.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAccent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storage_rounded, color: _kAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _loadingInfo
                ? const Text(
                    'Loading database info…',
                    style: TextStyle(color: _kTextDim),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local Database',
                        style: TextStyle(
                          color: _kText,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _infoRow(
                        Icons.folder_rounded,
                        'pos_store.db  ·  ${_info!.sizeKb} KB',
                      ),
                      const SizedBox(height: 4),
                      _infoRow(
                        Icons.access_time_rounded,
                        _info!.lastModified != null
                            ? 'Last modified: ${_formatDate(_info!.lastModified!)}'
                            : 'No data yet',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: _kTextDim, size: 13),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: _kTextDim, fontSize: 12),
        ),
      ),
    ],
  );

  // ── Section label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: _kTextDim,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );

  // ── Action card ────────────────────────────────────────────────────────────
  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    required bool loading,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDestructive
              ? _kDanger.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isDestructive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _kDanger.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'CAUTION',
                    style: TextStyle(
                      color: _kDanger,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(color: _kTextDim, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                disabledBackgroundColor: buttonColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: _kBg,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: _kBg,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── How it works ───────────────────────────────────────────────────────────
  Widget _buildHowItWorks() {
    final steps = [
      (
        icon: Icons.cloud_upload_rounded,
        color: _kAccent,
        title: 'Export Database',
        desc:
            'Creates a copy of your entire database — products, sales, everything — as a single file you can save to Google Drive, WhatsApp, or email.',
      ),
      (
        icon: Icons.cloud_download_rounded,
        color: _kBlue,
        title: 'Restore from Backup',
        desc:
            'To move to a new phone or recover after uninstalling, pick your .stockflow_backup file and all data is restored instantly.',
      ),
      (
        icon: Icons.table_chart_rounded,
        color: _kWarning,
        title: 'Export CSV',
        desc:
            'Opens your data in Excel or Google Sheets for accounting, reporting, or sharing with your accountant.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: steps.map((s) {
          final isLast = s == steps.last;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: const TextStyle(
                            color: _kText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.desc,
                          style: const TextStyle(
                            color: _kTextDim,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: Colors.white10, height: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m $ampm';
  }
}
