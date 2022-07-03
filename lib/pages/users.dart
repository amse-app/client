import 'package:amse/providers/users.dart';
import 'package:amse/widgets/scaffold.dart';
import 'package:amse/widgets/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AmseScaffold(
      title: Text(AppLocalizations.of(context)!.users),
      selectedIndex: 4,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            GoRouter.of(context).goNamed("add_user");
          },
          child: const Icon(Icons.add)),
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

class UserCreatePage extends StatelessWidget {
  const UserCreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.add_user)),
      body: Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: const UserCreateForm()),
      ),
    );
  }
}
