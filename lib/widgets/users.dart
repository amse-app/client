import 'package:amse/api.dart';
import 'package:amse/providers/users.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          subtitle = Text(AppLocalizations.of(context)!.admin);
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

class UserCreateForm extends ConsumerStatefulWidget {
  const UserCreateForm({Key? key}) : super(key: key);

  @override
  ConsumerState<UserCreateForm> createState() => _UserCreateFormState();
}

class _UserCreateFormState extends ConsumerState<UserCreateForm> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isAdmin = false;
  final _passwdController = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _passwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.create_user,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          const Padding(padding: EdgeInsets.all(30)),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.username)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.user_create_username_val;
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.all(15)),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.name)),
          ),
          const Padding(padding: EdgeInsets.all(15)),
          Row(
            children: [
              Text(AppLocalizations.of(context)!.is_admin),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Checkbox(
                  value: _isAdmin,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAdmin = value ?? false;
                    });
                  },
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.all(15)),
          TextFormField(
            controller: _passwdController,
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.password)),
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.length < 8) {
                return AppLocalizations.of(context)!.user_create_password_val;
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.all(30)),
          ElevatedButton(
            onPressed: () async {
              if (_formkey.currentState!.validate()) {
                setState(() {
                  _loading = true;
                });
                String? name;
                if (_nameController.text.isNotEmpty) {
                  name = _nameController.text;
                }
                AmseApi api = ref.read(apiProvider);
                try {
                  await api.users.create(
                    username: _usernameController.text,
                    password: _passwdController.text,
                    admin: _isAdmin,
                    name: name,
                  );
                  await ref.read(userProvider.notifier).refresh();
                  if (mounted) {
                    GoRouter.of(context).pop();
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _loading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.user_create_error,
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.submit),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
