import 'package:amse/api.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:amse_api_client/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompetitionNotifier extends StateNotifier<List<Comp>> {
  final Ref ref;
  Future<void>? _refreshing;

  CompetitionNotifier(this.ref) : super([]) {
    refresh();
  }

  Future<void> refresh() {
    Future<void> _internalRefresh() async {
      AmseApi api = ref.read(apiProvider);

      final allComps = await api.competitions.getAll();

      List<Comp> result = [];

      for (var mComp in allComps) {
        Comp c = await api.competitions.getOne(mComp.id);
        result.add(c);
      }

      state = result;
    }

    _refreshing ??= _internalRefresh();
    return _refreshing!;
  }

  Future<String> add(Comp comp) async {
    AmseApi api = ref.read(apiProvider);
    final r = await api.competitions.create(comp);
    await refresh();
    return r;
  }

  Future<void> delete(Comp comp) async {
    AmseApi api = ref.read(apiProvider);

    await api.competitions.delete(comp.id!);
    await refresh();
  }
}

final competitionProvider =
    StateNotifierProvider<CompetitionNotifier, List<Comp>>((ref) {
  return CompetitionNotifier(ref);
});
