import 'package:flutter/material.dart';

import '../../widgets/dtune_logo.dart';
import '../home/home_screen.dart';
import 'subsonic_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final SubsonicAuthService _authService;
  bool _rememberMe = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _serverController.text = SubsonicAuthService.defaultBaseUrlString;
    _authService = SubsonicAuthService();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final serverUrl = _serverController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final uri = _parseServerUrl(serverUrl);
      await _authService.authenticate(
        baseUrl: uri,
        username: username,
        password: password,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } on SubsonicAuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } on Object {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Uri _parseServerUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const SubsonicAuthException(
        'Please enter your Navidrome server URL.',
      );
    }

    final normalizedInput =
        trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;

    const requiredBase = SubsonicAuthService.defaultBaseUrlString;

    if (normalizedInput != requiredBase) {
      throw const SubsonicAuthException(
        'This app is configured for http://4.180.15.163:4533. '
        'Please use the bundled server URL.',
      );
    }

    return SubsonicAuthService.defaultBaseUri;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DTuneLogo(),
                  const SizedBox(height: 32),
                  Text(
                    'Sign in to your Navidrome server',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _serverController,
                          decoration: const InputDecoration(
                            labelText: 'Server URL',
                            hintText: 'http://4.180.15.163:4533',
                            prefixIcon: Icon(Icons.dns),
                          ),
                          keyboardType: TextInputType.url,
                          autofillHints: const [AutofillHints.url],
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Navidrome server URL';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                          autofillHints: const [AutofillHints.username],
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: _isSubmitting
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                            ),
                            const Text('Remember me'),
                            const Spacer(),
                            TextButton(
                              onPressed: _isSubmitting ? null : () {},
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _onSubmit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isSubmitting) ...[
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ] else ...[
                                    const Icon(Icons.login),
                                  ],
                                  const SizedBox(width: 12),
                                  Text(_isSubmitting ? 'Signing in...' : 'Continue'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
