import 'package:film_randomizer/notifiers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/ui/screens/home_page.dart';
import 'package:film_randomizer/ui/widgets/main_app_bar.dart';

class LoginRegisterPage extends ConsumerStatefulWidget {
  const LoginRegisterPage({super.key});
  static String routeName = "/login";

  @override
  ConsumerState<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends ConsumerState<LoginRegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loginMode = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final pageTitle = L10nAccessor.get(context, _loginMode ? "login_page" : "register_page");

    return Scaffold(
      appBar: MainAppBar(title: pageTitle),
      body: _buildLoginRegisterForm(),
    );
  }

  Widget _buildLoginRegisterForm() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  _buildUsernameField(),
                  const SizedBox(height: 8),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                _loginMode = !_loginMode;
              });
            },
            child: Text(
              L10nAccessor.get(context, _loginMode ? "goto_register" : "goto_login"),
              style: TextStyle(
                color: Theme.of(context).hintColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField _buildUsernameField() {
    return TextFormField(
      autofillHints: const [AutofillHints.username],
      decoration: InputDecoration(
        labelText: L10nAccessor.get(context, "username"),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hoverColor),
        ),
      ),
      controller: _usernameController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return L10nAccessor.get(context, "username_required");
        } else if (value.length < 4) {
          return L10nAccessor.get(context, "username_short");
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: L10nAccessor.get(context, "password"),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hoverColor),
        ),
      ),
      controller: _passwordController,
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return L10nAccessor.get(context, "password_required");
        } else if (value.length < 4) {
          return L10nAccessor.get(context, "password_short");
        }
        return null;
      },
    );
  }

  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          _handleSubmit();
        }
      },
      child: _isLoading
          ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
          : Text(L10nAccessor.get(context, _loginMode ? "login_action" : "register_action")),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    if (_loginMode) {
      await _handleLogin();
    } else {
      await _handleRegister();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    // Instead of Provider.of<AuthProvider>(context, listen: false),
    // we use Riverpod's ref.read(authProvider.notifier)
    final result = await ref.read(authProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!result && mounted) {
      Fluttertoast.showToast(msg: L10nAccessor.get(context, "login_error"));
      return;
    }

    // If success, go to HomePage
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> _handleRegister() async {
    final result = await ref.read(authProvider.notifier).register(
      _usernameController.text,
      _passwordController.text,
    );

    if (!result && mounted) {
      Fluttertoast.showToast(msg: L10nAccessor.get(context, "ERROR"));
      return;
    }

    // If success, go to HomePage
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}
