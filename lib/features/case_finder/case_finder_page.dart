import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
            setState(() {
              _isReady = false;
              _isLoading = true;
            });
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

            // 1. Inject CSS immediately for instant theming (FOUC prevention)
            _controller.runJavaScript('''
              (function() {
                var style = document.createElement('style');
                style.innerHTML = `
                  html, body {
                    background-color: #0A032A !important;
                    color: white !important;
                    background-image: none !important;
                  }
                  /* Hide branding elements immediately */
                  header, footer, nav, .navbar, .top-bar, #header, #footer,
                  .header-top, .accessibility, .lang-dropdown, .logo,
                  .breadcrumb, .page-header, #top-bar, .top-header {
                    display: none !important;
                  }
                  /* Force dark theme on containers */
                  .card, .result, .list-group-item, .table, tr, td, .row, .container, 
                  .form-control, input, select, .modal-content, .card-body {
                    background-color: #151038 !important;
                    color: white !important;
                    border-color: #2C55A9 !important;
                  }
                  /* Text colors */
                  div, p, span, h1, h2, h3, h4, h5, h6, li, td, th, label, strong, b {
                    color: white !important;
                  }
                  /* Links */
                  a {
                    color: #02F1C3 !important;
                    text-decoration: none !important;
                  }
                  /* Buttons */
                  button, input[type="submit"], .btn {
                    background-color: #02F1C3 !important;
                    color: #0A032A !important;
                    border: none !important;
                    border-radius: 12px !important;
                  }
                  /* Inputs */
                  input, select, textarea {
                    background-color: #1A1832 !important;
                    color: white !important;
                    border: 1px solid #02F1C3 !important;
                    border-radius: 12px !important;
                  }
                  /* Highlighted text */
                  span[style*="background-color: yellow"], mark {
                    background-color: #FFD700 !important;
                    color: black !important;
                  }
                  /* Hide images by default (JS will unhide captcha) */
                  img:not([id*="captcha"]):not([src*="captcha"]) {
                    display: none !important;
                  }
                `;
                document.head.appendChild(style);
              })();
            ''');

            // 2. Run JS for logic-based hiding (text content) and dynamic updates
            _controller.runJavaScript('''
              (function() {
                function hideSpecificElements() {
                  var tagsToCheck = ['div', 'p', 'span', 'a', 'section', 'h6', 'h5', 'label'];
                  tagsToCheck.forEach(tag => {
                    document.querySelectorAll(tag).forEach(el => {
                      if (el.style.display === 'none') return;
                      var text = el.innerText.trim();
                      if (text.includes('Skip to navigation') || 
                          text.includes('Skip to main content') ||
                          text.includes('eSCR,Judgements') || 
                          text.includes('Indian Judiciary') ||
                          text.includes('Version:') ||
                          text.includes('Supreme Court of India') ||
                          text.includes('©')) {
                        if (el.tagName !== 'BODY' && el.id !== 'main-content') {
                          el.style.display = 'none';
                        }
                      }
                    });
                  });
                }

                // Run immediately
                hideSpecificElements();

                // Watch for mutations to re-apply text hiding
                var observer = new MutationObserver(function(mutations) {
                  hideSpecificElements();
                });
                observer.observe(document.body, { childList: true, subtree: true });

                // 3. Attach listener to Search/Submit buttons for immediate hiding
                document.querySelectorAll('button, input[type="submit"], .btn').forEach(btn => {
                  btn.addEventListener('click', function() {
                    // Check if it's likely a search/submit action
                    if (this.type === 'submit' || this.innerText.toLowerCase().includes('search') || this.innerText.toLowerCase().includes('submit')) {
                       AppChannel.postMessage('hide');
                    }
                  });
                });
                
                // Also listen for form submissions directly
                document.querySelectorAll('form').forEach(form => {
                  form.addEventListener('submit', function() {
                    AppChannel.postMessage('hide');
                  });
                });

              })();
            ''');

            // Add a delay to ensure CSS is applied before showing the view
            Future.delayed(const Duration(milliseconds: 1000), () {
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
        title: Text(
          'Case Finder',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
