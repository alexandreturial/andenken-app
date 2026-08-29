# Diff visual — Stitch vs rotas (T075)

Critério: cada rota da [`spec.md`](../spec.md) §7 é **reconhecível** frente ao frame (hierarquia, tokens, estados). Não é pixel-perfect.

Projeto Stitch: **Andenken Flashcards** (`projects/10397297006861135646`). Tokens em [`DESIGN.md`](DESIGN.md) → `lib/core/theme/app_theme.dart`.

O app é **dark-mode-first**. Frames light do Stitch foram reescritos com os tokens dark.

## Por rota

| Rota | Frame Stitch | Screen | Recorte de propósito |
|------|----------------|--------|----------------------|
| `/login` | Login | `LoginScreen` | **Forgot?** só visual (reset fora da v1). Continue with Google entra (RN-A05). Sem hamburger/avatar extra. |
| `/register` | Register | `RegisterScreen` | Sem **Full Name** (User sem nome). Confirmação de senha é do spec, não do Stitch. Continue with Google entra (RN-A05). |
| `/decks` | Lista de Decks (`ffce7272f94244d2ae0940cd0baae1bd`) | `DeckListScreen` | Dark densa. Mastery + cards left + streak + bottom nav. Sem FAB (botão + New Deck). Logout no `menu`. `more_vert` (editar) não está no frame. Variante Clean não usada. |
| `/decks` (vazio) | *sem frame* | empty state | Copy local: “Lista de decks vazia” + Criar deck. |
| `/decks/new` | Cadastrar Decks (Clean) | `DeckFormScreen` | Create. Sem fluxo combinado “Cadastrar Decks e Cards”. |
| `/decks/:deckId/edit` | *sem frame* | `DeckFormScreen` | Rename reusa o form de create. |
| `/decks/:deckId` | *sem frame de detalhe* | `DeckDetailScreen` | Lista `frontText` para editar. Não usa Visualização de Card. |
| `/decks/:deckId` (vazio) | *sem frame* | empty state | “Nenhum card neste deck”; Estudar desabilitado. |
| `/decks/:deckId/cards/new` | Cadastrar Múltiplos Cards (Dark) | `CardFormScreen` | Lista de rascunhos, add/remove, Save All. Sem Deck Name, Live Preview nem bottom nav. Variante Clean (sequencial) não usada. |
| `/decks/:deckId/cards/:cardId/edit` | *sem frame* | `CardFormScreen` | Um card; sem add/remove. |
| `/decks/:deckId/study` | Visualização de Card (`ebc67888eb24422cba69955b9bbeb31f`) | `StudyScreen` | FLIP CARD + 4 opções (não Hard/Good/Easy nem intervalos). Sem hint/tag. Bottom nav Study ativo. Tab Decks sai da sessão. |
| `/decks/:deckId/study` | *sem frame* | `empty` / `done` | “Nada para revisar hoje”; resumo “N cards revisados”. |
| dialogs | *sem frame* | `showConfirmDeleteDialog` | Apagar deck / card. |

## Frames Stitch fora da v1 (existem, não implementar)

Estudo de Cards - Áudio; Estudo de Cards - Imagem; Estudo de Cards - Áudio + Imagem; Andenken Logo; Andenken App Icon; `image.png`; Login (Light); Register (Light).

## Artefato proibido

Export Flutter/HTML do Stitch **não** entra em `lib/`. Telas reescritas com atoms em `lib/core/widget/` + `AppTheme`.
