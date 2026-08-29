# Analyze — 004-quatro-opcoes-e-stitch-decks

Matriz de cobertura **depois** de spec, plan e tasks.

---

## RN ↔ plan ↔ tasks ↔ teste

| RN | Plan (§) | Task | Teste | Status |
|----|----------|------|-------|--------|
| RN-U01 | §3 presentation | T101, T102 | `study_choice_test.dart`, `study_screen_test.dart` | ok |
| RN-U02 | §2 SM-2 map, §3 | T101, T102 | `study_choice_test.dart` | ok |
| RN-U03 | §3 StudyNotifier intacto | T102 | `study_screen_test.dart` (Não lembro refila) | ok |
| RN-S03 | §2 sem mudança | — | `card_review_test.dart` (já existe) | ok |

## US ↔ aceite ↔ tasks

| US | Aceite no spec | Tasks | Status |
|----|----------------|-------|--------|
| US-07 | 4 botões, mapeamento, refila só Não lembro | T100–T102 | ok |
| US-08 | decks/detail reconhecíveis vs Stitch | T103, T104 | ok |

## v1

| Impacto na v1 | docs globais atualizados? |
|---------------|---------------------------|
| US-05 / §7 estudo (UI); P-08; DIFF; qa-manual; SM-2 só §3.1 | sim |
| Entidade / Firestore / fórmulas / rotas | n/a |

## Lacunas

- (nenhuma)
