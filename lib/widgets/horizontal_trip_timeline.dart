import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';

// A compact, scrollable "when did I go where" strip for the profile screen
// — city name only (no state/country) so it stays skimmable, ordered
// oldest-to-newest left to right like a normal timeline, with the most
// recent trip called out.
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
      // A couple px taller than the content needs, so the highlighted
      // pill's extra padding around the most recent stop doesn't overflow.
      height: 98,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: dated.length,
        itemBuilder: (context, i) {
          final visit = dated[i];
          return _TimelineStop(
            visit: visit,
            isFirst: i == 0,
            // The rightmost stop is both the last one in the strip and,
            // since dated is sorted oldest-to-newest, the most recent trip
            // — so it doubles as the "current" highlight.
            isMostRecent: i == dated.length - 1,
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
  final bool isMostRecent;
  final VoidCallback onTap;

  const _TimelineStop({
    required this.visit,
    required this.isFirst,
    required this.isMostRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.outlineVariant;
    final highlightColor = theme.colorScheme.onPrimaryContainer;
    final dotSize = isMostRecent ? 14.0 : 10.0;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 96,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: isMostRecent
            ? const EdgeInsets.symmetric(vertical: 4)
            : EdgeInsets.zero,
        decoration: isMostRecent
            ? BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat.MMMd().format(visit.visitedFrom!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isMostRecent ? highlightColor : null,
                fontWeight: isMostRecent ? FontWeight.w600 : null,
              ),
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
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    border: isMostRecent
                        ? Border.all(
                            color: theme.colorScheme.primaryContainer,
                            width: 2,
                          )
                        : null,
                  ),
                ),
                // Always the rightmost stop, so there's never a line
                // continuing past it.
                const Expanded(child: SizedBox.shrink()),
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
                color: isMostRecent ? highlightColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
