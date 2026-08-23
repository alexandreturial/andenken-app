# Spec: Algoritmo SM-2 (SuperMemo 2) — Repetição Espaçada

> **Tipo:** Artefato de especificação (SDD — Spec-Driven Development)
> **Versão:** 1.0.0
> **Domínio:** `flashcard` / `spaced-repetition`

---

## 1. Visão Geral

O SM-2 é um algoritmo de **repetição espaçada** criado por Piotr Wozniak em 1987. Ele calcula o intervalo ótimo de revisão para cada flashcard com base no desempenho do usuário, maximizando a retenção de longo prazo e evitando revisões desnecessárias.

**Base científica:** Curva do Esquecimento de Ebbinghaus — sem revisões periódicas, a memória decai rapidamente. O SM-2 agenda revisões no momento em que a memória está prestes a se perder.

---

## 2. Terminologia e Conceitos

| Termo | Descrição |
|-------|-----------|
| `easeFactor` (EF) | Fator de facilidade do card. Determina a taxa de crescimento dos intervalos. Varia entre `1.3` (difícil) e `2.5` (fácil). Todo card começa com `2.5`. |
| `interval` | Número de dias até a próxima revisão do card. |
| `repetition` | Contador de revisões consecutivas bem-sucedidas (nota ≥ 3). Resetado para `0` em caso de falha. |
| `grade` (q) | Nota de desempenho do usuário na revisão. Inteiro de `0` a `5`. |
| `nextReviewAt` | Data/hora da próxima revisão agendada. |
| `lastReviewedAt` | Data/hora da última revisão realizada. |

---

## 3. Escala de Notas (grade)

| grade (q) | Significado | Tipo |
|-----------|-------------|------|
| `5` | Resposta perfeita, imediata e correta | Acerto |
| `4` | Resposta correta com pequena hesitação | Acerto |
| `3` | Resposta correta, mas com dificuldade significativa | Acerto |
| `2` | Resposta incorreta, mas a resposta correta parecia fácil de lembrar | Falha |
| `1` | Resposta incorreta, mas a resposta correta foi lembrada após ver | Falha |
| `0` | Nenhuma lembrança da resposta correta | Falha |

> **Regra:** `grade >= 3` → acerto (avança). `grade < 3` → falha (reinicia sequência).

---

## 4. Fórmulas

### 4.1 Cálculo do Próximo Intervalo

```
Se repetition == 0:
  interval = 1

Se repetition == 1:
  interval = 6

Se repetition > 1:
  interval = round(interval_anterior * easeFactor)
```

> O intervalo resultante deve sempre ser um inteiro positivo (arredondado para cima).

### 4.2 Atualização do EaseFactor (EF)

```
EF' = EF + (0.1 - (5 - q) * (0.08 + 0.02 * (5 - q)))
```

Forma simplificada equivalente:

```
EF' = EF - 0.8 + 0.28 * q - 0.02 * q²
```

> **Restrição:** Se `EF' < 1.3`, definir `EF' = 1.3` (piso mínimo).

### 4.3 Efeito da Nota no EF (valores aproximados)

| grade (q) | Δ EF (aproximado) |
|-----------|-------------------|
| `5` | +0.10 |
| `4` | 0.00 (sem alteração) |
| `3` | –0.14 |
| `2` | –0.32 |
| `1` | –0.54 |
| `0` | –0.80 |

---

## 5. Regras de Negócio

### RN-01 — EF Inicial
Todo card novo começa com `easeFactor = 2.5`.

### RN-02 — Piso do EF
O `easeFactor` nunca pode ser menor que `1.3`. Se a fórmula produzir valor menor, usar `1.3`.

### RN-03 — Primeiros Intervalos Fixos
As duas primeiras revisões bem-sucedidas seguem intervalos fixos:
- 1ª revisão bem-sucedida (`repetition == 0`): `interval = 1` dia
- 2ª revisão bem-sucedida (`repetition == 1`): `interval = 6` dias

**Justificativa:** O SM-2 usa intervalos fixos iniciais porque não há histórico suficiente do aluno para confiar no EF calculado. O valor `6` foi calibrado empiricamente para o estágio de consolidação inicial.

### RN-04 — Falha (grade < 3)
Quando `grade < 3`:
- `repetition` é resetado para `0`
- `interval` é resetado para `1` dia
- O `easeFactor` **não é alterado** neste momento (a fórmula do EF ainda é aplicada, mas a sequência de intervalos reinicia)

### RN-05 — Atualização do EF em Falhas
Mesmo em caso de falha, a fórmula do EF é aplicada normalmente, penalizando o fator de facilidade. A diferença é que o intervalo reinicia, não o EF.

### RN-06 — Revisão Adicional no Mesmo Dia
Após cada sessão, todos os cards com `grade < 4` devem ser colocados na fila de revisão do mesmo dia e repetidos até que o usuário os responda com `grade >= 4`.

### RN-07 — Cálculo de nextReviewAt
```
nextReviewAt = lastReviewedAt + interval (em dias)
```

### RN-08 — Incremento do Repetition
O contador `repetition` só é incrementado quando `grade >= 3`. Em falha, volta a `0`.

---

## 6. Fluxo de Execução (por revisão)

```
ENTRADA: card, grade (0–5)

1. Calcular novo EF:
   EF' = EF + (0.1 - (5 - grade) * (0.08 + 0.02 * (5 - grade)))
   Se EF' < 1.3 → EF' = 1.3

2. Verificar resultado da revisão:
   SE grade >= 3 (acerto):
     SE repetition == 0 → interval = 1
     SE repetition == 1 → interval = 6
     SE repetition > 1  → interval = round(interval * EF')
     repetition += 1

   SE grade < 3 (falha):
     interval = 1
     repetition = 0

3. Atualizar card:
   card.easeFactor    = EF'
   card.interval      = interval
   card.repetition    = repetition
   card.lastReviewedAt = agora
   card.nextReviewAt  = agora + interval dias

SAÍDA: card atualizado
```

