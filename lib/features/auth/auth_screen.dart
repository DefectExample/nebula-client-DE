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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+1234567890',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _sendCode,
                  child: const Text('Send Code'),
                ),
              ] else ...[
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    hintText: '1111',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _verifyCode,
                  child: const Text('Verify'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    await _core.sendPhone(_phoneController.text);
    setState(() => _waitingForCode = true);
  }

  Future<void> _verifyCode() async {
    await _core.checkCode(_codeController.text);
    if (mounted) {
      context.go('/vault-unlock');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
