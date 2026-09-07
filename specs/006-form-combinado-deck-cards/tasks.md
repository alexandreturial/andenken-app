# Tasks — 006-form-combinado-deck-cards

> v1 (T000–T075) está encerrada em [`docs/tasks.md`](../../docs/tasks.md). Esta lista é só da feature.
> **TDD (P-09):** task de regra = teste vermelho → implementação → verde → refactor → UI Stitch.

---

## Fase A — contrato

- [x] **T120** Contrato v1 (spec §7, DIFF, plan rotas, qa-manual) + pasta 006
  - US: US-12, US-13
  - RN: RN-F01, RN-F02
  - Teste: n/a (docs)
  - Depends: —

## Fase B — notifier

- [x] **T121** `DeckFormNotifier` vermelho → verde (create opcional, parcial aborta, edit nome+cards)
  - US: US-12, US-13
  - RN: RN-F01
  - Teste: `test/presentation/deck_form_notifier_test.dart`
  - Depends: T120

## Fase C — UI

- [x] **T122** `DeckFormScreen` combinado; rotas de card saem; detalhe aponta para `/edit`
  - US: US-12, US-13
  - RN: RN-F02
  - Teste: `test/presentation/deck_form_screen_test.dart`, `test/presentation/deck_detail_screen_test.dart`
  - Depends: T121

## Fora desta feature

Import JSON; Live Preview; tags; transação Firestore; apagar card no form.