---

## 7. Modelo de Dados

### Entidade: `Card`

| Campo | Tipo | Valor Padrão | Descrição |
|-------|------|--------------|-----------|
| `id` | `string (uuid)` | gerado | Identificador único |
| `deckId` | `string (uuid)` | — | Deck ao qual pertence |
| `front` | `string` | — | Frente do card (pergunta) |
| `back` | `string` | — | Verso do card (resposta) |
| `easeFactor` | `float` | `2.5` | Fator de facilidade (EF) |
| `interval` | `int` | `0` | Intervalo atual em dias |
| `repetition` | `int` | `0` | Contador de acertos consecutivos |
| `nextReviewAt` | `datetime` | `now()` | Próxima revisão agendada |
| `lastReviewedAt` | `datetime \| null` | `null` | Última revisão realizada |
| `createdAt` | `datetime` | `now()` | Data de criação |
| `updatedAt` | `datetime` | `now()` | Última atualização |

### Entidade: `ReviewLog` (opcional — para auditoria)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | `string (uuid)` | Identificador único |
| `cardId` | `string (uuid)` | Card revisado |
| `grade` | `int (0–5)` | Nota atribuída |
| `easeFactor` | `float` | EF após a revisão |
| `interval` | `int` | Intervalo definido após a revisão |
| `repetition` | `int` | Repetition após a revisão |
| `reviewedAt` | `datetime` | Momento da revisão |

---

## 8. Exemplo Passo a Passo

**Cenário:** Novo card, EF inicial = 2.5

| Revisão | Dia | grade (q) | EF antes | EF depois | Interval | Próxima Revisão | Observação |
|---------|-----|-----------|----------|-----------|----------|-----------------|------------|
| 1 | 1 | 4 | 2.50 | 2.50 | 1 | Dia 2 | 1ª rep, intervalo fixo = 1d, EF inalterado |
| 2 | 2 | 4 | 2.50 | 2.50 | 6 | Dia 8 | 2ª rep, intervalo fixo = 6d, EF inalterado |
| 3 | 8 | 3 | 2.50 | 2.36 | 15 | Dia 23 | `round(6 * 2.36) = 14` → 15 dias |
| 4 | 23 | 2 | 2.36 | 2.04 | 1 | Dia 24 | Falha: reinicia sequência |
| 5 | 24 | 4 | 2.04 | 2.04 | 1 | Dia 25 | repetition=0, intervalo fixo = 1d |
| 6 | 25 | 5 | 2.04 | 2.14 | 6 | Dia 31 | repetition=1, intervalo fixo = 6d |

---

## 9. Casos de Borda

| Situação | Comportamento esperado |
|----------|------------------------|
| `grade = 4` aplicado → EF não muda | `EF' = EF + (0.1 - 1*(0.08 + 0.02)) = EF + 0` ✓ |
| `grade = 5` aplicado → EF cresce | `EF' = EF + 0.10` |
| EF calculado < 1.3 | Forçar `EF = 1.3` |
| Card nunca revisado (`repetition = 0`) | `nextReviewAt = createdAt` (disponível imediatamente) |
| Revisão atrasada (feita após `nextReviewAt`) | Aplicar normalmente; o atraso não penaliza o algoritmo base |

---

## 10. Comparação SM-2 Original vs Anki

| Aspecto | SM-2 Original | Anki (variante) |
|---------|---------------|-----------------|
| Primeiros intervalos | 1 e 6 dias (fixos) | Configurável em minutos (ex: 2 e 12 min) |
| Escala de resposta | 6 notas (0–5) | 4 botões: Novamente / Difícil / Bom / Fácil |
| Falha no aprendizado inicial | Penaliza EF | **Não penaliza** o EF durante aprendizado |
| Revisão atrasada | Não considera | Bônus extra no próximo intervalo |
| Botão "Fácil" | q = 5 | Multiplica por EF + bônus extra |

---

## 11. Restrições de Implementação

- O `easeFactor` deve ser armazenado como `float` com precisão de 2 casas decimais
- O `interval` deve ser sempre um inteiro positivo (`>= 1`)
- O `repetition` nunca pode ser negativo
- `grade` deve ser validado como inteiro no intervalo `[0, 5]` antes de aplicar o algoritmo
- A lógica do SM-2 deve ser encapsulada em um **use-case** ou **domain service** isolado, sem dependência de infraestrutura
- O cálculo deve ser **puro** (sem efeitos colaterais): recebe o estado atual do card + grade, retorna o novo estado

---

## 12. Interface do Use-Case (TypeScript)

```typescript
// Entrada
interface ReviewCardInput {
  cardId: string
  grade: 0 | 1 | 2 | 3 | 4 | 5
}

// Saída (campos atualizados do card)
interface SM2Result {
  easeFactor: number   // novo EF
  interval: number     // novo intervalo em dias
  repetition: number   // novo contador
  nextReviewAt: Date   // data da próxima revisão
  lastReviewedAt: Date // data da revisão atual
}

// Função pura do algoritmo
function applyS M2(card: CardSM2State, grade: number): SM2Result
```

---

## 13. Referências

- SM-2 original: https://super-memory.com/english/ol/sm2.htm
- Documentação do Anki sobre SR: https://faqs.ankiweb.net/what-spaced-repetition-algorithm.html
- Artigo crítico sobre SM-2: https://www.blueraja.com/blog/477/a-better-spaced-repetition-learning-algorithm-sm2
