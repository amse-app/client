import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiProvider = StateProvider<AmseApi>((ref) {
  return AmseApi(Uri.parse("http://localhost:8080"));
});
