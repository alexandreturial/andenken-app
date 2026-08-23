# Tasks — Andenken v1

> **Tipo:** Artefato de especificação (GitHub Spec Kit)
> **Versão:** 1.4.0
> **Spec:** [`spec.md`](spec.md)
> **Plan:** [`plan.md`](plan.md)
> **Algoritmo:** [`algoritmo-SM-2.md`](algoritmo-SM-2.md)

Checklist de implementação. Ordem = dependência. **TDD (P-09):** em toda task de regra, teste vermelho → implementação → verde → refactor → UI Stitch. Não pular a fase 2 (SM-2 verde) para “já ir fazendo tela”.

---

## Fase 0 — Firebase e pacotes

- [x] **T000** Criar projeto Firebase; ativar Email/Password e Firestore.
- [x] **T001** Registrar app Android `com.turial_dev.andenken.app` no projeto `andenken-ed808`. Sem app iOS.
- [x] **T002** `flutterfire configure --project=andenken-ed808 --platforms=android --android-package-name=com.turial_dev.andenken.app` e gerar `lib/firebase_options.dart`.
- [x] **T003** Publicar regras de Firestore do [`plan.md`](plan.md) §6.3.
- [x] **T004** Adicionar ao `pubspec.yaml`: `firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `go_router`, `uuid`.
- [x] **T005** `flutter pub get` e garantir `flutter run` no **Android** com Firebase init (ainda pode ser o counter). Sem `GoogleService-Info.plist`.

---

## Fase 1 — Esqueleto do app

- [ ] **T010** Criar pastas `lib/core`, `lib/domain`, `lib/data`, `lib/presentation` e `test/fakes`, `test/domain`, `test/presentation` conforme [`plan.md`](plan.md) §3 e §1.2.
- [ ] **T011** Extrair `MyApp` do counter para `lib/app.dart`; `main.dart` só inicializa Firebase e chama `runApp`.
- [ ] **T012** Theme a partir do `DESIGN.md` / tokens do Stitch MCP em `core/theme/app_theme.dart` (cores, tipo, radius, espaçamento; pt-BR).
- [ ] **T013** `GoRouter` com rotas do plan e redirect stub (ainda sem Auth).
- [ ] **T014** Remover a tela do counter e o teste que incrementa o counter (ou reescrever depois).
- [ ] **T015** `MultiProvider` vazio em `app.dart` (será preenchido nas fases 3–4).
- [ ] **T016** Confirmar no [`spec.md`](spec.md) §7.1 os nomes exatos de cada frame Stitch ↔ rota (MCP `stitch`).
- [ ] **T017** Flavors Android `develop` / `homolog` / `prod` (plan §1.3): `productFlavors`, `FlavorConfig`, banner Dev/Homolog. Mesmo `applicationId` e mesmo Firebase. Sem `applicationIdSuffix`. Depois disto: `flutter run --flavor develop --dart-define=FLAVOR=develop`.

---

## Fase 2 — Domínio e SM-2 (TDD, sem Firebase)

- [ ] **T020** Entidade `User` (`id`, `email`, `createdAt`).
- [ ] **T021** Entidade `Deck` (`id`, `userId`, `name`, `cards`, `createdAt`, `updatedAt?`).
- [ ] **T022** Entidade `Card` com campos do [`spec.md`](spec.md) §3.3 e defaults de card novo (RN-C02).
- [ ] **T023** Contratos `AuthRepository`, `DeckRepository`, `CardRepository` + fakes in-memory em `test/fakes/`.
- [ ] **T024** Testes vermelhos da tabela §8 do algoritmo (6 revisões) em `test/domain/apply_sm2_test.dart`. `ApplySM2` ainda não existe ou falha.
- [ ] **T025** Implementar `ApplySM2` (função pura, seção 6 do algoritmo) + validar `grade` em `[0, 5]` (RN-S03) até T024 verde.
- [ ] **T026** Testes vermelhos dos casos de borda §9 (EF piso 1.3, grade 4 não muda EF, card novo due, revisão atrasada) → implementar até verde.
- [ ] **T027** Teste vermelho: `grade < 3` zera `repetitions` e `intervalDays = 1`, mas aplica EF → verde.
- [ ] **T028** Teste vermelho de `endOfLocalDay(DateTime)` (spec §7, um fuso fixo) → helper único até verde.
- [ ] **T029** Refactor do SM-2 sem mudar testes; `flutter test test/domain` verde.

---

## Fase 3 — Auth

- [ ] **T030** Testes vermelhos dos use-cases `SignIn`, `SignUp`, `SignOut`, `WatchCurrentUser` contra `FakeAuthRepository` (US-01, US-02, RN-A01–A03).
- [ ] **T031** Implementar os use-cases até T030 verde.
- [ ] **T032** `FirebaseAuthRepository` + mapeamento User (plan §6.1); registrar no `MultiProvider`.
- [ ] **T033** Teste do `AuthNotifier` (loading / error / sucesso) contra fake → implementar notifier até verde.
- [ ] **T034** `GoRouter.refreshListenable` no stream de Auth; redirects RN-A04 (widget test do redirect se couber).
- [ ] **T035** `LoginScreen` no layout do frame Stitch "Login" (US-02). Não commitar export Flutter do Stitch.
- [ ] **T036** `RegisterScreen` no layout do frame Stitch "Cadastro", com confirmação de senha (US-01).
- [ ] **T037** Logout acessível a partir da lista de Decks; mensagens de rede/credencial sem vazar se o email existe (RN-A02).

---

## Fase 4 — Decks

- [ ] **T040** Testes vermelhos: `ListDecks`, `CreateDeck`, `RenameDeck`, `DeleteDeck` + RN-D01 (`name` 1–80, trim) contra fakes. `DeleteDeck` deve apagar os Cards da subcoleção (plan §6.2).
- [ ] **T041** Implementar use-cases até T040 verde.
- [ ] **T042** DTOs e `FirestoreDeckRepository` no path `users/{uid}/decks/{deckId}`.
- [ ] **T043** Teste do `DeckListNotifier` (loading / data / error / empty) contra fake → notifier verde.
- [ ] **T044** `DeckListScreen` no layout Stitch "Lista de decks" + empty state "Lista de decks vazia" + FAB (US-03, US-06 placeholder de badge).
- [ ] **T045** `DeckFormScreen` nos frames "Novo deck" / "Renomear deck".
- [ ] **T046** Dialog de confirmação no delete (frame Stitch "Confirmar exclusão", se houver).
- [ ] **T047** Isolamento: User A não lista Decks de B (regra Firestore + teste manual — não é unitário).

---

## Fase 5 — Cards

- [ ] **T050** Testes vermelhos: `ListCards`, `CreateCard` (RN-C02), `UpdateCard` (RN-C03), `DeleteCard` (RN-C04), validação RN-C01 — contra `FakeCardRepository`.
- [ ] **T051** Implementar use-cases até T050 verde.
- [ ] **T052** DTOs e `FirestoreCardRepository` em `.../decks/{deckId}/cards/{cardId}`.
- [ ] **T053** Teste do `DeckDetailNotifier` contra fakes → notifier verde.
- [ ] **T054** `DeckDetailScreen` no frame Stitch "Detalhe do deck": lista `frontText`, CTA add, CTA estudar, editar/apagar Deck.
- [ ] **T055** `CardFormScreen` nos frames "Novo card" / "Editar card".
- [ ] **T056** Delete de Card com confirmação (RN-C04).
- [ ] **T057** Empty state de Deck sem Cards (frame "Detalhe sem cards"); botão estudar desabilitado.

---

## Fase 6 — Estudo SM-2

- [ ] **T060** Testes vermelhos de `ListDueCards` (RN-S01, RN-S02) contra fake + `endOfLocalDay` → implementar até verde.
- [ ] **T061** Testes vermelhos de `ReviewCard`: chama `ApplySM2` e persiste (RN-S04) contra fake → implementar até verde.
- [ ] **T062** Testes vermelhos do `StudyNotifier`: fases `front` / `back` / `done` / `empty`; RN-S08 (`grade < 4` reenfileira) → notifier verde.
- [ ] **T063** Query Firestore `nextReviewAt <= endOfLocalDay`; criar índice se o console pedir; anotar no repo.
- [ ] **T064** `StudyScreen` nos frames Stitch "Estudo — frente" / "Estudo — verso": revelar + 6 botões com rótulos do algoritmo §3 (spec vence se o Stitch tiver 4 botões).
- [ ] **T065** Resumo ao terminar no frame "Estudo — fim" (quantos revisados) e volta ao Deck.
- [ ] **T066** Empty state no frame "Estudo — vazio" (RN-S10).
- [ ] **T067** Badge due na lista de Decks (US-06); atualiza após a sessão.

---

## Fase 7 — Fechamento

- [ ] **T070** Passe manual US-01 a US-06 no Android.
- [ ] **T071** Duas contas: confirmar isolamento (critério de sucesso 4).
- [ ] **T072** Matar o app e reabrir: `nextReviewAt` e EF persistidos (critério 2).
- [ ] **T073** Conferir que a UI não contém fórmula SM-2.
- [ ] **T074** Atualizar `README.md` do app: o que é Andenken, como configurar Firebase, link para `docs/`. Sem API key do Stitch.
- [ ] **T075** Diff visual: cada rota vs screenshot Stitch da §7.1; listar o que ficou de fora de propósito.

---

## Fora desta lista (não fazer na v1)

- ReviewLog, imagens, share, login social, web/iOS como alvo, soft delete, i18n extra, push.
- Merge do export Flutter/HTML do Stitch em `lib/`.
- Firebase emulator, mockito obrigatório, TDD de layout Stitch, meta de 100% coverage.
- `GoogleService-Info.plist` / FlutterFire no iOS.
- `applicationIdSuffix` ou projeto Firebase por flavor.

---

## Como usar

Marque o checkbox no arquivo (ou no tracker) conforme concluir. Se uma task mudar o contrato de entidade ou regra, atualize `spec.md` / `algoritmo-SM-2.md` **antes** do teste e do código (constitution §6). Tasks de regra: primeiro o teste vermelho. Telas: só depois do verde; puxar o frame no MCP `stitch` e reescrever em `presentation/` — não colar o export Flutter.
