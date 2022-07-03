import 'package:amse/providers/competitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResultsCompChooser extends ConsumerWidget {
  const ResultsCompChooser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comps = ref.watch(competitionProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          Text("Choose a competition"),
          ListView.separated(
            itemCount: comps.length,
            itemBuilder: (context, index) {
              final comp = comps[index];
              return ListTile(
                title: Text("${comp.short} - ${comp.name ?? ""}"),
                subtitle:
                    comp.description != null ? Text(comp.description!) : null,
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  GoRouter.of(context)
                      .goNamed("result", params: {"cid": comp.id!});
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}
