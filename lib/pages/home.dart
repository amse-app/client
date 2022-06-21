import 'package:amse/widgets/scaffold.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AmseScaffold(
      selectedIndex: 0,
      body: Center(child: Text("Dashboard")),
      title: Text("Dashboard"),
    );
  }
}
