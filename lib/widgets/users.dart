import 'package:amse/providers/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListView extends ConsumerWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);
    return ListView.separated(
      itemBuilder: (context, index) {
        final user = users[index];
        String title = user.username;
        if (user.name != null) {
          title = "$title - ${user.name}";
        }
        Widget? subtitle;
        if (user.roles.contains("admin")) {
          subtitle = const Text("admin");
        }

        return ListTile(
          title: Text(title),
          subtitle: subtitle,
          trailing: IconButton(
            onPressed: () {
              ref.read(userProvider.notifier).delete(user);
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: users.length,
    );
  }
}
