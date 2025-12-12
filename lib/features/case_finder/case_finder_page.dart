import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/ad_service.dart';
import '../../features/home/providers/usage_provider.dart';
import '../../utils/usage_limit_helper.dart';

class CaseFinderPage extends StatefulWidget {
  const CaseFinderPage({super.key});

  @override
  State<CaseFinderPage> createState() => _CaseFinderPageState();
}

class _CaseFinderPageState extends State<CaseFinderPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isReady = false;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A032A))
      ..addJavaScriptChannel(
        'AppChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'hide') {
            _handleSearchAction();
          } else if (message.message == 'captcha_error') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Invalid Captcha or Code used. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
            if (mounted) {
              setState(() {
                _isLoading = false;
                _isReady = true;
              });
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _isReady = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _controller.runJavaScript('''
              (function() {
                var style = document.createElement('style');
                style.innerHTML = `
                  html, body {
                    background-color: #0A032A !important;
                    color: white !important;
                    background-image: none !important;
                    font-family: 'Poppins', sans-serif !important;
                    overflow-x: hidden !important; 
                  }
                  .accessibility, .accessibility-box, .accessibility-toolbar,
                  #accessibility, #accessibility-box, #accessibility-toolbar,
                  .skip-to-content, .skip-to-main-content, .skip-link, 
                  #skip-to-main, #skip-content,
                  .font-resize, .text-resize, .font-switcher, .font-size-control,
                  .lang-dropdown, .language-select, #language,
                  header, footer, nav, .navbar, .top-bar, .header-top, .top-strip,
                  .container-fluid.bg-white, .bg-light,
                  .row.top-row, .d-flex.justify-content-end,
                  [aria-label*="Skip"], [title*="Skip"],
                  img:not([id*="captcha"]):not([src*="captcha"]),
                  .header-bg, .footer-bg, a[href*="gov.in"],
                  .text-center.text-white, div[style*="background"]
                  {
                    display: none !important;
                    opacity: 0 !important;
                    height: 0 !important;
                    width: 0 !important;
                    overflow: hidden !important;
                    position: absolute !important;
                    top: -9999px !important;
                  }
                  table {
                    width: 100% !important;
                    border-collapse: separate !important;
                    border-spacing: 0 16px !important; 
                    background: transparent !important;
                  }
                  thead, tfoot {
                    display: none !important; 
                  }
                  tr {
                    display: block !important;
                    background: #151038 !important;
                    border: 1px solid #2C55A9 !important;
                    border-radius: 16px !important;
                    padding: 2px !important; 
                    box-shadow: 0 4px 20px rgba(0,0,0,0.4) !important;
                    margin-bottom: 24px !important;
                    position: relative !important;
                  }
                  td {
                    display: block !important;
                    border: none !important;
                    padding: 12px 16px !important;
                    text-align: left !important;
                    color: #E0E0E0 !important;
                    font-size: 15px !important;
                    line-height: 1.6 !important;
                  }
                  td:first-child {
                    padding-top: 16px !important;
                    padding-bottom: 8px !important;
                  }
                  a {
                    color: #0A032A !important;
                    font-weight: 700 !important;
                    text-decoration: none !important;
                    font-size: 16px !important;
                    display: block !important; 
                    padding: 14px 20px !important;
                    background: #02F1C3 !important;
                    border-radius: 12px !important;
                    text-align: center !important;
                    margin-top: 12px !important;
                    box-shadow: 0 4px 10px rgba(2, 241, 195, 0.2) !important;
                    transition: transform 0.2s !important;
                  }
                  a:active {
                    transform: scale(0.98) !important;
                  }
                  span[style*="background-color:yellow"], 
                  span[style*="background-color: yellow"] {
                     background-color: rgba(255, 215, 0, 0.3) !important;
                     color: #FFD700 !important;
                     border-radius: 4px !important;
                     padding: 0 4px !important;
                     font-weight: bold !important;
                  }
                  input[type="text"], select, textarea {
                    background-color: #1A1832 !important;
                    color: white !important;
                    border: 1px solid #42218E !important;
                    border-radius: 12px !important;
                    padding: 14px !important;
                    margin-bottom: 16px !important;
                    font-size: 16px !important;
                  }
                  button, input[type="submit"], input[type="button"], .btn {
                    background: linear-gradient(135deg, #02F1C3, #02d1a8) !important;
                    color: #0A032A !important;
                    font-weight: bold !important;
                    border: none !important;
                    border-radius: 12px !important;
                    padding: 14px 0 !important;
                    box-shadow: 0 4px 12px rgba(2, 241, 195, 0.3) !important;
                    cursor: pointer !important;
                    width: 100% !important;
                    font-size: 16px !important;
                    margin-top: 10px !important;
                  }
                  .dataTables_paginate {
                    margin-top: 20px !important;
                    text-align: center !important;
                  }
                `;
                document.head.appendChild(style);
              })();
            ''');
            _controller.runJavaScript('''
              (function() {
                function cleanUI() {
                  var walker = document.createTreeWalker(
                      document.body, 
                      NodeFilter.SHOW_ELEMENT, 
                      null, 
                      false
                  );
                  var node;
                  while(node = walker.nextNode()) {
                      var txt = node.innerText ? node.innerText.toLowerCase().trim() : "";
                      if (!txt) continue;
                      if (txt.includes('skip to navigation') || 
                          txt.includes('skip to main') ||
                          txt === 'a-' || txt === 'a' || txt === 'a+' ||
                          txt === 'screen reader access') {
                          node.style.display = 'none';
                          if (node.parentElement && node.parentElement.offsetHeight < 60) {
                              node.parentElement.style.display = 'none';
                              if (node.parentElement.parentElement && node.parentElement.parentElement.offsetHeight < 60) {
                                  node.parentElement.parentElement.style.display = 'none';
                              }
                          }
                      }
                  }
                }
                cleanUI();
                var observer = new MutationObserver(function(mutations) {
                  cleanUI();
                  checkCaptchaErrors();
                });
                observer.observe(document.body, { childList: true, subtree: true });
                function checkCaptchaErrors() {
                   var bodyText = document.body.innerText;
                   if (bodyText.includes('Invalid Captcha') || 
                       bodyText.includes('Captcha code does not match') || 
                       bodyText.includes('Enter correct captcha')) {
                       if (!window.captchaErrorShown) {
                           AppChannel.postMessage('captcha_error');
                           window.captchaErrorShown = true;
                           setTimeout(() => { window.captchaErrorShown = false; }, 3000);
                       }
                   }
                }
              })();
            ''');
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  _isReady = true;
                });
              }
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://judgments.ecourts.gov.in/pdfsearch/index.php'));
  }

  Future<void> _handleSearchAction() async {
    // Check if user can use the feature
    final canProceed = await UsageLimitHelper.checkAndShowLimit(
      context,
      'caseFinder',
      customTitle: 'Case Finder Limit Reached',
    );

    if (canProceed) {
      setState(() {
        _isReady = false;
        _isLoading = true;
      });

      final usageProvider = Provider.of<UsageProvider>(context, listen: false);
      await usageProvider.incrementCaseFinder();

      // Show usage info
      UsageLimitHelper.showUsageSnackbar(
        context,
        'Case Finder',
        usageProvider.dailyCaseFinderUsage,
        usageProvider.dailyCaseFinderLimit,
      );
    } else {
      // User hit limit, reload the page
      _controller.reload();
    }
  }

  void _showAdDialog(UsageProvider usageProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF19173A),
        title: Text('Daily Limit Reached',
            style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'You have reached your search limit. Watch a short ad to get an extra search?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.reload();
            },
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAd(usageProvider);
            },
            child: Text('Watch Ad',
                style: GoogleFonts.poppins(color: const Color(0xFF02F1C3))),
          ),
        ],
      ),
    );
  }

  void _showAd(UsageProvider usageProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    AdService.showRewardedAd(
      onUserEarnedReward: () {
        Navigator.pop(context); // Close loading

        // Grant usage logic?
        // UsageProvider doesn't have a "grant extra" method, it respects the limit.
        // If limit is hardcoded, we can't easily "grant one more".
        // BUT, UsageProvider increments usage. If usage >= limit, it stops.

        // OPTION: We can't really "lower" usage, but we could "bypass" the check temporarily?
        // OR: We create a specialized method in UsageProvider later.
        // FOR NOW: We will assume we can just proceed as if counted, OR we need the provider to allow +1.

        // Hack: Just proceed without checking limit again, but verify counting still happens?
        // Actually, if usage >= limit, incrementCaseFinder() won't increment.
        // So the count stays at limit.

        setState(() {
          _isReady = false;
          _isLoading = true;
        });

        // Since we watched an ad, we essentially proceed.
        // Note: The usage count won't go up if it's hit limit, which is fine.
        // It just stays at max.
      },
      onAdFailedToLoad: () {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ad. Please try again.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usageProvider = Provider.of<UsageProvider>(context);
    final dailyRemaining =
        usageProvider.dailyCaseFinderLimit - usageProvider.dailyCaseFinderUsage;
    final monthlyRemaining =
        usageProvider.caseFinderLimit - usageProvider.caseFinderUsage;

    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A032A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Case Finder',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              '${dailyRemaining > 0 ? dailyRemaining : 0} searches left today • ${monthlyRemaining > 0 ? monthlyRemaining : 0} this month',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                size: 20, color: Colors.white),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                await _controller.goForward();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Visibility(
            visible: _isReady,
            maintainState: true,
            child: WebViewWidget(controller: _controller),
          ),
          if (!_isReady)
            Container(
              color: const Color(0xFF0A032A),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF02F1C3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Case Finder...',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading &&
              _isReady) // Show progress bar only if visible and loading subsequent pages
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: Colors.transparent,
              color: const Color(0xFF02F1C3),
            ),
        ],
      ),
    );
  }
}
