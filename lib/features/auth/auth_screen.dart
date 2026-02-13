import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nebula_core/nebula_core.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _core = NebulaCore();
  bool _waitingForCode = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Basic validation logic
    final isPhoneValid = _phoneController.text.length >= 8;
    final isCodeValid = _codeController.text.length >= 4;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud, size: 80, color: Color(0xFF6366F1)),
                const SizedBox(height: 16),
                const Text(
                  'Nebula',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure Distributed Storage',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 48),
                if (!_waitingForCode) ...[
                  TextField(
                    controller: _phoneController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1234567890',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: (isPhoneValid && !_isLoading) ? _sendCode : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Send Code'),
                  ),
                ] else ...[
                  TextField(
                    controller: _codeController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: '1111',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed:
                        (isCodeValid && !_isLoading) ? _verifyCode : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Verify'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    try {
      final success = await _core.sendPhone(_phoneController.text);
      if (success) {
        setState(() => _waitingForCode = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to send code. Please try again.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    setState(() => _isLoading = true);
    try {
      final success = await _core.checkCode(_codeController.text);
      if (success) {
        if (mounted) {
          // Navigate only on success
          context.go('/setup-password');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid code.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
