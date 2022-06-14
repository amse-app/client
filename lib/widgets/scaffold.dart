import 'package:amse/widgets/nav_rail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AmseScaffold extends StatefulWidget {
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
  State<AmseScaffold> createState() => _AmseScaffoldState();
}

class _AmseScaffoldState extends State<AmseScaffold> {
  bool extended = true;

  @override
  Widget build(BuildContext context) {
    Widget leading;
    if (widget.firstLevel) {
      leading = IconButton(
          onPressed: () {
            setState(() {
              extended = !extended;
            });
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
          AmseNavRail(selectedIndex: widget.selectedIndex, extended: extended),
          const VerticalDivider(
            width: 1,
            thickness: 1,
          ),
          Expanded(child: widget.body)
        ],
      ),
      appBar: AppBar(
        leading: leading,
        title: widget.title,
        actions: widget.actions,
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
