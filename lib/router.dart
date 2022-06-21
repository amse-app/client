import 'package:amse/api.dart';
import 'package:amse/pages/competitions.dart';
import 'package:amse/pages/home.dart';
import 'package:amse/pages/participants.dart';
import 'package:amse_api_client/amse_api_client.dart';
import 'package:flutter/material.dart';
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
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const HomePage()),
        ),
        GoRoute(
          path: "/login",
          name: "login",
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const LoginPage()),
        ),
        GoRoute(
          path: "/participants",
          name: "participants",
          pageBuilder: (context, state) {
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

            return FadeTransitionPage(child: ParticipantsPage(add: add));
          },
        ),
        GoRoute(
            path: "/competitions",
            name: "competitions",
            pageBuilder: (context, state) =>
                FadeTransitionPage(child: const CompetitionsPage()),
            routes: [
              GoRoute(
                path: "add",
                name: "addCompetition",
                pageBuilder: (context, state) {
                  return const MaterialPage(
                      fullscreenDialog: true, child: CompetitionCreatePage());
                },
              ),
              GoRoute(
                path: ":cid",
                name: "competitionDetail",
                pageBuilder: (context, state) => FadeTransitionPage(
                    child: CompetitionDetailPage(state.params["cid"]!)),
              ),
            ])
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

class FadeTransitionPage extends CustomTransitionPage {
  static final _curveTween = CurveTween(curve: Curves.easeIn);

  FadeTransitionPage({required Widget child, LocalKey? key})
      : super(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
                      opacity: animation.drive(_curveTween),
                      child: child,
                    ),
            child: child,
            key: key);
}
