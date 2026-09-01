# 💬 Arquitetura do Chat Privado — WorkGB

## 🎯 Conceito
O sistema de chat do WorkGB foi desenhado para ser um intermediário seguro entre clientes e profissionais, organizado de forma a facilitar a gestão de múltiplos contactos para quem presta serviços.

---

## 🏗️ Estrutura de Dados
As conversas não são "salas" fixas, mas sim fluxos de mensagens filtrados dinamicamente:

| Campo | Descrição |
|-------|-----------|
| `trabalhador_id` | Identifica qual o anúncio/serviço originou o contacto. |
| `cliente_id` | ID do utilizador que iniciou o contacto. |
| `remetente_id` | Quem escreveu a mensagem específica. |
| `mensagem` | Conteúdo de texto. |
| `estado` | `enviado`, `entregue` ou `lido`. |
| `tipo` | `texto`, `imagem` ou `video`. |
| `url_midia` | Link público para o ficheiro (se tipo for imagem/video). |

---

## 📈 Hierarquia de Navegação (Profissional)

O profissional possui uma visão em 3 níveis para gerir o seu volume de trabalho:

1.  **Nível 1 (Mensagens por Card)**: Lista os seus serviços que têm mensagens ativas.
2.  **Nível 2 (Clientes)**: Para cada card, lista os clientes interessados (ex: Sora, João). Mostra a última mensagem e contador de pendentes.
3.  **Nível 3 (Chat)**: A conversa individual e privada.

---

## ✅ Indicadores de Estado (WhatsApp Style)

Implementámos indicadores visuais para dar confiança ao utilizador sobre a entrega:

- 🕐 **A enviar**: Mensagem em processamento local.
- ✔ **Enviado**: Registo guardado com sucesso na base de dados Supabase.
- ✔✔ **Entregue**: O app do recetor detetou a mensagem via Realtime e confirmou a receção ao servidor.
- ✔✔ **Lido (Azul)**: O recetor abriu o ecrã de chat e visualizou as mensagens.

---

## 🛠️ Lógica de Interface (UX)

### Auto-scroll Inteligente
Para garantir que a conversa comece sempre na mensagem mais recente:
- Utilizamos `reverse: true` no `ListView.builder`.
- Isto fixa a base da lista no fundo do ecrã.
- Ao enviar ou receber, o app executa um `jumpTo(0)` para garantir o alinhamento.
- Implementada técnica de **duplo gatilho** (imediato + delay 300ms) para acomodar a renderização de imagens.

### Envio de Mídia
- Integração direta com a câmara e galeria.
- Upload para bucket dedicado `chat_midia`.
- Para detalhes, consulte [docs/MIDIA.md](MIDIA.md).

---

## 🔒 Segurança e Privacidade

- **Busca de Nomes**: O app não guarda nomes estáticos nas mensagens. Ele cruza o `cliente_id` com a tabela `utilizadores` em tempo real para exibir sempre o nome mais atualizado.
- **Isolamento**: Um cliente nunca consegue ver mensagens de outro cliente, mesmo que ambos estejam a contactar o mesmo profissional sobre o mesmo card.

---
**Documento atualizado em: 31 de Agosto de 2026**
