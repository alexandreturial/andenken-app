# Plan — 005-stitch-lista-e-estudo

> Delta vs [`docs/plan.md`](../../docs/plan.md). Clarify fechado.

---

## 1. O que muda

- Frame `/decks`: Lista de Decks (densa), não Clean.
- Frame estudo: Visualização de Card.
- Firestore: `users/{uid}/meta/studyStats`.
- Tap no deck → study. Bottom nav. Sem FAB.

Reusar: SM-2, 4 opções, rotas, `CardReview`.

## 2. Domínio / data

- `DeckMastery.fromCards`
- `StudyStats` + `RecordStudyDay` (puro) + persistência
- `StudyStatsRepository` / fake / Firestore
- Regras: `match /users/{uid}/meta/{docId}`

## 3. Rotas e presentation

| Rota | Notifier | Tela |
|------|----------|------|
| `/decks` | `DeckListNotifier` (+ mastery, streak, cardCount) | `DeckListScreen` |
| `/decks/:id/study` | `StudyNotifier` + `RecordStudyDay` | `StudyScreen` |
| `/decks/:id` | inalterado | detalhe (editar) |

## 4. Stitch (MCP obrigatório)

1. Ler `.cursor/mcp.json` (key local; nunca no git).
2. Se o namespace `stitch` existir no chat: `list_screens` + `get_screen`.
3. Senão: HTTP JSON-RPC `https://stitch.googleapis.com/mcp` (`initialize`, `tools/call`).
4. Telas: `ffce7272f94244d2ae0940cd0baae1bd`, `ebc67888eb24422cba69955b9bbeb31f`.
5. Baixar `htmlCode` + `screenshot`. Reescrever com atoms.

DIFF: [`docs/stitch/DIFF.md`](../../docs/stitch/DIFF.md).

## 5. Testes

- `test/domain/deck_mastery_test.dart`
- `test/domain/record_study_day_test.dart`
- Widget lista/estudo (tap, nav, 4 labels)

## 6. Dependências

Nenhuma.
