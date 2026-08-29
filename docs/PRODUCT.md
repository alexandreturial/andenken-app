# Andenken — produto

> Visão e escopo. Não substitui o contrato da v1 ([`spec.md`](spec.md)).
> Como desenvolver: [`constitution.md`](constitution.md).

## Objetivo

App Flutter de flash cards para estudo pessoal: o usuário cria decks, adiciona cards frente/verso e os revisa no prazo calculado pelo SM-2.

## Público

Quem quer memorizar conteúdo próprio (idiomas, concursos, notas). Sem papéis de professor, turma ou colaboração na v1.

## Problema

Esquecer o que foi estudado sem um intervalo de revisão.

## Proposta de valor

Cadastrar o material e estudá-lo no dia certo, com SM-2 (4 opções na UI).

## MVP (v1)

Contrato: [`spec.md`](spec.md). Implementação: [`tasks.md`](tasks.md) T000–T075.

- Cadastro e login (email/senha e Google) no Android
- CRUD privado de Decks e Cards
- Sessão de estudo SM-2 (4 opções na UI mapeadas para 0/4/5/5; fila due; refila se `grade < 4`)
- Persistência Firestore; isolamento por `uid`
- Badge de cards due na lista de decks

Alvo oficial: **Android**. Flavors `develop` / `homolog` / `prod` no mesmo Firebase e `applicationId`.

## Fora do MVP (v1)

Fonte: [`spec.md`](spec.md) §10. Não implementar sem spec de feature nova.

- Anônimo, Apple Sign-In, reset de senha como aceite
- Compartilhar / colaborar / decks públicos
- Imagens, áudio, cloze, tags
- Estatísticas além do resumo da sessão e do badge due
- `ReviewLog`, import/export Anki
- Temas, i18n além de pt-BR
- Web, desktop e iOS como alvo oficial (iOS sem Firebase na v1)
- Projetos Firebase ou applicationIds distintos por flavor
- Soft delete, mover card entre decks, push de due
- Offline avançado além da persistência padrão do Firestore

## Roadmap

Próximas features **ainda não especificadas**. Quando uma for decidida: pasta `specs/NNN-nome/` (clarify antes do plan). Não reabrir as RNs da v1 sem atualizar [`spec.md`](spec.md).

## Métricas

A v1 não define KPIs de produto. Aceite: critérios de sucesso em [`spec.md`](spec.md) §11 e passe manual em [`qa-manual.md`](qa-manual.md).
