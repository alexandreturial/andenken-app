# Spec — Andenken v1

> **Tipo:** Artefato de especificação (GitHub Spec Kit)
> **Versão:** 1.7.0
> **Princípios:** [`constitution.md`](constitution.md)
> **Algoritmo:** [`algoritmo-SM-2.md`](algoritmo-SM-2.md)

---

## 1. Visão do produto

Andenken é um app de flash cards para estudo pessoal. O usuário cria decks, adiciona cards frente/verso e os revisa no prazo calculado pelo SM-2.

**Problema:** esquecer conteúdo estudado sem um intervalo de revisão.

**Promessa da v1:** cadastrar material e estudá-lo no dia certo, com SM-2 (domínio 0–5; UI com 4 opções).

---

## 2. Atores

| Ator | Descrição |
|------|-----------|
| Visitante | Não autenticado. Só acessa login e cadastro. |
| User | Conta Firebase Auth (email + senha ou Google). Dono exclusivo dos próprios Decks e Cards. |

Não há papéis de admin, professor ou colaborador na v1.

---

## 3. Entidades

IDs de Deck e Card são strings UUID geradas no cliente. ID de User é o `uid` do Firebase Auth.

### 3.1 User

Não há coleção `users`. O domínio mapeia o usuário autenticado.

| Campo | Tipo | Origem | Descrição |
|-------|------|--------|-----------|
| `id` | `string` | Auth `uid` | Identificador |
| `email` | `string` | Auth | Email da conta |
| `createdAt` | `Date` | Auth `metadata.creationTime` | Criação da conta |

### 3.2 Deck

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | `string` (uuid) | sim | Identificador |
| `userId` | `string` | sim | `uid` do dono |
| `name` | `string` | sim | Nome visível (1–80 caracteres, trimmed) |
| `cards` | `Card[]` | não | Agregado em memória; no Firestore é subcoleção |
| `createdAt` | `Date` | sim | Criação |
| `updatedAt` | `Date` | não | Última alteração do Deck (não dos Cards) |

### 3.3 Card

| Campo | Tipo | Default | Descrição |
|-------|------|---------|-----------|
| `id` | `string` (uuid) | gerado | Identificador |
| `deckId` | `string` (uuid) | — | Deck pai |
| `frontText` | `string` | — | Frente / pergunta (1–500, trimmed) |
| `backText` | `string` | — | Verso / resposta (1–2000, trimmed) |
| `repetitions` | `int` | `0` | Acertos consecutivos (`grade >= 3`) |
| `intervalDays` | `int` | `0` | Intervalo atual em dias |
| `easeFactor` | `double` | `2.5` | Fator de facilidade (piso `1.3`, 2 casas) |
| `nextReviewAt` | `Date` | `createdAt` | Próxima revisão; card novo está due imediatamente |
| `lastReviewedAt` | `Date \| null` | `null` | Última revisão |
| `createdAt` | `Date` | agora | Criação |
| `updatedAt` | `Date` | agora | Última alteração |

### 3.4 Mapeamento SM-2

O algoritmo fala `front`, `back`, `repetition`, `interval`. O domínio usa os nomes da tabela acima.

| Domínio | SM-2 |
|---------|------|
| `frontText` | `front` |
| `backText` | `back` |
| `repetitions` | `repetition` |
| `intervalDays` | `interval` |
| `easeFactor` | `easeFactor` |
| `nextReviewAt` | `nextReviewAt` |
| `lastReviewedAt` | `lastReviewedAt` |

O use-case `CardReview` lê/escreve os campos do domínio. A UI nunca usa os nomes do algoritmo.

### 3.5 Fora do modelo v1

- `ReviewLog`
- Imagem, dica, tags, áudio
- `description`, cor ou capa no Deck
- Soft delete / `deletedAt`
- Compartilhamento

---

## 4. Relacionamentos

```
User 1 ── * Deck 1 ── * Card
```

- Todo Deck tem exatamente um `userId`.
- Todo Card tem exatamente um `deckId`.
- Apagar um Deck apaga todos os Cards da subcoleção.
- Mover Card entre Decks não existe na v1.

---

## 5. Regras de negócio

### Auth

| ID | Regra |
|----|--------|
| RN-A01 | Cadastro exige email válido e senha com no mínimo 6 caracteres (limite do Firebase Auth). |
| RN-A02 | Login exige email + senha corretos. Erro de credencial não revela se o email existe. |
| RN-A03 | Sessão persiste até logout explícito (Firebase Auth persistence padrão no mobile). |
| RN-A04 | Rotas autenticadas redirecionam Visitante para `/login`. Rotas de auth redirecionam User para `/decks`. |
| RN-A05 | Continue with Google (Login e Cadastro) cria a conta se o email ainda não existir e entra. Cancelar o seletor Google não é erro e não navega. O mesmo use-case nas duas telas. |

