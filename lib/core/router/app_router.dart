import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/cards/card_form_screen.dart';
import '../../presentation/decks/deck_detail_screen.dart';
import '../../presentation/decks/deck_form_screen.dart';
import '../../presentation/decks/deck_list_screen.dart';
import '../../presentation/study/study_screen.dart';
import 'auth_refresh.dart';

/// Rotas do plan §5. Redirect de Auth (RN-A04).
GoRouter createAppRouter({
  required AuthRefresh authRefresh,
  String initialLocation = '/decks',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final loggedIn = authRefresh.user != null;
      final guestRoute = path == '/login' || path == '/register';

      if (path == '/') {
        return loggedIn ? '/decks' : '/login';
      }
      if (!loggedIn && !guestRoute) {
        return '/login';
      }
      if (loggedIn && guestRoute) {
        return '/decks';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/decks',
        builder: (context, state) => const DeckListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const DeckFormScreen(),
          ),
          GoRoute(
            path: ':deckId',
            builder: (context, state) =>
                DeckDetailScreen(deckId: state.pathParameters['deckId']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    DeckFormScreen(deckId: state.pathParameters['deckId']),
              ),
              GoRoute(
                path: 'study',
                builder: (context, state) =>
                    StudyScreen(deckId: state.pathParameters['deckId']!),
              ),
              GoRoute(
                path: 'cards/new',
                builder: (context, state) =>
                    CardFormScreen(deckId: state.pathParameters['deckId']!),
              ),
              GoRoute(
                path: 'cards/:cardId/edit',
                builder: (context, state) => CardFormScreen(
                  deckId: state.pathParameters['deckId']!,
                  cardId: state.pathParameters['cardId'],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
