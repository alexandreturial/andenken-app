# Spec — 005-stitch-lista-e-estudo

> **Feature:** 005-stitch-lista-e-estudo
> **Status:** pronto
> **Clarify:** [`clarify.md`](clarify.md)

Delta sobre a v1 + 004: lista densa Stitch, estudo = Visualização de Card, mastery/streak/nav.

---

## 1. Problema

As telas `/decks` e `/study` não batem com os frames densos (Your Decks, mastery, streak, bottom nav, FLIP CARD).

## 2. Fora desta feature

- Pixel-perfect vs HTML. Foto de perfil, hints, intervalos 1m/1d/4d na UI.
- `ReviewLog`. Bottom nav em login/forms.
- Trocar as 4 opções de estudo da 004.

## 3. User stories

| ID | Como… | Quero… | Para… |
|----|--------|---------|--------|
| US-09 | User | ver lista e estudo iguais aos frames densos | reconhecer o Stitch |
| US-10 | User | tocar o deck e estudar | não passar pelo detalhe |
| US-11 | User | ver mastery, cards left e streak | saber o que revisar hoje |

## 4. Regras de negócio

| ID | Regra | Relação com a v1 |
|----|--------|------------------|
| RN-M01 | `masteryPercent = round(100 * naoDue / total)`; `total == 0` → 0. `naoDue` = cards com `nextReviewAt` depois do fim do dia local. “cards left” = due. | Nova |
| RN-K01 | `users/{uid}/meta/studyStats`: `currentStreak`, `lastStudyLocalDate` (`yyyy-MM-dd`). Após persistir uma revisão: mesmo dia → não muda; dia seguinte → +1; pulou dia → 1. Sem ReviewLog. | Nova |
| RN-K02 | Bolinhas M–S: preenchidas se a data daquele weekday **da semana local corrente** está em `[lastStudy - (streak-1) dias, lastStudy]`. Sem lastStudy → todas vazias. | Nova |
| RN-N01 | Bottom nav (lista e estudo): Decks → `/decks`; Create → `/decks/new`; Study → deck com mais due (empate `createdAt`); sem decks → `/decks`. | Nova |
| RN-N02 | Tap no corpo do card do deck abre `/decks/:id/study`. Editar cards: `/decks/:id` via menu. | Altera US-03 navegação |
| RN-U01–U03 | 4 opções (feature 004) | Inalteradas |

## 5. Telas e rotas

| Rota | Frame Stitch | Notas |
|------|----------------|-------|
| `/decks` | Lista de Decks `ffce7272f94244d2ae0940cd0baae1bd` | Dark. Botão + New Deck (sem FAB). `more_vert` no DIFF. |
| `/decks/:deckId/study` | Visualização de Card `ebc67888eb24422cba69955b9bbeb31f` | FLIP + 4 opções (não Hard/Good/Easy). Sem hint/tag. |

**MCP (passo obrigatório da UI):** `.cursor/mcp.json` → `list_screens` / `get_screen` (ferramenta Cursor ou HTTP `https://stitch.googleapis.com/mcp`). HTML + screenshot **antes** de reescrever. Sem colar export em `lib/`.

## 6. Aceite

- [ ] Lista reconhecível frente ao frame denso (header ANDENKEN, Your Decks, New Deck, mastery, streak, nav).
- [ ] Tap no deck abre estudo; menu Editar abre detalhe.
- [ ] Estudo reconhecível frente a Visualização de Card; 4 opções; FLIP CARD.
- [ ] Testes RN-M01 / RN-K01 (P-09, fakes).

## 7. Impacto na v1

- Spec §7.1, DIFF, plan Firestore `meta/studyStats`, regras, qa-manual.
- Rotas iguais. Entidade Card/Deck sem campos novos.
