import 'package:go_router/go_router.dart';

import '../../presentation/widgets/route_stub_screen.dart';

/// Rotas do plan §5. Redirect de Auth entra na T033.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/decks',
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return '/decks';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const RouteStubScreen(title: 'Login'),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const RouteStubScreen(title: 'Cadastro'),
      ),
      GoRoute(
        path: '/decks',
        builder: (context, state) => const RouteStubScreen(title: 'Decks'),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) =>
                const RouteStubScreen(title: 'Novo deck'),
          ),
          GoRoute(
            path: ':deckId',
            builder: (context, state) => RouteStubScreen(
              title: 'Deck ${state.pathParameters['deckId']}',
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    const RouteStubScreen(title: 'Renomear deck'),
              ),
              GoRoute(
                path: 'study',
                builder: (context, state) =>
                    const RouteStubScreen(title: 'Estudo'),
              ),
              GoRoute(
                path: 'cards/new',
                builder: (context, state) =>
                    const RouteStubScreen(title: 'Novo card'),
              ),
              GoRoute(
                path: 'cards/:cardId/edit',
                builder: (context, state) => RouteStubScreen(
                  title: 'Editar card ${state.pathParameters['cardId']}',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
