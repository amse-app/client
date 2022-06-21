import 'package:amse/providers/competitions.dart';
import 'package:amse/widgets/competitions.dart';
import 'package:amse/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompetitionsPage extends ConsumerWidget {
  const CompetitionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AmseScaffold(
      body: const Center(
        child: CompetitionListView(),
      ),
      selectedIndex: 3,
      title: const Text("Competitions"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).pushNamed("addCompetition");
        },
        child: const Icon(Icons.add),
      ),
      actions: [
        IconButton(
            onPressed: () {
              ref.read(competitionProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh))
      ],
    );
  }
}

class CompetitionDetailPage extends ConsumerWidget {
  final String id;
  const CompetitionDetailPage(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comp = ref.read(competitionProvider).firstWhere((c) => c.id == id);
    return AmseScaffold(
      body: Center(
        child: CompetitionDetailView(id),
      ),
      selectedIndex: 3,
      firstLevel: false,
      title: const Text("Competition"),
      actions: [
        IconButton(
            onPressed: () {
              GoRouter.of(context).pop();
              ref.read(competitionProvider.notifier).delete(comp);
            },
            icon: const Icon(Icons.delete))
      ],
    );
  }
}

class CompetitionCreatePage extends StatelessWidget {
  const CompetitionCreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add competition")),
      body: const Center(
        child: CompetitionCreateForm(),
      ),
    );
  }
}