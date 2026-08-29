/// Opções da sessão de estudo (RN-U01). Mapeiam para `grade` SM-2 (RN-U02).
enum StudyChoice {
  forgotten,
  hard,
  remembered,
  known;

  String get label => switch (this) {
    StudyChoice.forgotten => 'Não lembro',
    StudyChoice.hard => 'Lembrei com dificuldade',
    StudyChoice.remembered => 'Lembrei',
    StudyChoice.known => 'Conheço',
  };

  int get sm2Grade => switch (this) {
    StudyChoice.forgotten => 0,
    StudyChoice.hard => 4,
    StudyChoice.remembered => 5,
    StudyChoice.known => 5,
  };
}
