# Spec — Andenken v1

> **Tipo:** Artefato de especificação (GitHub Spec Kit)
> **Versão:** 1.2.0
> **Princípios:** [`constitution.md`](constitution.md)
> **Algoritmo:** [`algoritmo-SM-2.md`](algoritmo-SM-2.md)

---

## 1. Visão do produto

Andenken é um app de flash cards para estudo pessoal. O usuário cria decks, adiciona cards frente/verso e os revisa no prazo calculado pelo SM-2.

**Problema:** esquecer conteúdo estudado sem um intervalo de revisão.

**Promessa da v1:** cadastrar material e estudá-lo no dia certo, com notas 0–5.

---

## 2. Atores

| Ator | Descrição |
|------|-----------|
| Visitante | Não autenticado. Só acessa login e cadastro. |
| User | Conta Firebase Auth (email + senha). Dono exclusivo dos próprios Decks e Cards. |

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

O use-case `ApplySM2` lê/escreve os campos do domínio. A UI nunca usa os nomes do algoritmo.

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
| RN-S04 | Aplicar grade chama `ApplySM2` (função pura) e persiste o Card retornado. |
| RN-S05 | `grade >= 3` incrementa `repetitions` e avança o intervalo (1 dia, depois 6, depois `round(intervalDays * easeFactor)`). |
| RN-S06 | `grade < 3` zera `repetitions`, `intervalDays = 1`, aplica a fórmula do EF mesmo assim. |
| RN-S07 | `easeFactor` nunca fica abaixo de `1.3`. |
| RN-S08 | **RN-06 do SM-2:** após a sessão, Cards com `grade < 4` voltam à fila do mesmo dia até o User responder `grade >= 4`. |
| RN-S09 | Revisão atrasada não recebe penalidade extra. Aplica SM-2 normalmente. |
| RN-S10 | Deck sem Cards due mostra empty state de “nada para revisar hoje”. |

---

## 6. User stories e aceite

### US-01 — Cadastrar conta

**Como** Visitante, **quero** criar conta com email e senha, **para** guardar meus decks.

**Aceite:**

- [ ] Formulário com email, senha e confirmação de senha.
- [ ] Senhas diferentes bloqueiam o submit com mensagem.
- [ ] Sucesso autentica e navega para a lista de Decks.
- [ ] Email já cadastrado mostra erro inteligível.

### US-02 — Entrar e sair

**Como** User, **quero** login e logout, **para** acessar só a minha conta.

**Aceite:**

- [ ] Login válido abre `/decks`.
- [ ] Credencial inválida mostra erro e não navega.
- [ ] Logout volta para `/login` e impede voltar às rotas autenticadas pelo back.

### US-03 — CRUD de Deck

**Como** User, **quero** criar, listar, renomear e apagar decks, **para** organizar o material.

**Aceite:**

- [ ] Lista vazia mostra CTA para criar o primeiro Deck.
- [ ] Criar Deck com nome válido aparece na lista.
- [ ] Nome vazio não salva.
- [ ] Renomear atualiza só aquele Deck.
- [ ] Apagar pede confirmação; após confirmar, Deck e Cards somem.
- [ ] User A não vê Decks do User B.

### US-04 — CRUD de Card

**Como** User, **quero** criar, listar, editar e apagar cards de um deck, **para** montar o conteúdo de estudo.

**Aceite:**

- [ ] Dentro do Deck, lista de Cards mostra `frontText`.
- [ ] Criar exige frente e verso.
- [ ] Editar persiste frente/verso sem zerar SM-2.
- [ ] Apagar pede confirmação e remove só aquele Card.
- [ ] Card novo entra como due na próxima sessão.

### US-05 — Estudar o Deck

**Como** User, **quero** revisar os cards due com notas 0–5, **para** espaçar o estudo.

**Aceite:**

- [ ] A sessão mostra só Cards due daquele Deck.
- [ ] Fluxo: frente → revelar verso → escolher grade 0–5.
- [ ] Cada grade persiste o novo estado SM-2.
- [ ] Cards com `grade < 4` reaparecem na mesma sessão até `grade >= 4`.
- [ ] Fila vazia encerra a sessão com resumo (quantos revisados).
- [ ] Deck sem due não inicia sessão; mostra empty state.

### US-06 — Ver o que está due

**Como** User, **quero** ver na lista de Decks quantos cards estão due, **para** saber o que estudar hoje.

**Aceite:**

- [ ] Cada item da lista mostra a contagem de Cards com `nextReviewAt` due.
- [ ] A contagem muda depois de uma sessão.

---

## 7. Telas e navegação

