import 'package:amse/api.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data_sources/participant_datasource.dart';
import '../providers/competitions.dart';
import '../providers/users.dart';

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
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.server)),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !_serverRegex.hasMatch(value)) {
                  return AppLocalizations.of(context)!.generic_val;
                }
                return null;
              },
              controller: _addressController,
            ),
            const Padding(padding: EdgeInsets.all(8)),
            TextFormField(
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.username)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.generic_val;
                }
                return null;
              },
              controller: _usernameController,
            ),
            const Padding(padding: EdgeInsets.all(8)),
            TextFormField(
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.password)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.generic_val;
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
                      throw Exception(
                          AppLocalizations.of(context)!.not_reachable_error);
                    }

                    ref.read(apiProvider.notifier).state = AmseApi(uri);

                    AmseApi api = ref.read(apiProvider);

                    bool success = await api.authorization.login(
                        username: _usernameController.text,
                        password: _passwordController.text);
                    if (!mounted) return;
                    if (success) {
                      ref.read(userProvider);
                      ref.read(competitionProvider);
                      ref.read(participantDataProvider);
                      GoRouter.of(context).goNamed("home");
                    } else {
                      setState(() {
                        _loading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(AppLocalizations.of(context)!.no_success),
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _loading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .server_address_error)));
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.to_login),
            ),
            if (_loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
