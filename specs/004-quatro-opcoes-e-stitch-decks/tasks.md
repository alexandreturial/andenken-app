# Tasks — 004-quatro-opcoes-e-stitch-decks

> v1 (T000–T075) está encerrada em [`docs/tasks.md`](../../docs/tasks.md). Esta lista é só da feature.
> **TDD (P-09):** task de regra = teste vermelho → implementação → verde → refactor → UI Stitch.

---

## Fase A — Contrato e mapper

- [x] **T100** Atualizar contrato v1 (spec US-05 / §7, PRODUCT, algoritmo §3.1, DIFF, constitution P-08, AGENTS, plan §1.1, qa-manual US-05)
  - US: US-07
  - RN: RN-U01, RN-U02, RN-U03
  - Teste: n/a (docs)
  - Depends: —

- [x] **T101** Teste vermelho do mapper `StudyChoice` → `grade` (0, 4, 5, 5) e Lembrei ≡ Conheço → implementação verde
  - US: US-07
  - RN: RN-U01, RN-U02
  - Teste: `test/presentation/study_choice_test.dart`
  - Depends: T100

## Fase B — UI de estudo

- [x] **T102** `StudyScreen`: 4 botões (rótulos RN-U01); “Não lembro” refila; as outras encerram; sem pad 0–5
  - US: US-07
  - RN: RN-U01, RN-U02, RN-U03
  - Teste: `test/presentation/study_screen_test.dart`
  - Depends: T101

## Fase C — Stitch decks

- [x] **T103** Reescrever `DeckListScreen` no frame Lista de Decks (Clean)
  - US: US-08
  - RN: n/a (tela após verde de T101)
  - Teste: `test/presentation/deck_list_screen_test.dart` (ajustar copy de chrome se mudar)
  - Depends: T100

- [x] **T104** Reescrever `DeckDetailScreen` no frame Visualização de Card (detalhe do deck: lista, FAB, Estudar, menu)
  - US: US-08
  - RN: n/a (tela)
  - Teste: `test/presentation/deck_detail_screen_test.dart`
  - Depends: T100

## Fora desta feature

Trocar fórmulas SM-2; viewer de um card; áudio/imagem; bottom nav.
