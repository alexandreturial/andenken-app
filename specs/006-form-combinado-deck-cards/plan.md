# Plan — 006-form-combinado-deck-cards

> Delta vs [`docs/plan.md`](../../docs/plan.md). Clarify fechado.

---

## 1. O que muda

- `/decks/new` e `/decks/:id/edit` usam o mesmo `DeckFormScreen` (nome + tiles de card).
- Rotas `cards/new` e `cards/:cardId/edit` saem; `CardFormScreen` / `CardFormNotifier` saem.
- Detalhe: FAB, empty CTA e tap/Editar abrem `/edit`.

Reusar: `CreateDeck`, `RenameDeck`, `CreateCard`, `UpdateCard`, RN-D01, RN-C01, atoms, tiles da lista de rascunhos.

## 2. Domínio / data

- Entidades: nenhuma.
- Use-cases: reusar os quatro acima. Sem orquestrador de domínio.
- `DeckFormNotifier.submit(name, drafts)` valida RN-F01 **antes** de persistir; depois create/rename + update/create cards.
- Firestore / SM-2: sem mudança.

## 3. Rotas e presentation

| Rota | Notifier | Tela |
|------|----------|------|
| `/decks/new` | `DeckFormNotifier` | `DeckFormScreen` (create) |
| `/decks/:deckId/edit` | `DeckFormNotifier` | `DeckFormScreen` (edit) |
| `/decks/:deckId` | `DeckDetailNotifier` | CTAs → `/edit` |

## 4. Stitch

- Frame: **Cadastrar Decks e Cards**. Tiles: Cadastrar Múltiplos Cards (Dark).
- Tokens: `DESIGN.md` da v1.
- DIFF: [`docs/stitch/DIFF.md`](../../docs/stitch/DIFF.md) (sem pasta `docs/stitch/006`).
- MCP: `list_screens` / `get_screen` se o namespace existir; senão reescrever com atoms já usados.
- Recorte: sem Live Preview, tags, imagens, bottom nav no form.

## 5. Testes

- `test/presentation/deck_form_notifier_test.dart` (RN-F01, US-12, US-13)
- `test/presentation/deck_form_screen_test.dart`
- `test/presentation/deck_detail_screen_test.dart`
- Remover `card_form_notifier_test.dart`
- QA: [`docs/qa-manual.md`](../../docs/qa-manual.md) US-03 / US-04

## 6. Dependências

Nenhuma.
