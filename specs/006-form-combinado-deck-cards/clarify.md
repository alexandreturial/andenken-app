# Clarify — 006-form-combinado-deck-cards

> P-10. Decisões fechadas antes do plan.

---

## Perguntas

### Q1 — Onde adicionar cards

- [x] Só em `/decks/new` e `/decks/:deckId/edit`. Remover `/cards/new` e `/cards/:cardId/edit`.
- [ ] Manter `/decks/:deckId/cards/new` para deck existente.
- [ ] Remover adicionar cards depois do create.

**Decisão:** Cards só entram no create e no edit do deck. `CardFormScreen` sai.  
**Motivo:** Pedido de produto: uma página com todos os forms.

### Q2 — Rascunho incompleto (só frente ou só verso)

- [x] Bloquear o save; nenhuma escrita (nem o deck).
- [ ] Ignorar o rascunho e gravar o resto.

**Decisão:** Erro `InvalidCardTextException`; aborta o submit inteiro.  
**Motivo:** RN-C01 continua valendo para qualquer card que o User tentou preencher.

### Q3 — Cards já existentes no edit

- [x] O form de editar deck carrega os cards atuais (editáveis) e aceita rascunhos novos.
- [ ] Edit deck só adiciona cards novos; editar frente/verso fica no detalhe.

**Decisão:** Edit combinado. Apagar card permanece no detalhe com confirmação (US-04).  
**Motivo:** Sem `CardFormScreen`, o edit de frente/verso precisa de um lugar.

---

## Lacunas

| Lacuna | Status |
|--------|--------|
| Import JSON / `Card.fromFile` | fora desta feature |
| Transação Firestore se card falhar após o deck | fora; validar tudo antes de persistir |
| Live Preview / tags / imagens do Stitch | recorte DIFF |
