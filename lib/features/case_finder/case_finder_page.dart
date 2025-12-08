import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ad_service.dart';
import '../shared/pdf_viewer_page.dart';

class CaseFinderPage extends StatefulWidget {
  const CaseFinderPage({super.key});

  @override
  State<CaseFinderPage> createState() => _CaseFinderPageState();
}

class _CaseFinderPageState extends State<CaseFinderPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isReady = false; // New state to track if custom CSS is applied
  int _loadingProgress = 0;
  int _dailySearches = 0;
  static const int _freeLimit = 5;

  @override
  void initState() {
    super.initState();
    _loadDailySearches();
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
            // Also reset loading state since they need to retry
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
              _isReady = false; // Hide view immediately on navigation
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // 1. Inject CSS for Premium Card UI - REFINED
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
                  
                  /* FORCE HIDE all accessibility/header junk */
                  /* Common Accessibility Classes/IDs */
                  .accessibility, .accessibility-box, .accessibility-toolbar,
                  #accessibility, #accessibility-box, #accessibility-toolbar,
                  .skip-to-content, .skip-to-main-content, .skip-link, 
                  #skip-to-main, #skip-content,
                  .font-resize, .text-resize, .font-switcher, .font-size-control,
                  .lang-dropdown, .language-select, #language,
                  
                  /* Bootstrap/Common Header Containers */
                  header, footer, nav, .navbar, .top-bar, .header-top, .top-strip,
                  .container-fluid.bg-white, .bg-light,
                  .row.top-row, .d-flex.justify-content-end,
                  
                  /* Elements containing specific text (handled by JS, but css backup) */
                  [aria-label*="Skip"], [title*="Skip"],
                  
                  /* Images/Logos */
                  img:not([id*="captcha"]):not([src*="captcha"]),
                  
                  /* Government Branding */
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

                  /* Card-like styling for Table Rows (Results) */
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
                    padding: 2px !important; /* Minimal padding on wrapper */
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

                  /* Make the first cell (often the link) look like a header */
                  td:first-child {
                    padding-top: 16px !important;
                    padding-bottom: 8px !important;
                  }

                  /* Highlight links (Case Titles/PDFs) */
                  a {
                    color: #0A032A !important;
                    font-weight: 700 !important;
                    text-decoration: none !important;
                    font-size: 16px !important;
                    display: block !important; /* Full width button */
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
                  
                  /* Highlight keyword matches */
                  span[style*="background-color:yellow"], 
                  span[style*="background-color: yellow"] {
                     background-color: rgba(255, 215, 0, 0.3) !important;
                     color: #FFD700 !important;
                     border-radius: 4px !important;
                     padding: 0 4px !important;
                     font-weight: bold !important;
                  }

                   /* Form Styling */
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

                  /* Custom Paging */
                  .dataTables_paginate {
                    margin-top: 20px !important;
                    text-align: center !important;
                  }
                `;
                document.head.appendChild(style);
              })();
            ''');

            // 2. Run JS for purely logic-based hiding (accessibility text check)
            _controller.runJavaScript('''
              (function() {
                
                function cleanUI() {
                  // 1. Text-based filtering for "Skip to..." buttons
                  var walker = document.createTreeWalker(
                      document.body, 
                      NodeFilter.SHOW_ELEMENT, 
                      null, 
                      false
                  );

                  var node;
                  while(node = walker.nextNode()) {
                      // Check for accessibility text
                      var txt = node.innerText ? node.innerText.toLowerCase().trim() : "";
                      if (!txt) continue;

                      if (txt.includes('skip to navigation') || 
                          txt.includes('skip to main') ||
                          txt === 'a-' || txt === 'a' || txt === 'a+' ||
                          txt === 'screen reader access') {
                          
                          // Hide this element
                          node.style.display = 'none';
                          
                          // Hide parent if it's a small container (likely a button wrapper)
                          if (node.parentElement && node.parentElement.offsetHeight < 60) {
                              node.parentElement.style.display = 'none';
                              // Go up one more level just in case (e.g. UL > LI > A)
                              if (node.parentElement.parentElement && node.parentElement.parentElement.offsetHeight < 60) {
                                  node.parentElement.parentElement.style.display = 'none';
                              }
                          }
                      }
                  }
                  
                  // 2. Hide any top-level divs that are NOT the main content area
                  // This is risky but often necessary for these gov sites
                  // We look for the main container (often has specific ID or class) or just hide first few large divs
                  // For now, let's stick to hiding known bad classes found in previous steps.
                }

                cleanUI();
                
                // Monitor for dynamic changes
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

            // Add a delay to ensure CSS is applied
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

  Future<void> _loadDailySearches() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString('last_search_date');

    if (lastDate != today) {
      await prefs.setString('last_search_date', today);
      await prefs.setInt('daily_searches', 0);
      setState(() => _dailySearches = 0);
    } else {
      setState(() => _dailySearches = prefs.getInt('daily_searches') ?? 0);
    }
  }

  Future<void> _incrementSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _dailySearches++);
    await prefs.setInt('daily_searches', _dailySearches);
  }

  void _handleSearchAction() {
    if (_dailySearches < _freeLimit) {
      setState(() {
        _isReady = false;
        _isLoading = true;
      });
      _incrementSearches();
    } else {
      // Limit reached, show ad dialog
      // We need to pause/hide the webview first
      setState(() => _isReady = false);
      _showAdDialog();
    }
  }

  void _showAdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF19173A),
        title: Text('Daily Limit Reached',
            style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'You have used your 5 free searches for today. Watch a short ad to get an extra search?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // If they cancel, we just show the webview again (or maybe reload to reset state?)
              // Reloading might be safer to prevent the search from continuing if it was already submitted
              _controller.reload();
            },
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAd();
            },
            child: Text('Watch Ad',
                style: GoogleFonts.poppins(color: const Color(0xFF02F1C3))),
          ),
        ],
      ),
    );
  }

  void _showAd() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    AdService.showRewardedAd(
      onUserEarnedReward: () {
        Navigator.pop(context); // Close loading
        _incrementSearches(); // Grant extra search
        setState(() {
          _isReady = false;
          _isLoading = true;
        });
        // We don't need to do anything else, the webview submitted the form already.
        // We just unhide it when it finishes loading the results.
        // Wait, if we hid it, the request might still be processing in background.
        // If we just set _isLoading = true, the onPageFinished will eventually fire and show it.
      },
      onAdFailedToLoad: () {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load ad. Granting search...')),
        );
        _incrementSearches();
        setState(() {
          _isReady = false;
          _isLoading = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              '${_freeLimit - _dailySearches > 0 ? _freeLimit - _dailySearches : 0} free searches left',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
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
