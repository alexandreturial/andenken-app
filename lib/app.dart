import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/flavor/flavor.dart';
import 'core/router/app_router.dart';
import 'core/router/auth_refresh.dart';
import 'core/theme/app_theme.dart';
import 'data/firebase/firebase_auth_repository.dart';
import 'data/firebase/firestore_card_repository.dart';
import 'data/firebase/firestore_deck_repository.dart';
import 'data/firebase/firestore_study_stats_repository.dart';
import 'data/memory/memory_study_stats_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/card_repository.dart';
import 'domain/repositories/deck_repository.dart';
import 'domain/repositories/study_stats_repository.dart';
import 'domain/usecases/create_card.dart';
import 'domain/usecases/create_deck.dart';
import 'domain/usecases/delete_card.dart';
import 'domain/usecases/delete_deck.dart';
import 'domain/usecases/list_cards.dart';
import 'domain/usecases/list_decks.dart';
import 'domain/usecases/list_due_cards.dart';
import 'domain/usecases/rename_deck.dart';
import 'domain/usecases/persist_study_day.dart';
import 'domain/usecases/review_card.dart';
import 'domain/usecases/update_card.dart';
import 'domain/usecases/sign_in.dart';
import 'domain/usecases/sign_in_with_google.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/sign_up.dart';
import 'domain/usecases/watch_current_user.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.authRepository,
    this.deckRepository,
    this.cardRepository,
    this.studyStatsRepository,
    this.initialLocation,
  });

  /// Testes injetam o fake. Em produção usa [FirebaseAuthRepository].
  final AuthRepository? authRepository;
  final DeckRepository? deckRepository;
  final CardRepository? cardRepository;
  final StudyStatsRepository? studyStatsRepository;
  final String? initialLocation;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthRepository _auth;
  late final DeckRepository _decks;
  late final CardRepository _cards;
  late final StudyStatsRepository _studyStats;
  late final SignIn _signIn;
  late final SignUp _signUp;
  late final SignOut _signOut;
  late final SignInWithGoogle _signInWithGoogle;
  late final WatchCurrentUser _watchCurrentUser;
  late final ListDecks _listDecks;
  late final CreateDeck _createDeck;
  late final RenameDeck _renameDeck;
  late final DeleteDeck _deleteDeck;
  late final ListCards _listCards;
  late final ListDueCards _listDueCards;
  late final CreateCard _createCard;
  late final UpdateCard _updateCard;
  late final DeleteCard _deleteCard;
  late final ReviewCard _reviewCard;
  late final PersistStudyDay _persistStudyDay;
  late final AuthRefresh _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = widget.authRepository ?? FirebaseAuthRepository();
    _decks = widget.deckRepository ?? FirestoreDeckRepository();
    _cards = widget.cardRepository ?? FirestoreCardRepository();
    final usingFakes =
        widget.authRepository != null ||
        widget.deckRepository != null ||
        widget.cardRepository != null ||
        widget.studyStatsRepository != null;
    _studyStats =
        widget.studyStatsRepository ??
        (usingFakes
            ? MemoryStudyStatsRepository()
            : FirestoreStudyStatsRepository());
    _signIn = SignIn(_auth);
    _signUp = SignUp(_auth);
    _signOut = SignOut(_auth);
    _signInWithGoogle = SignInWithGoogle(_auth);
    _watchCurrentUser = WatchCurrentUser(_auth);
    _listDecks = ListDecks(_decks);
    _createDeck = CreateDeck(_decks);
    _renameDeck = RenameDeck(_decks);
    _deleteDeck = DeleteDeck(_decks, _cards);
    _listCards = ListCards(_cards);
    _listDueCards = ListDueCards(_cards);
    _createCard = CreateCard(_cards);
    _updateCard = UpdateCard(_cards);
    _deleteCard = DeleteCard(_cards);
    _reviewCard = ReviewCard(_cards);
    _persistStudyDay = PersistStudyDay(_studyStats);
    _authRefresh = AuthRefresh(
      stream: _watchCurrentUser(),
      initial: _auth.currentUser,
    );
    _router = createAppRouter(
      authRefresh: _authRefresh,
      initialLocation: widget.initialLocation ?? '/decks',
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _auth),
        Provider<DeckRepository>.value(value: _decks),
        Provider<CardRepository>.value(value: _cards),
        Provider<StudyStatsRepository>.value(value: _studyStats),
        Provider<SignIn>.value(value: _signIn),
        Provider<SignUp>.value(value: _signUp),
        Provider<SignOut>.value(value: _signOut),
        Provider<SignInWithGoogle>.value(value: _signInWithGoogle),
        Provider<WatchCurrentUser>.value(value: _watchCurrentUser),
        Provider<ListDecks>.value(value: _listDecks),
        Provider<CreateDeck>.value(value: _createDeck),
        Provider<RenameDeck>.value(value: _renameDeck),
        Provider<DeleteDeck>.value(value: _deleteDeck),
        Provider<ListCards>.value(value: _listCards),
        Provider<ListDueCards>.value(value: _listDueCards),
        Provider<CreateCard>.value(value: _createCard),
        Provider<UpdateCard>.value(value: _updateCard),
        Provider<DeleteCard>.value(value: _deleteCard),
        Provider<ReviewCard>.value(value: _reviewCard),
        Provider<PersistStudyDay>.value(value: _persistStudyDay),
      ],
      child: MaterialApp.router(
        title: FlavorConfig.current.displayName,
        locale: AppTheme.locale,
        supportedLocales: AppTheme.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final page = child ?? const SizedBox.shrink();
          if (!FlavorConfig.current.showFlavorBanner) {
            return page;
          }
          return Banner(
            message: FlavorConfig.current.bannerLabel,
            location: BannerLocation.topStart,
            child: page,
          );
        },
      ),
    );
  }
}