### Deck

| ID | Regra |
|----|--------|
| RN-D01 | `name` não pode ser vazio após trim. Máximo 80 caracteres. |
| RN-D02 | User só lista, cria, edita e apaga Decks com o próprio `userId`. |
| RN-D03 | Hard delete do Deck remove o documento e todos os Cards da subcoleção. |
| RN-D04 | Editar `name` atualiza `updatedAt`. Não altera Cards. |

### Card

| ID | Regra |
|----|--------|
| RN-C01 | `frontText` e `backText` não podem ser vazios após trim. |
| RN-C02 | Card novo nasce due: `easeFactor = 2.5`, `repetitions = 0`, `intervalDays = 0`, `nextReviewAt = createdAt`, `lastReviewedAt = null`. |
| RN-C03 | Editar frente/verso não reseta o SM-2. |
| RN-C04 | Hard delete remove só aquele Card. |
| RN-C05 | User só acessa Cards de Decks próprios. |

### Estudo (SM-2)

Fonte normativa: [`algoritmo-SM-2.md`](algoritmo-SM-2.md). Resumo operacional:

| ID | Regra |
|----|--------|
| RN-S01 | Card está **due** quando `nextReviewAt <= agora` (início do dia local do dispositivo, ver §7). |
| RN-S02 | A sessão de um Deck é a fila de Cards due daquele Deck, ordem `nextReviewAt` ascendente, desempate `createdAt`. |
| RN-S03 | `grade` é inteiro em `[0, 5]`. Valor inválido é rejeitado antes do algoritmo. |
| RN-S04 | Aplicar grade chama `CardReview` (função pura) e persiste o Card retornado. |
| RN-S05 | `grade >= 3` incrementa `repetitions` e avança o intervalo (1 dia, depois 6, depois `round(intervalDays * easeFactor)`). |
| RN-S06 | `grade < 3` zera `repetitions`, `intervalDays = 1`, aplica a fórmula do EF mesmo assim. |
| RN-S07 | `easeFactor` nunca fica abaixo de `1.3`. |
| RN-S08 | **RN-06 do SM-2:** após a sessão, Cards com `grade < 4` voltam à fila do mesmo dia até o User responder `grade >= 4`. |
| RN-S09 | Revisão atrasada não recebe penalidade extra. Aplica SM-2 normalmente. |
| RN-S10 | Deck sem Cards due mostra empty state de “nada para revisar hoje”. |

### Lista e sessão (005)

| ID | Regra |
|----|--------|
| RN-M01 | `masteryPercent = round(100 * naoDue / total)`; deck vazio → 0. “cards left” = due. |
| RN-K01 | Streak em `users/{uid}/meta/studyStats`. Após review: mesmo dia local não muda; dia seguinte +1; pulou dia → 1. |
| RN-N01 | Bottom nav: Decks `/decks`; Create `/decks/new`; Study = deck com mais due (empate `createdAt`). |
| RN-N02 | Tap no card do deck abre `/decks/:id/study`. |

### Form combinado (006)

| ID | Regra |
|----|--------|
| RN-F01 | No form combinado: rascunho com frente e verso em branco é ignorado. Rascunho com só um lado preenchido (após trim) aborta o submit inteiro (nenhuma escrita). Card com os dois lados passa por RN-C01. Nome do deck continua RN-D01. Create só com nome grava deck vazio. |
| RN-F02 | Cards só são criados em `/decks/new` e `/decks/:deckId/edit`. Não existem `/decks/:deckId/cards/new` nem `/decks/:deckId/cards/:cardId/edit`. |

---

## 6. User stories e aceite

### US-01 — Cadastrar conta

**Como** Visitante, **quero** criar conta com email e senha, **para** guardar meus decks.

**Aceite:**

- [ ] Formulário com email, senha e confirmação de senha.
- [ ] Senhas diferentes bloqueiam o submit com mensagem.
- [ ] Sucesso autentica e navega para a lista de Decks.
- [ ] Email já cadastrado mostra erro inteligível.
- [ ] Continue with Google cria a conta (se nova) e abre `/decks`.

### US-02 — Entrar e sair

**Como** User, **quero** login e logout, **para** acessar só a minha conta.

**Aceite:**

- [ ] Login válido abre `/decks`.
- [ ] Credencial inválida mostra erro e não navega.
- [ ] Logout volta para `/login` e impede voltar às rotas autenticadas pelo back.
- [ ] Continue with Google (conta nova ou já existente) abre `/decks`. Cancelar o seletor permanece na tela sem erro.

