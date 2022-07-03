import 'package:amse/providers/competitions.dart';
import 'package:amse/widgets/participants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/scaffold.dart';

class ParticipantsPage extends ConsumerWidget {
  const ParticipantsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget? fab = FloatingActionButton(
      onPressed: () {
        GoRouter.of(context).goNamed("add_participant");
      },
      child: const Icon(Icons.add),
    );

    if (ref.read(competitionProvider).isEmpty) {
      fab = null;
    }

    return AmseScaffold(
      selectedIndex: 1,
      title: Text(AppLocalizations.of(context)!.participants),
      body: const Center(
        child: ParticipantsWidget(),
      ),
      floatingActionButton: fab,
    );
  }
}

class ParticipantCreatePage extends StatelessWidget {
  const ParticipantCreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.create_participant)),
      body: const Center(
        child: ParticipantCreateForm(),
      ),
    );
  }
}
