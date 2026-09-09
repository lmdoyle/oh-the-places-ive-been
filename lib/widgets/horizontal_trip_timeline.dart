import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';

// A compact, scrollable "when did I go where" strip for the profile screen
// — city name only (no state/country) so it stays skimmable, ordered
// oldest-to-newest left to right like a normal timeline. Opens scrolled to
// the most recent trip (the right end) rather than the earliest.
class HorizontalTripTimeline extends StatefulWidget {
  final List<Visit> visits;
  final void Function(Visit visit) onTap;
  final void Function(int year)? onYearTap;

  const HorizontalTripTimeline({
    super.key,
    required this.visits,
    required this.onTap,
    this.onYearTap,
  });

  @override
  State<HorizontalTripTimeline> createState() => _HorizontalTripTimelineState();
}

class _HorizontalTripTimelineState extends State<HorizontalTripTimeline> {
  final _controller = ScrollController();
  bool _hasJumpedToEnd = false;

  // The visits list starts out empty (the Firestore stream hasn't emitted
  // yet), so build() returns a SizedBox with no ListView/controller
  // attached — scheduling this only once in initState would frequently
  // fire before the ListView ever existed, and never fire again once real
  // data arrived. Calling this from every build (it's a no-op once
  // _hasJumpedToEnd is set) means whichever build first actually attaches
  // the controller is the one that performs the jump.
  void _jumpToEndOnceReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasJumpedToEnd && _controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
        _hasJumpedToEnd = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dated = widget.visits.where((v) => v.visitedFrom != null).toList()
      ..sort((a, b) => a.visitedFrom!.compareTo(b.visitedFrom!));

    if (dated.isEmpty) return const SizedBox.shrink();

    _jumpToEndOnceReady();

    return SizedBox(
      height: 106,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: dated.length,
        itemBuilder: (context, i) {
          final visit = dated[i];
          final isNewYear =
              i == 0 ||
              dated[i - 1].visitedFrom!.year != visit.visitedFrom!.year;
          return _TimelineStop(
            visit: visit,
            isFirst: i == 0,
            isLast: i == dated.length - 1,
            showYear: isNewYear,
            onTap: () => widget.onTap(visit),
            onYearTap: widget.onYearTap == null
                ? null
                : () => widget.onYearTap!(visit.visitedFrom!.year),
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
  final bool showYear;
  final VoidCallback onTap;
  final VoidCallback? onYearTap;

  const _TimelineStop({
    required this.visit,
    required this.isFirst,
    required this.isLast,
    required this.showYear,
    required this.onTap,
    required this.onYearTap,
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
            // Only the first stop of each year gets a year label, so a
            // multi-year timeline stays legible without repeating it on
            // every single stop. Tapping it (separately from the stop
            // itself) shares a recap card for that year.
            SizedBox(
              height: 14,
              child: showYear
                  ? GestureDetector(
                      onTap: onYearTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat.y().format(visit.visitedFrom!),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (onYearTap != null) ...[
                            const SizedBox(width: 2),
                            Icon(
                              Icons.ios_share,
                              size: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    )
                  : null,
            ),
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
