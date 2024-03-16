import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});
  static String routeName = "/login";
  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loginMode = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = L10nAccessor.get(context, _loginMode? "login_page" : "register_page");

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body:_buildLoginRegisterForm(),
    );
  }

  Widget _buildLoginRegisterForm() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            children: [
              _buildUsernameField(),
              _buildPasswordField(),
              _buildSubmitButton(),
            ],
          ),
        ),
        GestureDetector(
        onTap: () {
          setState(() {
            _loginMode = !_loginMode;
          });
        },
        child: Text(
          L10nAccessor.get(context, _loginMode? "goto_register" : "goto_login"),
          style: TextStyle(
            color: Theme.of(context).hintColor,
            decoration: TextDecoration.underline, 
          ),
        ),
      ),
      ],
    );
  }

  TextFormField _buildUsernameField() {
    return TextFormField(
      autofillHints: const [AutofillHints.username],
      decoration: InputDecoration(
        labelText: L10nAccessor.get(context, "username")
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
        labelText: L10nAccessor.get(context, "password")
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
          _handleSubmit(context);
        }
      },
      child: _isLoading
          ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
          : Text(L10nAccessor.get(context, "submit")),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    if (_loginMode){
      _handleLogin(context);
    }
    else {
      _handleRegister(context);
    }
  }

  Future<void> _handleLogin(BuildContext context) async {

  }

  Future<void> _handleRegister(BuildContext context) async {

  }
}
