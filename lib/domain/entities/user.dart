/// Usuário autenticado. Sem coleção `users` — o domínio mapeia o Auth (spec §3.1).
class User {
  const User({required this.id, required this.email, required this.createdAt});

  final String id;
  final String email;
  final DateTime createdAt;

  User copyWith({String? id, String? email, DateTime? createdAt}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
