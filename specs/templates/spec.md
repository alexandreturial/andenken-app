# Spec — NNN-nome

> **Feature:** NNN-nome
> **Status:** rascunho
> **Princípios:** [`docs/constitution.md`](../../docs/constitution.md)
> **Produto:** [`docs/PRODUCT.md`](../../docs/PRODUCT.md)
> **Contrato v1 (não duplicar):** [`docs/spec.md`](../../docs/spec.md)
> **Clarify:** [`clarify.md`](clarify.md) — preencher **antes** do plan

A v1 permanece congelada. Este arquivo descreve só o **delta**. Se a feature alterar entidade, RN ou aceite da v1, atualizar também `docs/spec.md` (constitution §6).

---

## 1. Problema

O que o usuário não consegue fazer hoje.

## 2. Fora desta feature

O que **não** entra. Não reabrir RNs da v1 (constitution §4) sem atualizar o spec global.

## 3. User stories

| ID | Como… | Quero… | Para… |
|----|--------|---------|--------|
| US- | | | |

## 4. Regras de negócio

| ID | Regra | Relação com a v1 |
|----|--------|------------------|
| RN- | | Nova / altera RN-xx de `docs/spec.md` |

Não inventar RN no código. Se faltar definição → `clarify.md`.

## 5. Telas e rotas

| Rota | Frame Stitch | Notas |
|------|----------------|-------|
| | | Spec vence Stitch. Estudo: 4 opções mapeadas para SM-2 0–5. |

Tela nova: recorte em `docs/stitch/NNN-nome/DIFF.md` se não couber no [DIFF da v1](../../docs/stitch/DIFF.md).

## 6. Aceite

- [ ] …
- [ ] Testes das RNs novas (P-09, fakes). Sem mock do SDK Firebase.

## 7. Impacto na v1

O que muda em entidades, Firestore, SM-2 ou rotas já entregues. Se nada, escrever “nenhum”.
