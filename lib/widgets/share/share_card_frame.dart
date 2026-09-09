import 'package:flutter/material.dart';

// The fixed logical size every share card is built at. Matches Instagram's
// recommended 4:5 portrait ratio for feed posts, and looks fine letterboxed
// into a Story too. ShareService.captureBoundary renders this at 3x, so the
// exported PNG comes out at 1080x1350 — sharp at Instagram's display size.
const shareCardSize = Size(360, 450);

// Common chrome (background gradient + footer watermark) for every share
// card, so they read as one consistent, branded set regardless of which
// screen they were shared from. Deliberately uses fixed teal colors rather
// than Theme.of(context) — a shared image should look like a piece of
// branded content, not shift with the viewer's light/dark setting.
class ShareCardFrame extends StatelessWidget {
  final Widget child;

  const ShareCardFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: shareCardSize.width,
      height: shareCardSize.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
        ),
      ),
      child: Column(
        children: [
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  "Oh the Places I've Been",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
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
