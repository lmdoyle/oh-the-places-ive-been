import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';

// A compact, scrollable "when did I go where" strip for the top of the
// Feed — city name only (no state/country) so it stays skimmable, ordered
// oldest-to-newest left to right like a normal timeline.
class HorizontalTripTimeline extends StatelessWidget {
  final List<Visit> visits;
  final void Function(Visit visit) onTap;

  const HorizontalTripTimeline({
    super.key,
    required this.visits,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dated = visits.where((v) => v.visitedFrom != null).toList()
      ..sort((a, b) => a.visitedFrom!.compareTo(b.visitedFrom!));

    if (dated.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: dated.length,
        itemBuilder: (context, i) {
          final visit = dated[i];
          return _TimelineStop(
            visit: visit,
            isFirst: i == 0,
            isLast: i == dated.length - 1,
            onTap: () => onTap(visit),
          );
        },
      ),
    );
  }
}

class _TimelineStop extends StatelessWidget {
  final Visit visit;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _TimelineStop({
    required this.visit,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.outlineVariant;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat.MMMd().format(visit.visitedFrom!),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    color: isFirst ? Colors.transparent : lineColor,
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              visit.placeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
