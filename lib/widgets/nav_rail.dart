import 'package:amse/api.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AmseNavRail extends ConsumerWidget {
  final bool extended;
  final int selectedIndex;
  const AmseNavRail(
      {Key? key, this.extended = true, required this.selectedIndex})
      : super(key: key);

  String _getNameFromIndex(int index) {
    switch (index) {
      case 0:
        return "home";
      case 1:
        return "participants";
      case 2:
        return "results";
      case 3:
        return "competitions";
      case 4:
        return "users";
      default:
        throw ArgumentError.value(index, "index");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AmseApi api = ref.read(apiProvider);
    bool isAdmin = api.user!.roles.contains("admin");
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (dest) {
        GoRouter.of(context).goNamed(_getNameFromIndex(dest));
      },
      extended: extended,
      labelType: NavigationRailLabelType.none,
      destinations: [
        NavigationRailDestination(
            icon: const Icon(Icons.dashboard_outlined),
            label: Text(AppLocalizations.of(context)!.dashboard),
            selectedIcon: const Icon(Icons.dashboard)),
        NavigationRailDestination(
            icon: const Icon(Icons.group_outlined),
            label: Text(AppLocalizations.of(context)!.participants),
            selectedIcon: const Icon(Icons.group)),
        NavigationRailDestination(
            icon: const Icon(Icons.timer_outlined),
            label: Text(AppLocalizations.of(context)!.results),
            selectedIcon: const Icon(Icons.timer)),
        if (isAdmin)
          NavigationRailDestination(
              icon: const Icon(Icons.workspaces_outlined),
              label: Text(AppLocalizations.of(context)!.competitions),
              selectedIcon: const Icon(Icons.workspaces)),
        if (isAdmin)
          NavigationRailDestination(
              icon: const Icon(Icons.manage_accounts_outlined),
              label: Text(AppLocalizations.of(context)!.users),
              selectedIcon: const Icon(Icons.manage_accounts))
      ],
    );
  }
}
