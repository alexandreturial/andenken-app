# Andenken

App Flutter de flash cards para estudo pessoal. O usuário cria decks, adiciona cards frente/verso e os revisa no prazo calculado pelo SM-2.

Alvo da v1: **Android**. iOS, web e desktop não são aceite.

## Docs

| Artefato | Conteúdo |
|----------|----------|
| [`AGENTS.md`](AGENTS.md) | Operação do agente (fonte de verdade, never, TDD) |
| [`docs/constitution.md`](docs/constitution.md) | Princípios |
| [`docs/PRODUCT.md`](docs/PRODUCT.md) | Visão, MVP feito, fora do MVP, roadmap |
| [`docs/spec.md`](docs/spec.md) | Contrato da v1: entidades, regras, telas |
| [`docs/plan.md`](docs/plan.md) | Stack, pastas, Firebase, rotas |
| [`docs/tasks.md`](docs/tasks.md) | Histórico da v1 (T000–T075) |
| [`docs/algoritmo-SM-2.md`](docs/algoritmo-SM-2.md) | Fórmulas SM-2 0–5; UI mapeia 4 opções |
| [`specs/README.md`](specs/README.md) | Features novas (não fatiar a v1) |
| [`docs/stitch/DESIGN.md`](docs/stitch/DESIGN.md) | Tokens visuais (Stitch) |
| [`docs/stitch/DIFF.md`](docs/stitch/DIFF.md) | Rota vs frame Stitch; o que ficou de fora |
| [`docs/qa-manual.md`](docs/qa-manual.md) | Passe manual US-01–US-06 (Fase 7) |

## Rodar

SDK via [FVM](https://fvm.app/). Flavors `develop` / `homolog` / `prod` usam o **mesmo** `applicationId` e o **mesmo** projeto Firebase; não dá para instalar os três APKs no mesmo device.

```bash
fvm flutter pub get
fvm flutter test
fvm flutter run --flavor develop --dart-define=FLAVOR=develop
```

`fvm flutter run` **sem** `--flavor` falha. Homolog e prod:

```bash
fvm flutter run --flavor homolog --dart-define=FLAVOR=homolog
fvm flutter run --flavor prod --dart-define=FLAVOR=prod
```

## Firebase

Projeto: `andenken-ed808`. Package Android: `com.turial_dev.andenken.app`.

1. No console: Auth **Email/Password** e **Google**; Firestore em modo produção.
2. Publicar regras: `firebase deploy --only firestore:rules` (fonte: [`firestore.rules`](firestore.rules)).
3. Registrar o app Android com o mesmo `applicationId`. Sem app iOS na v1.
4. SHA-1 e SHA-256 do keystore de debug (Google Sign-In):

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Colar em Firebase → Project settings → app Android.

5. Gerar config **somente Android**:

```bash
flutterfire configure --project=andenken-ed808 \
  --platforms=android \
  --android-package-name=com.turial_dev.andenken.app \
  --yes
```

`lib/firebase_options.dart` entra no git. `android/app/google-services.json` **não** (está no `.gitignore`). Quem clona precisa do JSON local ou de um `flutterfire configure`. O `oauth_client` precisa ter tipo 1 (Android) e tipo 3 (Web); sem isso o Google Sign-In não emite `idToken`.

Se o console pedir índice na query de cards due (`nextReviewAt`), criar e anotar o URL em [`docs/plan.md`](docs/plan.md) §6.2.

## O que a v1 não inclui

Reset de senha, imagens/áudio nos cards, compartilhar decks, Apple Sign-In, iOS com Firebase, projetos Firebase distintos por flavor.

A API key do Google Stitch é só local (Cursor MCP / env). Não commitar em `docs/`, neste README ou no git. Template: [`.cursor/mcp.json.example`](.cursor/mcp.json.example).
