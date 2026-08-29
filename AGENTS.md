# AGENTS.md — Andenken

Manual operacional do agente. Princípios e restrições: [`docs/constitution.md`](docs/constitution.md). Não duplicar a constitution aqui.

## Fonte de verdade (nessa ordem)

1. [`docs/constitution.md`](docs/constitution.md) — princípios; em conflito, vence.
2. [`docs/PRODUCT.md`](docs/PRODUCT.md) — o que estamos construindo e o que está fora do MVP.
3. [`docs/spec.md`](docs/spec.md) — contrato da **v1** (entidades, RN, rotas, aceite).
4. [`docs/algoritmo-SM-2.md`](docs/algoritmo-SM-2.md) — fórmulas SM-2.
5. [`docs/plan.md`](docs/plan.md) — stack, pastas, Firebase, rotas técnicas.
6. Feature atual em [`specs/NNN-nome/`](specs/README.md) — se existir; senão a v1 acima.
7. [`docs/tasks.md`](docs/tasks.md) — histórico da v1. Features novas: `specs/NNN-nome/tasks.md`.
8. [`docs/stitch/DIFF.md`](docs/stitch/DIFF.md) — divergência Stitch vs spec (intencional ≠ bug).

## Antes de codar

1. Ler constitution, PRODUCT e o spec relevante (v1 e/ou `specs/NNN-*`).
2. Se a feature toca SM-2, ler `algoritmo-SM-2.md`.
3. Ler o plan (global e o delta da feature).
4. Identificar a task atual, dependências e o teste que a cobre.
5. Implementar **só** o escopo pedido.

Fluxo de feature nova: specify → **clarify** (P-10) → plan → checklist → tasks → analyze → implement (P-09) → `fvm flutter test` → QA.

## Never

- Inventar regra de negócio. Se faltar informação: dizer que o spec não define X. Não “assumir”.
- Alterar constitution ou spec para facilitar o código.
- Introduzir dependência sem justificativa no `plan.md`.
- Mudar arquitetura sem atualizar o plan (e o impacto nas tasks).
- Marcar task completa sem teste verde (regra de domínio/notifier) ou sem o aceite da task.
- Colar export Flutter/HTML do Stitch em `lib/`.
- Commitar API key do Stitch, `google-services.json` ou secrets.
- Trocar o SM-2 0–5 no domínio por 3 botões Hard/Good/Easy do Stitch. Spec vence; a UI mapeia 4 opções (feature 004). Registrar recorte no DIFF.

## Stitch

Tokens: [`docs/stitch/DESIGN.md`](docs/stitch/DESIGN.md) → `lib/core/theme/app_theme.dart`.  
Tela nova: puxar o frame no MCP, reescrever com atoms. Se Stitch e spec divergirem: spec vence e o DIFF registra o recorte. Feature com tela nova pode ter `docs/stitch/NNN-nome/DIFF.md`.

## TDD e flavors

P-09: teste vermelho → verde → refactor → UI. Fakes em `test/fakes/`. Sem mock do SDK Firebase.

```bash
fvm flutter test
fvm flutter run --flavor develop --dart-define=FLAVOR=develop
```

`flutter run` sem `--flavor` falha. Mesmo `applicationId` e mesmo Firebase nos três flavors.
