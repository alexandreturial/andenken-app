import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';

/// Converte o stream de Auth num [Listenable] para o `GoRouter`.
class AuthRefresh extends ChangeNotifier {
  AuthRefresh({required Stream<User?> stream, User? initial})
    : _user = initial {
    _subscription = stream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;
  User? _user;

  User? get user => _user;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
