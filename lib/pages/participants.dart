import 'package:amse/widgets/participants.dart';
import 'package:flutter/material.dart';

import '../widgets/scaffold.dart';

class ParticipantsPage extends StatelessWidget {
  final bool _add;

  ParticipantsPage({Key? key, bool add = false})
      : _add = add,
        super(key: key);

  final GlobalKey<ParticipantsWidgetState> _partsKey =
      GlobalKey<ParticipantsWidgetState>();

  @override
  Widget build(BuildContext context) {
    return AmseScaffold(
      selectedIndex: 1,
      title: const Text("Participants"),
      body: Center(
        child: ParticipantsWidget(key: _partsKey, add: _add),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _partsKey.currentState?.showAdd();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
