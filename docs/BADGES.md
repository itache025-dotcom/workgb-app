# 🔴 Sistema de Badges (Contadores de Pendentes)

## 🎯 Objetivo
Indicar visualmente ao utilizador que existem mensagens novas que ainda não foram lidas, utilizando uma hierarquia de contadores que guiam o utilizador até à conversa pendente.

---

## 🏗️ Hierarquia de Contagem

### 1. Nível Global (Barra de Navegação / Home)
- **Onde**: Ícone de mensagens no AppBar.
- **Lógica**: Soma de todas as conversas únicas onde existe pelo menos uma mensagem não lida enviada por outra pessoa.
- **Atualização**: Automática via Realtime Global no `main.dart`.

### 2. Nível de Cards (Painel do Profissional)
- **Onde**: Lista de cards com atividade.
- **Lógica**: Conta quantos clientes diferentes enviaram mensagens que o profissional ainda não leu para aquele serviço específico.
- **Visual**: Círculo vermelho com o número à direita do ListTile.

### 3. Nível de Conversa (Lista de Clientes)
- **Onde**: Dentro de um card, na lista de pessoas interessadas.
- **Lógica**: Conta o número exato de mensagens pendentes vindas daquele cliente específico.
- **Visual**: Badge verde circular estilo WhatsApp.

---

## 🔄 Fluxo de Atualização em Tempo Real

Para evitar consultas excessivas (polling), o WorkGB utiliza o **Supabase Realtime**:

1.  O `main.dart` cria uma subscrição global à tabela `mensagens`.
2.  Quando uma nova mensagem é inserida (INSERT):
    - O app verifica se o recetor é o utilizador logado.
    - Se sim, chama o método `_recalcularBadges()`.
    - O `EstadoGlobal` (Provider) é atualizado.
    - Todos os ícones e badges no app reagem instantaneamente sem o utilizador mudar de ecrã.

---

## 🧹 Limpeza de Badges
Os contadores são zerados no momento em que a conversa é aberta. O app envia um sinal ao servidor (`marcarComoLidas`) e o Realtime propaga a descida do contador para todos os outros componentes da interface.

---

## 🛠️ Métodos Técnicos (SupabaseService)

- `obterTotalConversasNaoLidas(userId)`: Retorna o número para o badge global.
- `obterClientesNaoLidosPorCard(cardId, userId)`: Filtra por card.
- `obterMensagensNaoLidasConversa(cardId, clienteId, userId)`: Filtra por pessoa.

---
**Documento criado em: 30 de Agosto de 2026**
