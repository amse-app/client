import 'package:amse/providers/users.dart';
import 'package:amse/widgets/scaffold.dart';
import 'package:amse/widgets/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AmseScaffold(
      title: const Text("Users"),
      selectedIndex: 4,
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
      actions: [
        IconButton(
          onPressed: () {
            ref.read(userProvider.notifier).refresh();
          },
          icon: const Icon(Icons.refresh),
        )
      ],
      body: const UserListView(),
    );
  }
}
