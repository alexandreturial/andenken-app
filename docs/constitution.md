# Constitution — Andenken

> **Tipo:** Artefato de especificação (GitHub Spec Kit)
> **Versão:** 1.4.0
> **Produto:** Andenken — flash cards com CRUD + repetição espaçada SM-2

Este documento é a fonte de princípios do projeto. `spec.md`, `plan.md` e `tasks.md` devem respeitá-lo. Em conflito, a constitution vence.

---

## 1. Propósito

Andenken é um app Flutter de flash cards. A v1 entrega:

1. Autenticação por email e senha.
2. CRUD privado de Decks e Cards.
3. Sessão de estudo com o algoritmo SM-2 definido em [`algoritmo-SM-2.md`](algoritmo-SM-2.md).

Não é um clone de Anki. É um MVP com boas práticas, não uma plataforma.

---

## 2. Princípios

### P-01 — MVP primeiro

Entregar o caminho feliz completo (cadastrar → estudar → revisar no prazo) antes de features secundárias. Se uma decisão aumenta escopo sem desbloquear esse caminho, fica fora da v1.

### P-02 — SOLID sem over-engineering

Separar responsabilidades em camadas claras (presentation / domain / data). Use-cases fazem uma coisa. Repositórios escondem Firebase. Não introduzir DDD pesado, aggregates complexos, event bus ou codegen de domínio.

### P-03 — Domínio puro

A regra de negócio — especialmente o SM-2 — não depende de Flutter, Firebase, `provider` ou `go_router`. Use-cases recebem dados, retornam dados. Efeitos colaterais ficam em repositórios.

### P-04 — Estado explícito com ValueNotifier

Estado de tela e de fluxo vive em `ValueNotifier` (ou `ValueNotifier<T>` + `ValueListenableBuilder`). `provider` existe só para injeção de dependência, não como store global de estado.

### P-05 — Uma fonte de verdade por assunto

| Assunto | Fonte |
|---------|--------|
| Princípios e restrições | Este arquivo |
| Produto, entidades, telas, aceite | [`spec.md`](spec.md) |
| Stack, pastas, Firebase, rotas, handoff Stitch | [`plan.md`](plan.md) |
| Ordem de implementação | [`tasks.md`](tasks.md) |
| Fórmulas e regras SM-2 | [`algoritmo-SM-2.md`](algoritmo-SM-2.md) |
| Visual / design system | Google Stitch via MCP (projeto Andenken) |
| Como testar | P-09 + [`plan.md`](plan.md) §1.2 |

### P-06 — Privacidade por padrão

Decks e Cards pertencem a um único User. Não há compartilhamento, busca pública nem coleção global de conteúdo na v1.

### P-07 — Nomes estáveis no domínio

Os campos do domínio usam os nomes da entidade (ex.: `frontText`, `intervalDays`, `repetitions`). O vocabulário do SM-2 (`front`, `interval`, `repetition`) é mapeado no use-case, não espalhado pela UI.

### P-08 — Stitch é a fonte visual; o spec vence o comportamento

Telas e tokens vêm do Google Stitch, acessado pelo MCP `stitch`. O agente **não** commita Flutter/HTML exportado do Stitch em `lib/`. Reescreve em `presentation/` + `app_theme.dart`, no contrato do spec (rotas, 6 notas 0–5, `ValueNotifier`, use-cases).

Se Stitch e spec divergirem, o spec vence; o frame no Stitch é atualizado depois. Figma não é fonte oficial da v1.

A API key do Stitch é local (Cursor MCP / env). Nunca entra em `docs/`, `README` ou git.

### P-09 — Test-Driven Development

Regra de domínio e notifier de fluxo nascem assim:

1. **Vermelho** — teste que falha, derivado do spec / RN / tabela SM-2.
2. **Verde** — implementação mínima para passar.
3. **Refactor** — limpar sem mudar comportamento.

O spec é o oráculo. Não escrever teste que não aponte para aceite ou RN. UI Stitch só depois do use-case/notifier verde.

Use-cases contra **fakes** in-memory (interfaces da T023). Sem mock do SDK Firebase. Sem TDD de layout pixel a pixel. Isolamento real entre users e passe US-01–US-06 continuam manuais (Fase 7).