### US-03 — CRUD de Deck

**Como** User, **quero** criar, listar, renomear e apagar decks, **para** organizar o material.

**Aceite:**

- [ ] Lista vazia mostra CTA para criar o primeiro Deck.
- [ ] Criar Deck com nome válido aparece na lista. Cards no mesmo form são opcionais (RN-F01).
- [ ] Nome vazio não salva.
- [ ] Toque no card do deck abre a sessão de estudo; Editar no menu abre `/decks/:deckId`.
- [ ] Renomear atualiza só aquele Deck.
- [ ] Apagar pede confirmação; após confirmar, Deck e Cards somem.
- [ ] User A não vê Decks do User B.

### US-04 — CRUD de Card

**Como** User, **quero** criar, listar, editar e apagar cards de um deck, **para** montar o conteúdo de estudo.

**Aceite:**

- [ ] Dentro do Deck, lista de Cards mostra `frontText`.
- [ ] Cards entram só em `/decks/new` e `/decks/:deckId/edit` (lista de forms frente/verso; add/remove rascunhos novos). Frente e verso obrigatórios em rascunho preenchido; linha em branco é ignorada (RN-F01). Editar card existente é no form de editar o deck.
- [ ] Editar persiste frente/verso sem zerar SM-2.
- [ ] Apagar pede confirmação e remove só aquele Card.
- [ ] Card novo entra como due na próxima sessão.

### US-05 — Estudar o Deck

**Como** User, **quero** revisar os cards due com 4 opções, **para** espaçar o estudo.

**Aceite:**

- [ ] A sessão mostra só Cards due daquele Deck.
- [ ] Fluxo: frente → FLIP CARD / Mostrar resposta → 4 opções (Não lembro / Lembrei com dificuldade / Lembrei / Conheço).
- [ ] Cada opção persiste o `grade` SM-2 mapeado (0 / 4 / 5 / 5).
- [ ] Cards com `grade < 4` reaparecem na mesma sessão até `grade >= 4` (na UI, só “Não lembro”).
- [ ] Fila vazia encerra a sessão com resumo (quantos revisados).
- [ ] Deck sem due não inicia sessão; mostra empty state.

### US-06 — Ver o que está due

**Como** User, **quero** ver na lista de Decks mastery, cards left e streak, **para** saber o que estudar hoje.

**Aceite:**

- [ ] Cada item mostra contagem total, mastery (RN-M01) e due (“cards left”).
- [ ] A contagem muda depois de uma sessão.
- [ ] Daily Streak reflete `studyStats` (RN-K01).

---

## 7. Telas e navegação

Rotas autenticadas exigem User. Rotas `/login` e `/register` exigem Visitante.

| Rota | Tela | Quem |
|------|------|------|
| `/login` | Login (email, senha) | Visitante |
| `/register` | Cadastro | Visitante |
| `/decks` | Lista de Decks + mastery + streak + nav + CTA criar | User |
| `/decks/new` | Form criar Deck + cards opcionais | User |
| `/decks/:deckId` | Detalhe: lista de Cards + ações + CTA estudar | User |
| `/decks/:deckId/edit` | Form editar Deck (nome + cards existentes + rascunhos) | User |
| `/decks/:deckId/study` | Sessão SM-2 | User |

### 7.1 Mapeamento Stitch

Fonte visual oficial: Google Stitch via MCP (`stitch`). Tokens em [`docs/stitch/DESIGN.md`](stitch/DESIGN.md) → `lib/core/theme/app_theme.dart`. Recorte por rota (T075): [`docs/stitch/DIFF.md`](stitch/DIFF.md).

Projeto: **Andenken Flashcards** (`projects/10397297006861135646`).

| Tela no Stitch (nome exato) | Rota | Screen / estado |
|-----------------------------|------|-----------------|
| Login | `/login` | `LoginScreen` |
| Register | `/register` | `RegisterScreen` |
| Lista de Decks | `/decks` | `DeckListScreen` (densa; frame `ffce7272f94244d2ae0940cd0baae1bd`) |
| Lista de Decks (Clean) | `/decks` | variante light; 005 usa a densa |
| *(empty state ainda sem frame)* | `/decks` | empty state |
| Cadastrar Decks e Cards | `/decks/new` | `DeckFormScreen` (create; nome + tiles de card). Sem Live Preview, tags, imagens nem bottom nav. |
| Cadastrar Decks (Clean) | `/decks/new` | variante só-nome; 006 usa o combinado |
| *(ainda sem frame)* | `/decks/:deckId/edit` | `DeckFormScreen` (edit; mesmo form, cards existentes + rascunhos) |
| Visualização de Card | `/decks/:deckId/study` | `StudyScreen` (FLIP + 4 opções). Detalhe do deck continua lista em `/decks/:deckId`. |
| *(empty state ainda sem frame)* | `/decks/:deckId` | empty state |
| Cadastrar Múltiplos Cards (Dark) | tiles no form combinado | referência visual de add/remove; sem rota própria |
| Cadastrar Múltiplos Cards (Clean) | tiles no form combinado | variante sequencial; preferir Dark |
| Estudo de Cards (Clean) | `/decks/:deckId/study` | variante; 005 prefere Visualização de Card |
| *(fim / vazio ainda sem frame)* | `/decks/:deckId/study` | fases `done` / `empty` |
| *(ainda sem frame)* | dialog | confirmar exclusão |

