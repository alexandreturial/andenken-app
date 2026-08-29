# Plan — 004-quatro-opcoes-e-stitch-decks

> **Delta** em relação à v1 ([`docs/plan.md`](../../docs/plan.md)).
> Clarify Q1 fechado em [`clarify.md`](clarify.md).

---

## 1. O que muda

- UI de estudo: 4 opções mapeadas para `grade` 0 / 4 / 5 / 5.
- Layout de `/decks` e `/decks/:deckId` no padrão Stitch das telas de auth (não `AppPageTemplate` genérico).
- Contrato v1 (copy de estudo + DIFF), não o algoritmo.

O que **não** muda: Firebase, rotas, entidades, `CardReview`, `StudyNotifier.grade(int)`, flavors.

## 2. Domínio / data

- Entidades novas ou campos novos: nenhum
- Use-cases: nenhum
- Repositórios / Firestore: nenhum
- SM-2: fórmulas intactas; mapeamento de UI em [`algoritmo-SM-2.md`](../../docs/algoritmo-SM-2.md) §3.1

## 3. Rotas e presentation

| Rota | Notifier | Tela |
|------|----------|------|
| `/decks/:deckId/study` | `StudyNotifier` (inalterado) | `StudyScreen` + `StudyChoice` mapper |
| `/decks` | `DeckListNotifier` (inalterado) | `DeckListScreen` reescrita |
| `/decks/:deckId` | `DeckDetailNotifier` (inalterado) | `DeckDetailScreen` reescrita |

Arquivo novo: `lib/presentation/study/study_choice.dart`.

## 4. Stitch

- Frames: Lista de Decks (Clean) `8bd6aff9cc3f47f689384e06196f578c`; Visualização de Card; Estudo de Cards (Clean) só no pad de 4 botões.
- Tokens novos: nenhum (`DESIGN.md` da v1).
- DIFF: [`docs/stitch/DIFF.md`](../../docs/stitch/DIFF.md)

Spec vence Stitch. Não colar export Flutter/HTML em `lib/`.

## 5. Testes

- Fakes novos: nenhum
- Testes: `test/presentation/study_choice_test.dart` (RN-U01/U02); `study_screen_test.dart` (4 labels, refila só em Não lembro); widget tests de decks se a copy de chrome mudar
- QA: [`docs/qa-manual.md`](../../docs/qa-manual.md) US-05

## 6. Dependências

| Pacote | Por quê | Alternativa rejeitada |
|--------|---------|------------------------|
| (nenhum) | | |
