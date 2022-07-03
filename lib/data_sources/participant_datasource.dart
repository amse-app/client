import 'package:amse/api.dart';
import 'package:amse/providers/competitions.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amse_api_client/models.dart' as amse_models;

class ParticipantDataSource extends DataTableSource {
  final Ref ref;

  List<amse_models.MinParticipant> _participants = [];

  Future<void>? _loading;

  int _count = 100;

  ParticipantDataSource(this.ref) : super() {
    _load();
  }

  void refresh() {
    _load();
  }

  Future<void> _load() {
    _loading ??= _loadInternally();
    return _loading!;
  }

  Future<void> _loadInternally() async {
    AmseApi api = ref.read(apiProvider);
    _participants = await api.participants.getAll();
    _count = _participants.length;
    _loading = null;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (!(index < _participants.length) || index < 0) {
      return null;
    }

    var part = _participants[index];

    String birth;

    if (part.birth == null) {
      birth = "-";
    } else {
      birth = part.birth!.toLocal().toString();
    }

    var competitions = ref.read(competitionProvider);
    String competition = "No competitions available";
    if (part.comps != null) {
      competition = "";
      for (var cs in part.comps!) {
        competition =
            "$competition${competitions.firstWhere((element) => element.id == cs).short}, ";
      }
    }

    return DataRow(
      cells: [
        DataCell(Text(part.number ?? "-")),
        DataCell(Text(part.name ?? "-")),
        DataCell(Text(birth)),
        DataCell(Text(competition)),
        DataCell(IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await ref.read(apiProvider).participants.delete(part.id!);
            refresh();
          },
        ))
      ],
    );
    //TODO: add option for deleting participants
  }

  @override
  bool get isRowCountApproximate => !(_participants.length == _count);

  @override
  int get rowCount => _count;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}

final Provider<ParticipantDataSource> participantDataProvider =
    Provider((ref) => ParticipantDataSource(ref));
