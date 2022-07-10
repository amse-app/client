import 'package:amse/api.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:amse_api_client/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParticipantNotifier extends StateNotifier<List<MinParticipant>> {
  Ref ref;
  Future<void>? _refreshing;

  ParticipantNotifier(this.ref) : super([]) {
    refresh();
  }

  Future<void> refresh() {
    Future<void> _internalRefresh() async {
      AmseApi api = ref.read(apiProvider);

      var res = await api.participants.getAll();
      state = res;
      _refreshing = null;
    }

    _refreshing ??= _internalRefresh();

    return _refreshing!;
  }
}

final participantProvider =
    StateNotifierProvider<ParticipantNotifier, List<MinParticipant>>((ref) {
  return ParticipantNotifier(ref);
});
