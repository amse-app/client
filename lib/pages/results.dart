import 'package:amse/widgets/results.dart';
import 'package:amse/widgets/scaffold.dart';
import 'package:amse_api_client/models.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).goNamed("add_global_result");
        },
        child: const Icon(Icons.timer),
      ),
    );
  }
}

class ResultPage extends ConsumerWidget {
  final Comp comp;
  const ResultPage({Key? key, required this.comp}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AmseScaffold(
      selectedIndex: 2,
      firstLevel: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).goNamed("add_result", params: {"cid": comp.id!});
        },
        child: const Icon(Icons.timer),
      ),
      title: Text(
          "Results of ${comp.short}${comp.name != null ? " - ${comp.name}" : ""}"),
      body: Center(
        child: ResultsList(comp: comp),
      ),
    );
  }
}

class AddResultPage extends ConsumerWidget {
  final Comp comp;
  const AddResultPage({Key? key, required this.comp}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Add results in ${comp.short}${comp.name != null ? ' - ${comp.name}' : ''}"),
      ),
      body: Center(
        child: ResultAdd(comp: comp),
      ),
    );
  }
}

class AddGlobalResultPage extends StatelessWidget {
  const AddGlobalResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add result")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: const GlobalResultAdd(quali: true),
        ),
      ),
    );
  }
}
