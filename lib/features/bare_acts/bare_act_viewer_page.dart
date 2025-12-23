import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'models/bare_act.dart';
import '../../services/ad_service.dart';

class BareActViewerPage extends StatefulWidget {
  final BareAct bareAct;

  const BareActViewerPage({super.key, required this.bareAct});

  @override
  State<BareActViewerPage> createState() => _BareActViewerPageState();
}

class _BareActViewerPageState extends State<BareActViewerPage> {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    setState(() {
      _isAdLoading = true;
    });

    RewardedAd.load(
      adUnitId: AdService.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Ad loaded.');
          setState(() {
            _rewardedAd = ad;
            _isAdLoading = false;
          });
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd(); // Reload for next time
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _startDownload(context); // Fallback to download if ad fails
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Ad failed to load: $error');
          setState(() {
            _rewardedAd = null;
            _isAdLoading = false;
          });
        },
      ),
    );
  }

  void _handleDownloadPress(BuildContext context) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          // User watched the ad, proceed to download
          _startDownload(context);
        },
      );
    } else {
      // Ad not ready or failed to load, proceed to download anyway
      _startDownload(context);
      // Attempt to load again if it failed previously
      if (!_isAdLoading) _loadRewardedAd();
    }
  }

  Future<void> _startDownload(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF02F1C3)),
        ),
      );

      // Check Permissions
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }

      // Download
      final response = await http.get(Uri.parse(widget.bareAct.pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Download failed: ${response.statusCode}');
      }

      // Determine path
      Directory? directory;
      if (Platform.isAndroid) {
        // Try public Download folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final safeTitle =
            widget.bareAct.title.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
        // Ensure LawGenie folder exists
        final safeDir = Directory('${directory.path}/LawGenie');
        if (!await safeDir.exists()) {
          await safeDir.create(recursive: true).catchError(
              (e) => directory!); // Fallback to root if create fails
        }

        final saveDiv = await safeDir.exists() ? safeDir : directory;

        final String filePath = '${saveDiv.path}/$safeTitle.pdf';
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded to: $filePath'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () => OpenFile.open(filePath),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1832),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bareAct.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.bareAct.category} • ${widget.bareAct.year}',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.orange),
            onPressed: () => _handleDownloadPress(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: const PDF().fromUrl(
        widget.bareAct.pdfUrl,
        placeholder: (progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: progress / 100,
                color: const Color(0xFF02F1C3),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading PDF... $progress%',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load PDF',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _handleDownloadPress(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in Browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02F1C3),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
