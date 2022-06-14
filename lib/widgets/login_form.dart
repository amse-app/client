import 'package:amse/api.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _serverRegex = RegExp(
      r"^(https?:\/\/)?[a-zA-Z0-9_\-\.]+(:[0-9]{2,5})?$",
      caseSensitive: false);
  final _domainRegex =
      RegExp(r"^[a-zA-Z0-9_\-\.]+(:[0-9]{2,5})?$", caseSensitive: false);

  bool _loading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(label: Text("Server")),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !_serverRegex.hasMatch(value)) {
                  return "Please enter a valid server address";
                }
                return null;
              },
              controller: _addressController,
            ),
            const Padding(padding: EdgeInsets.all(8)),
            TextFormField(
              decoration: const InputDecoration(label: Text("Username")),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a valid username";
                }
                return null;
              },
              controller: _usernameController,
            ),
            const Padding(padding: EdgeInsets.all(8)),
            TextFormField(
              decoration: const InputDecoration(label: Text("Password")),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a valid password";
                }
                return null;
              },
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            const Padding(padding: EdgeInsets.all(16)),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _loading = true;
                  });
                  try {
                    String urlString = _addressController.text;
                    if (_domainRegex.hasMatch(urlString)) {
                      urlString = "http://$urlString";
                    }
                    Uri uri = Uri.parse(urlString);

                    if (!(await AmseApi.checkHealth(uri))) {
                      throw Exception("Server is not reachable1");
                    }

                    ref.read(apiProvider.notifier).state = AmseApi(uri);

                    AmseApi api = ref.read(apiProvider);

                    bool success = await api.authorization.login(
                        username: _usernameController.text,
                        password: _passwordController.text);
                    if (!mounted) return;
                    if (success) {
                      GoRouter.of(context).goNamed("home");
                    } else {
                      setState(() {
                        _loading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Error: Credentials or ServerAddress incorrect")));
                    }
                  } catch (e, s) {
                    print(e);
                    print(s);
                    setState(() {
                      _loading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Error: Credentials or ServerAddress incorrect")));
                  }
                }
              },
              child: const Text("Login"),
            ),
            if (_loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
