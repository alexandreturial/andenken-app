# Specs — features novas

A **v1 está congelada** em [`docs/spec.md`](../docs/spec.md), [`docs/plan.md`](../docs/plan.md), [`docs/tasks.md`](../docs/tasks.md) e [`docs/algoritmo-SM-2.md`](../docs/algoritmo-SM-2.md). Não fatiar auth / decks / estudo em `001`–`003`.

Feature nova = pasta `specs/NNN-nome/` (primeiro número livre: **006**). Copia os templates, preenche, **clarify antes do plan**. Feature atual: [`005-stitch-lista-e-estudo/`](005-stitch-lista-e-estudo/).

## Contrato com a v1

- A feature *referencia* a v1. Só altera `docs/spec.md` / `plan.md` / `algoritmo-SM-2.md` se mudar entidade, RN ou stack (constitution §6).
- Spec vence Stitch. Tela nova: `docs/stitch/NNN-nome/DIFF.md` se o recorte não couber no [DIFF da v1](../docs/stitch/DIFF.md).
- Não inventar RN. Ambiguidade → `clarify.md` (P-10).
- QA da v1 continua em [`docs/qa-manual.md`](../docs/qa-manual.md). `acceptance.md` só se a US nova não couber lá. Não criar `qa/regression.md` vazio.

## Pasta

```
specs/NNN-nome/
  spec.md
  clarify.md
  plan.md
  checklist.md
  tasks.md
  analyze.md
```

Fluxo: specify → clarify → plan → checklist → tasks → analyze → implementar (P-09) → teste → QA.

## Templates

| Arquivo | Papel |
|---------|--------|
| [templates/spec.md](templates/spec.md) | US, RN, aceite. Delta, não cópia da v1. |
| [templates/clarify.md](templates/clarify.md) | Q&A fechadas **antes** do plan. |
| [templates/plan.md](templates/plan.md) | Delta: Firebase, rotas, pastas, Stitch. |
| [templates/checklist.md](templates/checklist.md) | Gates antes de tasks/código. |
| [templates/tasks.md](templates/tasks.md) | Tasks com `US` / `RN` / teste / `depends`. |
| [templates/analyze.md](templates/analyze.md) | Matriz RN ↔ plan ↔ tasks. |