---

## 3. Restrições da v1 (não negociáveis)

- Backend: Firebase Auth + Cloud Firestore. Sem API própria.
- Auth: email + senha. Sem Google, Apple, anônimo ou coleção `users`.
- Estado: `ValueNotifier`. Sem Riverpod, Bloc ou GetX.
- DI: `provider`.
- Navegação: `go_router`.
- Persistência: `users/{uid}/decks/{deckId}/cards/{cardId}`.
- Card: texto frente/verso. Sem imagem, dica, tags ou markdown rico.
- Deck: só `name` + timestamps. Sem descrição, cor ou capa.
- Delete: hard delete (Deck apaga os Cards da subcoleção).
- Sem `ReviewLog` na v1.
- Plataformas-alvo: Android. Sem Firebase/config iOS na v1. Web/desktop e iOS não são critério de aceite.
- Flavors: `develop`, `homolog`, `prod`. Mesmo Firebase (`andenken-ed808`) e mesmo `applicationId` na v1.
- Offline: persistência local padrão do Firestore no mobile; sem modo offline customizado.
- UI: tokens e layout do Stitch (MCP). Sem merge cego do export Flutter. Sem Figma como fonte oficial.
- TDD: use-case e notifier de regra não entram em `lib/` sem teste vermelho prévio. Sem Firebase emulator nem meta de 100% coverage na v1.

---

## 4. Decisões de escopo (dúvidas fechadas)

Estas perguntas estavam abertas no planejamento. Ficam registradas aqui para não reabrir no meio da implementação.

| Dúvida | Decisão v1 | Motivo |
|--------|------------|--------|
| Nomes SM-2 vs Card | Domínio usa `frontText`, `backText`, `repetitions`, `intervalDays` | Contrato definido no produto; SM-2 mapeia no use-case |
| `ReviewLog` | Fora | Auditoria não desbloqueia o MVP |
| RN-06 (fila no mesmo dia até `grade >= 4`) | Dentro | Está no spec do algoritmo; faz parte da sessão de estudo |
| Delete | Hard delete | Soft delete exige campo extra e queries filtradas |
| Deck `description` | Não | Só `name` |
| Plataformas | Android only | iOS fica para depois; pasta `ios/` do Flutter pode existir sem Firebase |
| Flavors | develop / homolog / prod, mesmo Firebase | Separação no app agora; projetos distintos depois |
| Offline | Persistência default do Firestore | Zero código extra; online-only quebraria o estudo no metrô |
| Fonte visual | Google Stitch + MCP | Handoff com screenshot/HTML/`DESIGN.md`; spec manda no comportamento |
| Testes | TDD no domínio e notifiers; fakes; UI depois do verde | P-01: sem emulator/coverage theater |

---

## 5. Qualidade

- Use-case SM-2 tem testes unitários escritos **antes** da implementação, cobrindo as tabelas e casos de borda de [`algoritmo-SM-2.md`](algoritmo-SM-2.md).
- Cada RN de domínio tem pelo menos um teste unitário (fake, sem Firebase).
- Regras de Firestore impedem leitura/escrita cruzada entre users.
- UI não contém fórmula de intervalo, EF ou grade.
- Cada tela implementada puxa o frame Stitch mapeado em [`spec.md`](spec.md) §7.1.
- Dependências novas exigem justificativa no `plan.md`.
- Credencial do MCP Stitch não aparece no repositório.

---

## 6. Governança

1. Mudança de princípio → atualizar este arquivo e a versão.
2. Mudança de produto → `spec.md`.
3. Mudança de stack/pastas/Firebase → `plan.md`.
4. Mudança de ordem de build → `tasks.md`.
5. Mudança de fórmula SM-2 → `algoritmo-SM-2.md` primeiro; depois o teste vermelho; depois o use-case.
6. Mudança visual → atualizar o frame no Stitch e a tabela [`spec.md`](spec.md) §7.1; tokens novos vão para `plan.md` / `app_theme.dart`.

Nenhuma implementação deve começar por uma tela se o use-case correspondente ainda não existir **e estiver verde** no domínio (exceto telas estáticas de auth, que só orquestram o repositório de Auth — o use-case de Auth ainda nasce em TDD contra fake).
