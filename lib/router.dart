import 'package:amse/api.dart';
import 'package:amse/pages/competitions.dart';
import 'package:amse/pages/home.dart';
import 'package:amse/pages/participants.dart';
import 'package:amse/pages/results.dart';
import 'package:amse/pages/users.dart';
import 'package:amse/providers/competitions.dart';
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
              return FadeTransitionPage(child: const ParticipantsPage());
            },
            routes: [
              GoRoute(
                path: "add",
                name: "add_participant",
                pageBuilder: (context, state) => const MaterialPage(
                  fullscreenDialog: true,
                  child: ParticipantCreatePage(),
                ),
              )
            ]),
        GoRoute(
          path: "/competitions",
          name: "competitions",
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const CompetitionsPage()),
          routes: [
            GoRoute(
              path: "add",
              //TODO: temporary fix for https://github.com/flutter/flutter/issues/1061639i
              name: "add_competition",
              pageBuilder: (context, state) {
                return const MaterialPage(
                    fullscreenDialog: true, child: CompetitionCreatePage());
              },
            ),
            GoRoute(
              path: ":cid",
              //TODO: temporary fix for https://github.com/flutter/flutter/issues/106163
              name: "competition_detail",
              pageBuilder: (context, state) => FadeTransitionPage(
                  child: CompetitionDetailPage(state.params["cid"]!)),
            ),
          ],
        ),
        GoRoute(
          path: "/users",
          name: "users",
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const UsersPage()),
          routes: [
            GoRoute(
              path: "add",
              name: "add_user",
              pageBuilder: (context, state) => const MaterialPage(
                child: UserCreatePage(),
                fullscreenDialog: true,
              ),
            )
          ],
        ),
        GoRoute(
          path: "/results",
          name: "results",
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const ResultsPage()),
          routes: [
            GoRoute(
                path: "add",
                name: "add_global_result",
                pageBuilder: (context, state) => const MaterialPage(
                    child: AddGlobalResultPage(), fullscreenDialog: true)),
            GoRoute(
              path: ":cid",
              name: "result",
              pageBuilder: (context, state) {
                final cid = state.params["cid"];
                if (cid == null ||
                    cid.isEmpty ||
                    !ref
                        .read(competitionProvider)
                        .map((e) => e.id)
                        .contains(cid)) {
                  throw Exception("no param specified");
                }
                return FadeTransitionPage(
                  child: ResultPage(
                    comp: ref
                        .read(competitionProvider)
                        .firstWhere((element) => element.id == cid),
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: "add",
                  name: "add_result",
                  pageBuilder: (context, state) {
                    final cid = state.params["cid"];
                    assert(cid != null);
                    return FadeTransitionPage(
                      child: AddResultPage(
                        comp: ref
                            .read(competitionProvider)
                            .firstWhere((element) => element.id == cid),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
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
