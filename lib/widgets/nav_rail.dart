import 'package:amse/api.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        const NavigationRailDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: Text("Dashboard"),
            selectedIcon: Icon(Icons.dashboard)),
        const NavigationRailDestination(
            icon: Icon(Icons.group_outlined),
            label: Text("Participants"),
            selectedIcon: Icon(Icons.group)),
        const NavigationRailDestination(
            icon: Icon(Icons.timer_outlined),
            label: Text("Results"),
            selectedIcon: Icon(Icons.timer)),
        if (isAdmin)
          const NavigationRailDestination(
              icon: Icon(Icons.workspaces_outlined),
              label: Text("Competitions"),
              selectedIcon: Icon(Icons.workspaces)),
        if (isAdmin)
          const NavigationRailDestination(
              icon: Icon(Icons.manage_accounts_outlined),
              label: Text("Users"),
              selectedIcon: Icon(Icons.manage_accounts))
      ],
    );
  }
}
