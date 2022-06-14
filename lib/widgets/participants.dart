import 'package:amse/data_sources/participant_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParticipantsWidget extends ConsumerStatefulWidget {
  const ParticipantsWidget({Key? key, bool add = false}) : super(key: key);

  @override
  ConsumerState<ParticipantsWidget> createState() => ParticipantsWidgetState();
}

class ParticipantsWidgetState extends ConsumerState<ParticipantsWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PaginatedDataTable(
        source: ref.read(participantDataProvider),
        columns: const [
          DataColumn(label: Text("Number")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Birth")),
          DataColumn(label: Text("Competitions"))
        ],
        //TODO: specify other options
      ),
    );
  }

  //TODO: implement showAdd
  void showAdd() {}
}
