import 'package:flutter/material.dart';
import '../../services/share_service.dart';

// Generic preview + share flow reused by all three share-card types (trip,
// year, profile) — precaches any network images the card needs (so the
// capture doesn't grab a blank placeholder), then renders the card into an
// off-screen-sized RepaintBoundary that gets captured to a PNG on Share.
class ShareCardPreviewScreen extends StatefulWidget {
  final Widget card;
  final String fileName;
  final List<String> imageUrlsToPreload;
  final String? shareText;

  const ShareCardPreviewScreen({
    super.key,
    required this.card,
    required this.fileName,
    this.imageUrlsToPreload = const [],
    this.shareText,
  });

  @override
  State<ShareCardPreviewScreen> createState() => _ShareCardPreviewScreenState();
}

class _ShareCardPreviewScreenState extends State<ShareCardPreviewScreen> {
  final _boundaryKey = GlobalKey();
  bool _isReady = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _preload();
  }

  Future<void> _preload() async {
    // In parallel — some cards (the profile mosaic) preload up to two
    // dozen photos, and loading those one at a time would make Share sit
    // behind a long wait for no reason.
    await Future.wait(
      widget.imageUrlsToPreload.map((url) async {
        try {
          await precacheImage(NetworkImage(url), context);
        } catch (_) {
          // A broken or slow-loading photo shouldn't block sharing the
          // rest of the card — it'll just render as whatever placeholder
          // the image widget shows on error.
        }
      }),
    );
    if (mounted) setState(() => _isReady = true);
  }

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      final bytes = await ShareService.captureBoundary(_boundaryKey);
      if (!mounted) return;
      await ShareService.shareImage(
        bytes,
        fileName: widget.fileName,
        text: widget.shareText,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share')),
      body: Center(
        child: !_isReady
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: widget.card,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSharing ? null : _share,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.ios_share),
                      label: Text(_isSharing ? 'Preparing…' : 'Share'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
