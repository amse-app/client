import 'package:amse/api.dart';
import 'package:amse/pages/home.dart';
import 'package:amse/pages/participants.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/login.dart';

final routerProvider = Provider((ref) {
  AmseApi api = ref.read(apiProvider);
  return GoRouter(
      routes: [
        GoRoute(
          path: "/",
          name: "home",
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: "/login",
          name: "login",
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: "/participants",
          name: "participants",
          builder: (context, state) {
            var addS = state.queryParams["add"];
            final bool add;
            if (addS == null || addS.isEmpty) {
              add = false;
            } else {
              if (addS.toLowerCase() == "true") {
                add = true;
              } else if (addS.toLowerCase() == "false") {
                add = false;
              } else {
                throw const FormatException("not a valid parameter");
              }
            }

            return ParticipantsPage(add: add);
          },
        ),
      ],
      routerNeglect: true,
      redirect: (state) {
        final loggingIn = state.subloc == "/login";
        final loggedIn = api.isLoggedIn;

        if (!loggedIn) return loggingIn ? null : "/login";

        if (loggingIn) return "/";

        return null;
      });
});
