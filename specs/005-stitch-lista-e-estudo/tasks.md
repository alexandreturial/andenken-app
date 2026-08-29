# Tasks — 005-stitch-lista-e-estudo

> **TDD (P-09)** em regra.

- [x] **T110** Contrato v1 (spec §7.1, DIFF, plan Firestore, regras, qa-manual)
  - US: US-09–US-11
  - RN: RN-M01, RN-K01, RN-N01, RN-N02
  - Teste: n/a (docs)
  - Depends: —

- [x] **T111** `DeckMastery` vermelho → verde
  - US: US-11
  - RN: RN-M01
  - Teste: `test/domain/deck_mastery_test.dart`
  - Depends: T110

- [x] **T112** `RecordStudyDay` vermelho → verde
  - US: US-11
  - RN: RN-K01
  - Teste: `test/domain/record_study_day_test.dart`
  - Depends: T110

- [x] **T113** Repositório + regras `meta/studyStats`; `StudyNotifier` grava o dia
  - US: US-11
  - RN: RN-K01
  - Teste: fake + notifier se couber
  - Depends: T112

- [x] **T114** MCP: `get_screen` dos dois frames (HTML + PNG) **antes** da UI
  - US: US-09
  - RN: n/a
  - Teste: n/a
  - Depends: T110

- [x] **T115** `DeckListScreen` frame denso + nav; tap → study
  - US: US-09, US-10
  - RN: RN-N01, RN-N02, RN-M01, RN-K02
  - Teste: `test/presentation/deck_list_screen_test.dart`
  - Depends: T111, T113, T114

- [x] **T116** `StudyScreen` Visualização de Card + 4 opções + nav
  - US: US-09
  - RN: RN-U01
  - Teste: `test/presentation/study_screen_test.dart`
  - Depends: T114

## Fora

Pixel-perfect; ReviewLog; hint; 3 botões Anki.
