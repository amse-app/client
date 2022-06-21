import 'package:amse/api.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:amse_api_client/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends StateNotifier<List<User>> {
  final Ref ref;

  Future<void>? _refreshing;

  UserNotifier(this.ref) : super([]) {
    refresh();
  }

  Future<void> refresh() {
    Future<void> _internalRefresh() async {
      AmseApi api = ref.read(apiProvider);

      final allUsers = await api.users.getAll();

      List<User> result = [];

      for (var mUser in allUsers) {
        User u = await api.users.getOne(mUser.id);
        result.add(u);
      }

      state = result;
      _refreshing = null;
    }

    _refreshing ??= _internalRefresh();
    return _refreshing!;
  }

  Future<String> add({
    required String username,
    required String password,
    bool admin = false,
    Map<String, dynamic>? data,
    String? name,
  }) async {
    AmseApi api = ref.read(apiProvider);
    final r = await api.users.create(
        password: password,
        username: username,
        admin: admin,
        data: data,
        name: name);
    await refresh();
    return r;
  }

  Future<void> delete(User user) async {
    AmseApi api = ref.read(apiProvider);

    await api.users.delete(user.id);
    await refresh();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, List<User>>(
  (ref) => UserNotifier(ref),
);
