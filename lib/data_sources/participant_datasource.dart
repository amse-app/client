import 'package:amse/api.dart';
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
    print("hi");
    notifyListeners();
    print(isRowCountApproximate);
  }

  @override
  DataRow? getRow(int index) {
    // TODO: implement competitions

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

    return DataRow(
      cells: [
        DataCell(Text(part.number ?? "-")),
        DataCell(Text(part.name ?? "-")),
        DataCell(Text(birth)),
        const DataCell(Text("competitions later"))
      ],
    );
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
