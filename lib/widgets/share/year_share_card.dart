import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/travel_stats_data.dart';
import '../../models/visit.dart';
import 'share_card_frame.dart';

class YearShareCard extends StatelessWidget {
  final int year;
  final List<Visit> visitsInYear;

  const YearShareCard({
    super.key,
    required this.year,
    required this.visitsInYear,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...visitsInYear]
      ..sort((a, b) => a.visitedFrom!.compareTo(b.visitedFrom!));
    final stats = TravelStatsData.compute(visitsInYear);

    return ShareCardFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$year',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            Text(
              'Year in travel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniStat(value: '${stats.countries}', label: 'Countries'),
                _MiniStat(value: '${stats.continents}', label: 'Continents'),
                _MiniStat(value: '${sorted.length}', label: 'Trips'),
              ],
            ),
            const SizedBox(height: 10),
            // The card is a fixed size, so a busy year needs an explicit cap
            // rather than trusting everything to fit — otherwise the last
            // trip or two just silently gets clipped off the bottom with no
            // sign anything's missing. Kept well under what could plausibly
            // fit, since exact text metrics can shift slightly by platform.
            Expanded(
              child: Builder(
                builder: (context) {
                  const maxVisible = 7;
                  final visible = sorted.take(maxVisible).toList();
                  final hiddenCount = sorted.length - visible.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final visit in visible)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Text(
                                  DateFormat.MMMd().format(visit.visitedFrom!),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${visit.placeName}, ${visit.country}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hiddenCount > 0)
                        Text(
                          '+$hiddenCount more',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
