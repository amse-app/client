import 'package:amse/widgets/results.dart';
import 'package:amse/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AmseScaffold(
      selectedIndex: 2,
      title: Text(AppLocalizations.of(context)!.results),
      body: const Center(
        child: ResultsCompChooser(),
      ),
    );
  }
}

class ResultPage extends ConsumerWidget {
  final String cid;
  const ResultPage({Key? key, required this.cid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AmseScaffold(
      selectedIndex: 2,
      firstLevel: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).goNamed("add_result", params: {"cid": cid});
        },
        child: const Icon(Icons.timer),
      ),
      body: const Text("result"),
    );
  }
}

class AddResultPage extends ConsumerWidget {
  const AddResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add results"),
      ),
      body: Text("Test"),
    );
  }
}
