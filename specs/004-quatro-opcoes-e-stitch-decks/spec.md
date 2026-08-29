# Spec — 004-quatro-opcoes-e-stitch-decks

> **Feature:** 004-quatro-opcoes-e-stitch-decks
> **Status:** pronto
> **Princípios:** [`docs/constitution.md`](../../docs/constitution.md)
> **Produto:** [`docs/PRODUCT.md`](../../docs/PRODUCT.md)
> **Contrato v1 (não duplicar):** [`docs/spec.md`](../../docs/spec.md)
> **Clarify:** [`clarify.md`](clarify.md)

A v1 permanece congelada no algoritmo. Este arquivo descreve o **delta**: 4 opções na UI de estudo (mapeadas para SM-2 0–5) e layout Stitch das rotas `/decks` e `/decks/:deckId`.

---

## 1. Problema

A sessão de estudo expõe 6 notas 0–5; o usuário quer 4 opções em português. As telas Lista de Decks e Visualização de Card ainda não seguem o padrão visual Stitch das telas de auth (hierarquia, glow, cards).

## 2. Fora desta feature

- Trocar o SM-2 por escala de 4 notas no domínio.
- Telas de estudo áudio/imagem, bottom nav, tags, intervalos na UI.
- CRUD novo, entidades, Firestore.
- Viewer de um único card no lugar do detalhe do deck.

## 3. User stories

| ID | Como… | Quero… | Para… |
|----|--------|---------|--------|
| US-07 | User | revisar com 4 opções (Não lembro / Lembrei com dificuldade / Lembrei / Conheço) | escolher mais rápido, sem 6 botões |
| US-08 | User | ver a lista de decks e o detalhe do deck no layout Stitch | reconhecer o app frente aos frames |

## 4. Regras de negócio

| ID | Regra | Relação com a v1 |
|----|--------|------------------|
| RN-U01 | A UI de estudo oferece exatamente 4 opções, nesta ordem: Não lembro, Lembrei com dificuldade, Lembrei, Conheço. | Nova (presentation). Não altera RN-S03. |
| RN-U02 | Mapeamento para `grade` SM-2: Não lembro → 0; Lembrei com dificuldade → 4; Lembrei → 5; Conheço → 5. A UI nunca envia 1, 2 ou 3. | Nova. Clarify Q1. |
| RN-U03 | RN-S08 continua: `grade < 4` reenfileira. Com este mapeamento, só “Não lembro” refila na sessão. | Não altera RN-S08; restringe o que a UI emite. |
| RN-S03 | `grade` no domínio permanece inteiro em `[0, 5]`. `CardReview` não muda. | Inalterada. |

Não inventar RN no código. Se faltar definição → `clarify.md`.

## 5. Telas e rotas

| Rota | Frame Stitch | Notas |
|------|----------------|-------|
| `/decks` | Lista de Decks (Clean) | Reescrever no padrão Login (glow, cards, tokens). Sem bento/mastery/streak/bottom nav. Logout no settings. Badge due real. |
| `/decks/:deckId` | Visualização de Card | Continua detalhe do deck (lista `frontText`, FAB, Estudar, menu). Frame é aproximação. |
| `/decks/:deckId/study` | Estudo de Cards (Clean) | Spec vence: “Mostrar resposta” + 4 opções (não 6, não Hard/Good/Easy). Sem intervalos na UI. |

Recorte no [DIFF da v1](../../docs/stitch/DIFF.md). Sem pasta `docs/stitch/004-…` (não há tela nova).

## 6. Aceite

- [ ] Frente → “Mostrar resposta” → 4 botões com os rótulos de RN-U01.
- [ ] “Não lembro” persiste q=0 e reapresenta o card na mesma sessão.
- [ ] “Lembrei com dificuldade”, “Lembrei” e “Conheço” encerram o card na sessão (q ≥ 4).
- [ ] “Lembrei” e “Conheço” produzem o mesmo `grade` 5 (teste do mapper).
- [ ] Lista de decks e detalhe reconhecíveis frente aos frames (hierarquia, tokens, estados). Não pixel-perfect.
- [ ] Testes das RNs novas (P-09, fakes). Sem mock do SDK Firebase.

## 7. Impacto na v1

- US-05 / §7 da sessão: 4 opções na UI em vez de 6 botões 0–5.
- `docs/spec.md`, `PRODUCT.md`, `algoritmo-SM-2.md` (só mapeamento de UI), `stitch/DIFF.md`, `qa-manual.md`, P-08, `plan.md` §1.1, `AGENTS.md`.
- Entidades, Firestore, fórmulas SM-2, rotas: nenhum.
