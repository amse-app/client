import 'package:amse/api.dart';
import 'package:amse/pages/home.dart';
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
        )
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
