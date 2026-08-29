# Passe manual — Fase 7

Device Android. Flavor `develop`. Duas contas de teste (email distinto).

```bash
fvm flutter run --flavor develop --dart-define=FLAVOR=develop
```

Marque no [`tasks.md`](tasks.md) T070–T072 só depois de passar no device.

## T070 — US-01 a US-06

### US-01 Cadastro

- [ ] Form com email, senha e confirmação.
- [ ] Senhas diferentes bloqueiam o submit.
- [ ] Sucesso autentica e abre a lista de Decks.
- [ ] Email já cadastrado mostra erro inteligível.
- [ ] Continue with Google (conta nova) abre `/decks`.

### US-02 Entrar e sair

- [ ] Login válido abre `/decks`.
- [ ] Credencial inválida mostra erro e não navega (não revela se o email existe).
- [ ] Logout volta para `/login`; o back não reabre rotas autenticadas.
- [ ] Continue with Google (conta já existente) abre `/decks`. Cancelar o seletor permanece na tela sem erro.

### US-03 Deck

- [ ] Toque no card do deck abre o estudo; menu Editar abre o detalhe.
- [ ] Lista vazia mostra CTA para criar o primeiro Deck.
- [ ] Criar com nome válido aparece na lista.
- [ ] Nome vazio não salva.
- [ ] Renomear atualiza só aquele Deck.
- [ ] Apagar pede confirmação; após confirmar, Deck e Cards somem.

### US-04 Card

- [ ] Dentro do Deck, a lista mostra `frontText`.
- [ ] Criar: lista de forms, add/remove, Save All; frente e verso obrigatórios.
- [ ] Editar persiste frente/verso (o estado SM-2 não zera).
- [ ] Apagar pede confirmação e remove só aquele Card.
- [ ] Card novo aparece due na sessão (Estudar).

### US-05 Estudo

- [ ] Só Cards due daquele Deck.
- [ ] Frente → FLIP CARD → 4 opções.
- [ ] A nota persiste (ver T072).
- [ ] “Não lembro” reaparece na mesma sessão; as outras três encerram o card.
- [ ] Fila vazia: resumo com quantos revisados.
- [ ] Deck com cards mas sem due: “Nada para revisar hoje”.

### US-06 Badge due

- [ ] Cada item mostra mastery, cards left (due) e a contagem muda depois da sessão.
- [ ] Daily Streak aparece (0 até estudar).

## T071 — Isolamento (duas contas)

Mesmo device, duas contas; ou dois devices.

1. Conta A: criar um Deck com nome único (ex.: `Alemão A1`) e um Card.
2. Logout. Entrar com a conta B.
3. A lista de B **não** mostra `Alemão A1`. Criar um Deck `Francês` em B.
4. Logout. Entrar de novo com A: só `Alemão A1`, sem `Francês`.
5. (Opcional) Console Firebase / regras playground: autenticado como B, `get` em `users/{uidA}/decks/{deckId}` → `permission-denied`.

## T072 — Persistência SM-2

1. Estudar um Card novo com nota **5**.
2. Matar o app (swipe away) e reabrir.
3. O mesmo Card **não** está due hoje (intervalo 1 dia após o primeiro acerto).
4. (Opcional) Console Firestore: o documento do Card tem `easeFactor`, `intervalDays`, `repetitions`, `nextReviewAt` e `lastReviewedAt` preenchidos.
