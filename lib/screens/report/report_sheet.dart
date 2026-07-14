import 'package:flutter/material.dart';
import '../../services/report_service.dart';

export '../../services/report_service.dart' show ReportTargetType;

class ReportSheet extends StatefulWidget {
  final ReportTargetType targetType;
  final String targetId;

  const ReportSheet({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  static const _reasons = [
    'Inappropriate photo',
    'Spam',
    'Harassment',
    'Other',
  ];
  String? _selectedReason;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    setState(() => _isSubmitting = true);
    await ReportService.submitReport(
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: _selectedReason!,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report', style: Theme.of(context).textTheme.titleLarge),
            ..._reasons.map((r) => RadioListTile<String>(
                  title: Text(r),
                  value: r,
                  groupValue: _selectedReason,
                  onChanged: (v) => setState(() => _selectedReason = v),
                )),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _selectedReason == null || _isSubmitting
                  ? null
                  : _submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
