import 'dart:io';

import 'package:amse/widgets/nav_rail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum MenuOptions { about }

class AmseScaffold extends ConsumerWidget {
  final int selectedIndex;
  final Widget body;
  final bool firstLevel;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AmseScaffold({
    Key? key,
    required this.selectedIndex,
    required this.body,
    this.firstLevel = true,
    this.title,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool extended = ref.watch(extendedProvider);
    Widget leading;
    if (firstLevel) {
      leading = IconButton(
          onPressed: () {
            ref.read(extendedProvider.notifier).state = !extended;
          },
          icon: const Icon(Icons.menu));
    } else {
      leading = IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back));
    }
    return Scaffold(
      body: Row(
        children: [
          AmseNavRail(selectedIndex: selectedIndex, extended: extended),
          const VerticalDivider(
            width: 1,
            thickness: 1,
          ),
          Expanded(child: body)
        ],
      ),
      appBar: AppBar(
        leading: leading,
        title: title,
        actions: [
          ...?actions,
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry<MenuOptions>>[
              PopupMenuItem(
                value: MenuOptions.about,
                child: Text(AppLocalizations.of(context)!.about),
              )
            ],
            onSelected: (MenuOptions option) {
              if (option == MenuOptions.about) {
                showAboutDialog(
                  context: context,
                  applicationName: "amse",
                  applicationVersion: "0.1.0",
                  applicationLegalese:
                      "${AppLocalizations.of(context)!.copyright} Paul Barbenheim 2022",
                );
              }
            },
          )
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

final extendedProvider = StateProvider<bool>((ref) {
  return kIsWeb ? true : !(Platform.isAndroid || Platform.isIOS);
});
