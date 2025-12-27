import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;
  final double vibeScore;

  const WebViewPage({
    super.key,
    required this.url,
    required this.title,
    required this.vibeScore,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error silently or show snackbar
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = ExpressiveTheme.getScaffoldBg(widget.vibeScore);
    final primaryText = ExpressiveTheme.getPrimaryText(widget.vibeScore);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        foregroundColor: primaryText,
        elevation: 0,
        title: Text(
          widget.title.toUpperCase(),
          style: GoogleFonts.teko(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: primaryText,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: primaryText, height: 2),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            LinearProgressIndicator(
              color: primaryText,
              backgroundColor: scaffoldBg,
            ),
        ],
      ),
    );
  }
}