**Fora da v1** (existem no Stitch, não implementar): Estudo de Cards - Áudio, Estudo de Cards - Imagem, Estudo de Cards - Áudio + Imagem, Andenken Logo (asset), frames `image.png`. No frame Login: Forgot? é só layout (reset de senha fora da v1). Continue with Google é aceite (RN-A05). No frame Register: Full Name não entra (User sem nome); confirmação de senha é do spec (US-01), não do Stitch; Continue with Google é aceite (RN-A05). No frame Lista de Decks o logout fica no `menu` (hamburger). `more_vert` no card do deck não está no frame (editar/renomear/apagar).

**Sessão de estudo (estados da tela):**

1. `loading` — carrega fila due.
2. `empty` — nenhum due.
3. `front` — mostra `frontText` + botão “FLIP CARD” / “Mostrar resposta”.
4. `back` — mostra `frontText` + `backText` + 4 botões (Não lembro / Lembrei com dificuldade / Lembrei / Conheço) mapeados em [`algoritmo-SM-2.md`](algoritmo-SM-2.md) §3.1.
5. `done` — resumo; tab Decks volta à lista.

**Due “hoje”:** comparar `nextReviewAt` com o fim do dia civil no fuso do dispositivo (`23:59:59.999` local). Cards com `nextReviewAt` neste instante ou no passado entram na fila.

---

## 8. Fluxos

### 8.1 Auth

```
Visitante → /login ou /register → Firebase Auth (email/senha ou Google) → /decks
User → logout → /login
```

### 8.2 CRUD

```
/decks → criar (nome + cards opcionais) → /decks
/decks/:id → editar (nome + cards) | apagar deck
/decks/:id → apagar card
```

### 8.3 Estudo

```
/decks/:id → estudar
  carregar due
  enquanto houver card na fila:
    frente → verso → grade
    CardReview + persistir
    se grade < 4: reenfileirar no fim
  resumo → /decks/:id
```

---

## 9. Erros e empty states

| Situação | Comportamento |
|----------|----------------|
| Sem rede no Auth | Mensagem de conexão; não navega |
| Sem rede no Firestore | Mensagem; dados em cache do Firestore podem aparecer |
| Deck/Card inexistente ou de outro user | Volta para `/decks` com erro |
| Validação de form | Erro inline; não chama repositório |
| Lista de Decks vazia | Ilustração + “Criar deck” |
| Deck sem Cards | CTA “Adicionar card”; botão estudar desabilitado |
| Deck com Cards mas sem due | “Nada para revisar hoje” |
| Confirmação de delete | Dialog; cancelar não apaga |

---

## 10. Fora de escopo (v1)

- Anônimo, Apple Sign-In, reset de senha avançado (pode existir o link nativo do Firebase depois; não é aceite)
- Compartilhar / colaborar / decks públicos
- Imagens, áudio, cloze, tags
- Estatísticas além do resumo da sessão e do badge due
- `ReviewLog`
- Import/export Anki
- Temas, i18n além de pt-BR
- Web, desktop e iOS como alvo oficial (iOS sem Firebase na v1)
- Projetos Firebase ou applicationIds distintos por flavor
- Soft delete
- Mover card entre decks
- Notificações push de due

---

## 11. Critérios de sucesso da v1

1. User cria conta, um Deck e pelo menos um Card.
2. Estuda com as 4 opções e o estado SM-2 persiste (reabrir o app mantém `nextReviewAt`).
3. No dia seguinte (ou com relógio avançado em teste), o Card due reaparece.
4. User B não lê dados do User A (regras de Firestore + teste manual com duas contas).
5. Testes unitários do `CardReview` cobrem a tabela de exemplo e os casos de borda do spec do algoritmo — escritos **antes** da implementação (P-09).
6. Cada RN de domínio tem teste unitário (fake, sem Firebase) derivado do aceite.
7. Cada rota da §7 é reconhecível frente ao frame Stitch correspondente (hierarquia, tokens, estados). Não é critério pixel-perfect.
