# Clarify — 005-stitch-lista-e-estudo

> P-10. Decisões fechadas no plan da feature (tap → study; mastery/streak/nav entram no spec).

---

## Perguntas

### Q1 — Fidelidade visual vs recorte da v1

- [x] Mastery, streak e bottom nav passam a ser aceite (spec muda)
- [ ] Só layout; sem streak/mastery/nav

**Decisão:** Aceite real.  
**Motivo:** Frames densos **Lista de Decks** e **Visualização de Card**.

### Q2 — Toque no deck

- [x] Tap no card → `/decks/:deckId/study`. Editar → `/decks/:deckId`
- [ ] Tap → detalhe (v1)

**Decisão:** Tap estuda; `more_vert` Editar/Renomear/Apagar.  
**Motivo:** Pedido de produto.

### Q3 — Onde é Visualização de Card

- [x] `StudyScreen` (`/decks/:deckId/study`)
- [ ] Detalhe do deck

**Decisão:** Frame de estudo. Lista de cards permanece no detalhe (US-04).

---

## Lacunas

| Lacuna | Status |
|--------|--------|
| Fórmulas RN-M01 / RN-K01 / RN-N01 | fechadas no spec |
