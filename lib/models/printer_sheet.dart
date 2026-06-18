// Add this class at the bottom of your pos_screen.dart file
// (after the ReceiptScreen class, before the last closing brace)
//
// Also add this import at the top of pos_screen.dart:
// import '../services/printer_service.dart';

import 'package:flutter/material.dart';
import 'package:stockflow/services/printer_service.dart';

class _PrinterSheet extends StatefulWidget {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String receiptNo;
  final DateTime soldAt;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double vat;
  final double total;
  final String footer;

  const _PrinterSheet({
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.receiptNo,
    required this.soldAt,
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.footer,
  });

  @override
  State<_PrinterSheet> createState() => _PrinterSheetState();
}

class _PrinterSheetState extends State<_PrinterSheet> {
  bool _printing = false;
  String _status = '';

  Future<void> _print() async {
    setState(() {
      _printing = true;
      _status = 'Opening print dialog…';
    });
    try {
      await PrinterService.instance.printReceipt(
        context: context,
        storeName: widget.storeName,
        storeAddress: widget.storeAddress,
        storePhone: widget.storePhone,
        receiptNo: widget.receiptNo,
        soldAt: widget.soldAt,
        items: widget.items,
        subtotal: widget.subtotal,
        vat: widget.vat,
        total: widget.total,
        footer: widget.footer,
      );
      if (mounted)
        setState(() {
          _printing = false;
          _status = '';
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _printing = false;
          _status = 'Print failed: $e';
        });
      }
    }
  }

  Future<void> _sharePdf() async {
    setState(() {
      _printing = true;
      _status = 'Generating PDF…';
    });
    try {
      await PrinterService.instance.shareReceiptAsPdf(
        storeName: widget.storeName,
        storeAddress: widget.storeAddress,
        storePhone: widget.storePhone,
        receiptNo: widget.receiptNo,
        soldAt: widget.soldAt,
        items: widget.items,
        subtotal: widget.subtotal,
        vat: widget.vat,
        total: widget.total,
        footer: widget.footer,
      );
      if (mounted)
        setState(() {
          _printing = false;
          _status = '';
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _printing = false;
          _status = 'Share failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the same dark theme as the receipt screen
    const kBg = Color(0xFF0A0F1E);
    const kCard = Color(0xFF1C2539);
    const kSurface = Color(0xFF141B2D);
    const kAccent = Color(0xFF00E5A0);
    const kBlue = Color(0xFF0066FF);
    const kText = Color(0xFFEEF2FF);
    const kTextDim = Color(0xFF8892A4);
    const kDanger = Color(0xFFFF5370);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.print_rounded, color: kBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Print Receipt',
                    style: TextStyle(
                      color: kText,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.receiptNo,
                    style: const TextStyle(color: kTextDim, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status message
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (_printing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kAccent,
                      ),
                    )
                  else
                    Icon(
                      _status.contains('failed')
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: _status.contains('failed') ? kDanger : kAccent,
                      size: 14,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('failed') ? kDanger : kAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Option 1 — Print via Bluetooth / WiFi
          _option(
            icon: Icons.print_rounded,
            color: kBlue,
            title: 'Print to Bluetooth / WiFi Printer',
            subtitle:
                'Opens system print dialog.\nSelect your thermal printer from the list.',
            onTap: _printing ? null : _print,
            bgColor: kCard,
            textColor: kText,
            subtitleColor: kTextDim,
          ),
          const SizedBox(height: 10),

          // Option 2 — Share as PDF
          _option(
            icon: Icons.picture_as_pdf_rounded,
            color: kAccent,
            title: 'Share / Save as PDF',
            subtitle: 'Send via WhatsApp, email, or save to phone.',
            onTap: _printing ? null : _sharePdf,
            bgColor: kCard,
            textColor: kText,
            subtitleColor: kTextDim,
          ),
          const SizedBox(height: 20),

          // Cancel
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: kTextDim,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _option({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Color bgColor,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
