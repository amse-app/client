import 'package:amse/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AmseScaffold(
      selectedIndex: 0,
      body: Center(child: Text(AppLocalizations.of(context)!.dashboard)),
      title: Text(AppLocalizations.of(context)!.dashboard),
    );
  }
}
