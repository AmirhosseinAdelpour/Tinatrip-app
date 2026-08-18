import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../theme/app_build_context.dart';
import '../widgets/gradient_button.dart';
import '../widgets/field_label.dart';
import '../widgets/app_background.dart';

class ReserveFormScreen extends StatefulWidget {
  const ReserveFormScreen({super.key});

  @override
  State<ReserveFormScreen> createState() => _ReserveFormScreenState();
}

class _ReserveFormScreenState extends State<ReserveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _sending = false;

  static final _phoneRegExp = RegExp(r'^(09\d{9}|\+989\d{9})$');

  @override
  void dispose() {
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    final uri = Uri.parse('https://tinatrip.com/contactRequest/').replace(
      queryParameters: {
        'saleCounter': 'نرم افزار',
        'destination': _cityController.text.trim(),
        'phone': _phoneController.text.trim(),
        'type': 'normal',
      },
    );

    String message;
    bool ok;
    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(response.body);
      final status = body is Map ? body['status'] : null;
      ok = response.statusCode == 200 && status == 'success';
      if (ok) {
        message = 'درخواست شما ثبت شد؛ کارشناسان ما به‌زودی با شما تماس می‌گیرند.';
      } else {
        message = (body is Map && body['message'] is String)
            ? body['message'] as String
            : 'ثبت درخواست ممکن نشد (کد خطا: ${response.statusCode}). لطفاً دوباره تلاش کنید.';
      }
    } on TimeoutException {
      ok = false;
      message = 'ارسال درخواست بیش از حد انتظار طول کشید؛ اتصال اینترنت را بررسی کنید.';
    } on http.ClientException {
      ok = false;
      message = 'ارتباط با سرور برقرار نشد؛ اتصال اینترنت را بررسی کنید.';
    } on FormatException {
      ok = false;
      message = 'پاسخ سرور قابل خواندن نبود؛ لطفاً بعداً دوباره تلاش کنید.';
    } catch (_) {
      ok = false;
      message = 'خطای غیرمنتظره‌ای رخ داد؛ لطفاً دوباره تلاش کنید.';
    }

    if (!mounted) return;
    setState(() => _sending = false);

    final colors = context.appColors;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('درخواست شما ثبت شد؛ کارشناسان ما به‌زودی با شما تماس می‌گیرند.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.surfaceElevated,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('گشت')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.surface, colors.background],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.primary.withAlpha(51),
                          ),
                        ),
                        child: Text(
                          'برای گشت، شهر مقصد و شماره تماس‌تان را بفرستید؛ کارشناسان ما با شما تماس می‌گیرند.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.onBackground,
                            height: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const FieldLabel('شهر مقصد'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cityController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'شهر مقصد را بنویسید.';
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'مثلاً مشهد، استانبول یا کیش',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const FieldLabel('شماره تماس'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          letterSpacing: 1,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'شماره تماس را وارد کنید.';
                          if (!_phoneRegExp.hasMatch(v)) {
                            return 'شماره موبایل معتبر نیست (مثلاً 09123456789 یا +989123456789).';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'مثلاً 09123456789',
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sending
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : GradientButton(
                              label: 'ارسال درخواست',
                              icon: Icons.send,
                              onTap: _submit,
                            ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
