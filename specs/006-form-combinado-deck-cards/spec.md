# Spec — 006-form-combinado-deck-cards

> **Feature:** 006-form-combinado-deck-cards
> **Status:** pronto
> **Princípios:** [`docs/constitution.md`](../../docs/constitution.md)
> **Produto:** [`docs/PRODUCT.md`](../../docs/PRODUCT.md)
> **Contrato v1 (não duplicar):** [`docs/spec.md`](../../docs/spec.md)
> **Clarify:** [`clarify.md`](clarify.md)

Delta: um form para criar/editar Deck **e** Cards. A v1 separava as rotas.

---

## 1. Problema

Criar um deck e os cards exige duas telas (`/decks/new` depois `/decks/:id/cards/new`). O User quer nome + cards na mesma página, com só o nome obrigatório.

## 2. Fora desta feature

- Import JSON / Anki.
- Tags, Live Preview, imagem, dica.
- Transação Firestore (validar tudo; falha de rede no meio fica como a v1).
- Apagar card pelo form (continua no detalhe).
- Reabrir RN-D01 / RN-C01 / SM-2.

## 3. User stories

| ID | Como… | Quero… | Para… |
|----|--------|---------|--------|
| US-12 | User | criar deck e cards na mesma tela | não pular de form |
| US-13 | User | editar nome e cards (existentes + novos) em `/decks/:id/edit` | manter o material num só lugar |

## 4. Regras de negócio

| ID | Regra | Relação com a v1 |
|----|--------|------------------|
| RN-F01 | No form combinado: rascunho com frente **e** verso em branco é ignorado. Rascunho com só um lado preenchido (após trim) é inválido e **aborta o submit inteiro** (nenhuma escrita). Card com os dois lados passa por RN-C01. Nome do deck continua RN-D01. Create só com nome (todos os rascunhos em branco) grava deck vazio. | Nova; não altera RN-C01 |
| RN-F02 | Cards só são criados em `/decks/new` e `/decks/:deckId/edit`. Rotas `/decks/:deckId/cards/new` e `/decks/:deckId/cards/:cardId/edit` deixam de existir. | Altera US-04 / rotas §7 |

## 5. Telas e rotas

| Rota | Frame Stitch | Notas |
|------|----------------|-------|
| `/decks/new` | Cadastrar Decks e Cards | Nome obrigatório; tiles de card opcionais; 1 rascunho vazio + add. Sem Live Preview, tags, imagens, bottom nav. |
| `/decks/:deckId/edit` | mesmo form | Nome + cards existentes (sem remover no form) + rascunhos novos. |
| `/decks/:deckId` | inalterado | Lista + apagar. FAB / “Adicionar card” / tap / Editar → `/edit`. |

Spec vence Stitch. Tiles visuais podem reusar “Cadastrar Múltiplos Cards (Dark)”.

## 6. Aceite

- [ ] `/decks/new`: nome válido + rascunhos em branco cria deck vazio e volta.
- [ ] `/decks/new`: nome + cards completos grava deck e cards.
- [ ] Nome vazio não salva.
- [ ] Rascunho parcial (só frente ou só verso) mostra erro e não grava nada.
- [ ] `/decks/:id/edit` carrega nome e cards; Save atualiza nome, atualiza cards (SM-2 intacto) e cria rascunhos novos.
- [ ] Detalhe não abre mais `CardFormScreen`; CTAs vão para `/edit`.
- [ ] Apagar card no detalhe com confirmação (US-04).
- [ ] Testes RN-F01 (P-09, fakes). Sem mock do SDK Firebase.

## 7. Impacto na v1

- Rotas: some `cards/new` e `cards/:cardId/edit`; `/decks/new` e `/edit` passam a ser o form combinado.
- US-03 / US-04 / §7 / §7.1 / §8.2 em [`docs/spec.md`](../../docs/spec.md).
- [`docs/plan.md`](../../docs/plan.md) §5; [`docs/stitch/DIFF.md`](../../docs/stitch/DIFF.md); [`docs/qa-manual.md`](../../docs/qa-manual.md).
- Entidades e Firestore sem campos novos.
