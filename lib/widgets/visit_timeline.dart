import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';
import 'visit_card.dart';

// Groups visits by year and connects them with a vertical line, so it
// reads as "when did I go where" rather than a flat list. Sorted by the
// actual trip date (visitedFrom), not when the entry was logged — those
// can be very different if someone backfills an old trip.
class VisitTimeline extends StatelessWidget {
  final List<Visit> visits;
  final void Function(Visit visit) onTap;
  final bool showAuthor;

  const VisitTimeline({
    super.key,
    required this.visits,
    required this.onTap,
    this.showAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final dated = visits.where((v) => v.visitedFrom != null).toList()
      ..sort((a, b) => b.visitedFrom!.compareTo(a.visitedFrom!));
    final undated = visits.where((v) => v.visitedFrom == null).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final groups = <String, List<Visit>>{};
    for (final visit in dated) {
      groups.putIfAbsent('${visit.visitedFrom!.year}', () => []).add(visit);
    }
    // No-date trips are real entries too, so they still need a home in the
    // timeline — grouped at the end rather than mixed in chronologically
    // with dated ones, or silently dropped.
    if (undated.isNotEmpty) groups['No date'] = undated;

    final years = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: years.length,
      itemBuilder: (context, yearIndex) {
        final year = years[yearIndex];
        final yearVisits = groups[year]!;
        final isLastGroup = yearIndex == years.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                year,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...List.generate(yearVisits.length, (i) {
              final visit = yearVisits[i];
              final isLastInGroup = i == yearVisits.length - 1;
              return _TimelineRow(
                visit: visit,
                showAuthor: showAuthor,
                showLineBelow: !(isLastInGroup && isLastGroup),
                onTap: () => onTap(visit),
              );
            }),
          ],
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final Visit visit;
  final bool showAuthor;
  final bool showLineBelow;
  final VoidCallback onTap;

  const _TimelineRow({
    required this.visit,
    required this.showAuthor,
    required this.showLineBelow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = visit.visitedFrom != null
        ? DateFormat.MMMd().format(visit.visitedFrom!)
        : '—';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                dateLabel,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (showLineBelow)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: VisitCard(
              visit: visit,
              showAuthor: showAuthor,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
