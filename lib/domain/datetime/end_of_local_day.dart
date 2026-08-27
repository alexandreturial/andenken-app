/// Fim do dia civil no fuso do [date] local (spec §7 / due).
DateTime endOfLocalDay(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day, 23, 59, 59, 999);
}
