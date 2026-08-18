import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_build_context.dart';
import '../platform_actions.dart';
import '../webview_setup.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

enum _WebState { loading, ready, error }

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  _WebState _state = _WebState.loading;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    final colors = context.appColors;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(colors.background)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; SM-G991B) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _setState(_WebState.loading);
            _armTimeout();
          },
          onPageFinished: (_) {
            _timeout?.cancel();
            _setState(_WebState.ready);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              _timeout?.cancel();
              _setState(_WebState.error);
            }
          },
        ),
      );
    configureWebViewController(_controller).then((_) {
      _controller.loadRequest(Uri.parse(widget.url));
    });
    _armTimeout();
  }

  void _armTimeout() {
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 25), () {
      if (_state == _WebState.loading) {
        _setState(_WebState.error);
      }
    });
  }

  void _setState(_WebState s) {
    if (mounted) setState(() => _state = s);
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colors.surface,
        foregroundColor: colors.onBackground,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_state == _WebState.loading) const _WebLoadingView(),
          if (_state == _WebState.error)
            _WebErrorView(
              onRetry: () {
                _setState(_WebState.loading);
                _armTimeout();
                _controller.reload();
              },
              onBrowser: () => openExternalUrl(widget.url),
            ),
        ],
      ),
    );
  }
}

class _WebLoadingView extends StatelessWidget {
  const _WebLoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            'درحال برقراری ارتباط…',
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'لطفاً کمی صبر کنید',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.muted.withAlpha(178),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebErrorView extends StatelessWidget {
  const _WebErrorView({required this.onRetry, required this.onBrowser});

  final VoidCallback onRetry;
  final VoidCallback onBrowser;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 52, color: colors.error),
          const SizedBox(height: 20),
          Text(
            'برقراری ارتباط ممکن نشد',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('تلاش دوباره'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onBrowser,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('در مرورگر'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
