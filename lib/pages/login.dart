import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Amse - ${AppLocalizations.of(context)!.login}"),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(50),
              child: Text(
                "Amse ${AppLocalizations.of(context)!.login}",
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}