Rotas autenticadas exigem User. Rotas `/login` e `/register` exigem Visitante.

| Rota | Tela | Quem |
|------|------|------|
| `/login` | Login (email, senha) | Visitante |
| `/register` | Cadastro | Visitante |
| `/decks` | Lista de Decks + badge due + FAB criar | User |
| `/decks/new` | Form criar Deck | User |
| `/decks/:deckId` | Detalhe: lista de Cards + ações + CTA estudar | User |
| `/decks/:deckId/edit` | Form renomear Deck | User |
| `/decks/:deckId/cards/new` | Form criar Card | User |
| `/decks/:deckId/cards/:cardId/edit` | Form editar Card | User |
| `/decks/:deckId/study` | Sessão SM-2 | User |

### 7.1 Mapeamento Stitch

Fonte visual oficial: Google Stitch via MCP (`stitch`). Confirmar os nomes **exatos** dos frames na T016.

Projeto Stitch: Andenken (preencher URL/id do projeto quando existir).

| Tela no Stitch (nome sugerido) | Rota | Screen / estado |
|--------------------------------|------|-----------------|
| Login | `/login` | `LoginScreen` |
| Cadastro | `/register` | `RegisterScreen` |
| Lista de decks | `/decks` | `DeckListScreen` |
| Lista de decks vazia | `/decks` | empty state |
| Novo deck | `/decks/new` | `DeckFormScreen` (create) |
| Renomear deck | `/decks/:deckId/edit` | `DeckFormScreen` (rename) |
| Detalhe do deck | `/decks/:deckId` | `DeckDetailScreen` |
| Detalhe sem cards | `/decks/:deckId` | empty state |
| Novo card | `/decks/:deckId/cards/new` | `CardFormScreen` (create) |
| Editar card | `/decks/:deckId/cards/:cardId/edit` | `CardFormScreen` (edit) |
| Estudo — frente | `/decks/:deckId/study` | fase `front` |
| Estudo — verso | `/decks/:deckId/study` | fase `back` |
| Estudo — fim | `/decks/:deckId/study` | fase `done` |
| Estudo — vazio | `/decks/:deckId/study` | fase `empty` |
| Confirmar exclusão | dialog | overlay, não é rota |

Se o Stitch tiver tela fora desta tabela (onboarding, share, stats, login social), não implementar na v1.

**Sessão de estudo (estados da tela):**

1. `loading` — carrega fila due.
2. `empty` — nenhum due.
3. `front` — mostra `frontText` + botão “Mostrar resposta”.
4. `back` — mostra `frontText` + `backText` + 6 botões de grade (0–5) com o significado de [`algoritmo-SM-2.md`](algoritmo-SM-2.md) §3.
5. `done` — resumo e voltar ao Deck.

**Due “hoje”:** comparar `nextReviewAt` com o fim do dia civil no fuso do dispositivo (`23:59:59.999` local). Cards com `nextReviewAt` neste instante ou no passado entram na fila.

---

## 8. Fluxos

### 8.1 Auth

```
Visitante → /login ou /register → Firebase Auth → /decks
User → logout → /login
```

### 8.2 CRUD

```
/decks → criar → /decks/:id → criar cards
/decks/:id → editar nome | apagar deck
/decks/:id → editar card | apagar card
```

### 8.3 Estudo

```
/decks/:id → estudar
  carregar due
  enquanto houver card na fila:
    frente → verso → grade
    ApplySM2 + persistir
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

- Login social, anônimo, reset de senha avançado (pode existir o link nativo do Firebase depois; não é aceite)
- Compartilhar / colaborar / decks públicos
- Imagens, áudio, cloze, tags
- Estatísticas além do resumo da sessão e do badge due
- `ReviewLog`
- Import/export Anki
- Temas, i18n além de pt-BR
- Web e desktop como alvo oficial
- Soft delete
- Mover card entre decks
- Notificações push de due

---

## 11. Critérios de sucesso da v1

1. User cria conta, um Deck e pelo menos um Card.
2. Estuda com as 6 notas e o estado SM-2 persiste (reabrir o app mantém `nextReviewAt`).
3. No dia seguinte (ou com relógio avançado em teste), o Card due reaparece.
4. User B não lê dados do User A (regras de Firestore + teste manual com duas contas).
5. Testes unitários do `ApplySM2` cobrem a tabela de exemplo e os casos de borda do spec do algoritmo — escritos **antes** da implementação (P-09).
6. Cada RN de domínio tem teste unitário (fake, sem Firebase) derivado do aceite.
7. Cada rota da §7 é reconhecível frente ao frame Stitch correspondente (hierarquia, tokens, estados). Não é critério pixel-perfect.
