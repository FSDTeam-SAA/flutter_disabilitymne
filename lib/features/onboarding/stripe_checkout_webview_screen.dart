import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Stripe Checkout in a WebView. Detects success/cancel redirects and calls confirm API.
class StripeCheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String planName;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const StripeCheckoutWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.planName,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<StripeCheckoutWebViewScreen> createState() =>
      _StripeCheckoutWebViewScreenState();
}

class _StripeCheckoutWebViewScreenState
    extends State<StripeCheckoutWebViewScreen> {
  late final WebViewController _controller;
  bool _isConfirming = false;

  static bool _isSuccessUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.contains('checkout/success') ||
        lower.contains('payments/checkout/success');
  }

  static bool _isCancelUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.contains('checkout/cancel') ||
        lower.contains('payments/checkout/cancel');
  }

  static String? _extractSessionId(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['session_id'];
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleSuccess(String url) async {
    if (_isConfirming) return;
    final sessionId = _extractSessionId(url);
    if (sessionId == null || sessionId.isEmpty) {
      widget.onSuccess();
      return;
    }
    _isConfirming = true;
    final repo = Get.find<PaymentPlansInterface>();
    final result = await repo.confirmCheckout(sessionId);
    _isConfirming = false;
    if (!mounted) return;
    result.fold(
      (failure) {
        Get.snackbar('Error', failure.uiMessage);
        widget.onSuccess();
      },
      (_) => widget.onSuccess(),
    );
  }

  void _onUrlChange(UrlChange change) {
    final url = change.url;
    if (_isSuccessUrl(url)) {
      _handleSuccess(url ?? '');
      return;
    }
    if (_isCancelUrl(url)) {
      widget.onCancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: _onUrlChange,
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete payment',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[800]),
          onPressed: () => widget.onCancel(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isConfirming)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
