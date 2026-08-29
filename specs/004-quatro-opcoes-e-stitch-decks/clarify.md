# Clarify — 004-quatro-opcoes-e-stitch-decks

> P-10: perguntas **fechadas** e respostas **antes** do `plan.md`. Não assumir no código.

---

## Perguntas

### Q1 — Mapeamento das 4 opções de estudo para SM-2

A UI passa a ter 4 botões. O domínio SM-2 continua com `grade` em `[0, 5]`.

- [x] Não lembro → 0 (falha, refila) · Lembrei com dificuldade → 4 (acerto, não refila; EF não muda) · Lembrei → 5 · Conheço → 5 (os dois últimos ficam iguais no algoritmo)
- [ ] Não lembro → 0 · Lembrei com dificuldade → 3 (refila hoje) · Lembrei → 4 · Conheço → 5
- [ ] Não lembro → 0 · Lembrei com dificuldade → 4 · Lembrei → 4 · Conheço → 5

**Decisão:** Opção 1 (hard_no_requeue).  
**Motivo:** Produto: só “Não lembro” volta na mesma sessão. “Lembrei com dificuldade” encerra o card hoje (q=4, EF inalterado). “Lembrei” e “Conheço” são o mesmo q=5 (EF +0.10). Fórmulas SM-2 não mudam.

---

## Lacunas ainda abertas

| Lacuna | Dono | Status |
|--------|------|--------|
| Nenhuma | — | fechada |
