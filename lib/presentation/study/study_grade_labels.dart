/// Rótulos curtos da escala de notas do algoritmo SM-2 §3. Sem intervalos na UI.
String labelForGrade(int grade) {
  switch (grade) {
    case 0:
      return 'Sem lembrança';
    case 1:
      return 'Lembrei depois';
    case 2:
      return 'Parecia fácil';
    case 3:
      return 'Com dificuldade';
    case 4:
      return 'Com hesitação';
    case 5:
      return 'Perfeita';
    default:
      return '';
  }
}
