import 'package:flutter/material.dart';

import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amse - Login"),
      ),
      body: Center(
          child: Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(50),
            child: Text(
              "Amse Login",
              style: TextStyle(fontSize: 40),
            ),
          ),
          LoginForm()
        ],
      )),
    );
  }
}
