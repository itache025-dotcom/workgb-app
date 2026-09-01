# 🏗️ Arquitetura Detalhada — Sistema WorkGB

Este documento descreve a infraestrutura técnica, os fluxos de dados e a lógica de negócio que sustenta o marketplace WorkGB.

---

## 1. Visão Geral da Arquitetura

O WorkGB utiliza uma arquitetura cliente-servidor moderna, onde o processamento pesado e a persistência de dados são delegados a serviços na nuvem (Backend as a Service - BaaS).

```text
       [ APP FLUTTER ] (Frontend)
              ↕
      [ ESTADO GLOBAL ] (Provider)
              ↕
        [ CAMADA DE SERVIÇOS ]
        /         |          \
 [ SUPABASE ] [ FIREBASE ] [ NATIVE OS ]
 (DB, Auth,   (Push Notif)  (GPS, Tel, 
  Storage,                   Câmara)
  Realtime)
```

---

## 2. Estrutura e Responsabilidades (lib/)

- **`main.dart`**: Ponto de entrada. Inicializa Firebase, Supabase e o sistema de notificações. Gere a lógica de Realtime global para Badges e Notificações Locais.
- **`modelos/`**: 
  - `usuario_model.dart`: Perfil de conta (ID, Nome, Tipo de utilizador).
  - `trabalhador_model.dart`: Anúncio de serviço (Profissão, Descrição, Localização, Fotos, Avaliações).
- **`provedores/`**:
  - `estado_global.dart`: Singleton que mantém o utilizador logado, lista de trabalhadores e contagem global de mensagens não lidas.
- **`servicos/`**:
  - `auth_service.dart`: Lógica de sessões, registo e segurança de acesso.
  - `supabase_service.dart`: Todas as operações de leitura/escrita de dados e ficheiros.
  - `conversao.dart`: Blindagem de tipos para garantir estabilidade nos dados numéricos do Supabase.
- **`telas/`**: Interface visual dividida por contexto (Pública, Cliente, Profissional).

---

## 3. Integração Supabase

O **Supabase** funciona como o motor principal do projeto:

- **Autenticação**: Utiliza Supabase Auth (JWT). As senhas são encriptadas no servidor.
- **Base de Dados (PostgreSQL)**:
  - Tabela `utilizadores`: Dados extras das contas.
  - Tabela `trabalhadores`: Armazena os cards de serviço.
  - Tabela `mensagens`: Histórico do chat interno com suporte a `estado` (enviado, entregue, lido).
  - Tabela `avaliacoes`: Feedback dos clientes com suporte a respostas do profissional e avaliações anónimas.
- **Storage**: Buckets `fotos` (perfis) e `documentos` (certificados) guardam os ficheiros media.
- **RLS (Row Level Security)**: Políticas que garantem que apenas o dono de um card ou mensagem pode gerir os seus dados.
- **Realtime**: Utilizado de forma global para atualizar badges e localmente no chat para mensagens instantâneas.

---

## 4. Integração Firebase & Notificações Push

As notificações push funcionam com o app fechado seguindo este fluxo:

1. **Tokens**: O app guarda o Token FCM na tabela `tokens_push` ao logar.
2. **Eventos**: Inserção em `mensagens` dispara um trigger SQL.
3. **Edge Function**: Processa o envio via FCM (Google API V1).
4. **Offline**: Se o utilizador estiver offline, a notificação é guardada em `notificacoes_pendentes` e entregue assim que o utilizador abrir o app novamente.

---

## 5. Sistema de Chat Privado

O chat foi desenhado para ser multi-nível e seguro:
- **Identificação**: Cada conversa é identificada pelo par `(trabalhador_id, cliente_id)`.
- **Hierarquia Pro**: Profissional vê primeiro os seus Cards → Clientes interessados → Chat individual.
- **Estados de Mensagem**: 
  - Inserção → `enviado` (✔)
  - Receção via Realtime pelo destinatário → `entregue` (✔✔)
  - Abertura da conversa pelo destinatário → `lido` (✔✔ azul)

---

## 6. Sistema de Badges (Mensagens Não Lidas)

Lógica em cascata para garantir que o utilizador nunca perca uma mensagem:
1. **Global**: Contador no ícone de mensagens na Home (soma de todas as conversas).
2. **Cards**: No painel, cada card mostra quantos clientes têm mensagens pendentes.
3. **Clientes**: Na lista de clientes, mostra quantas mensagens aquele cliente enviou.
- **Realtime**: O `main.dart` escuta a tabela `mensagens` e recalcula os contadores sempre que chega algo novo.

---

## 7. Lógica de Media (Imagens e Documentos)

- **Imagens**: Compressão automática para ~300KB antes do upload.
- **Documentos**: Suporte nativo para PDF e ficheiros Microsoft Office (Word, Excel, PowerPoint) com ícones identificadores.

---

## 8. Sessão e Segurança

- **Persistência**: O `main.dart` valida a sessão no arranque.
- **Blindagem de Tipos**: Conversão segura de `int` para `double` para evitar crashes por dados inconsistentes no banco de dados.

---
**Documentação atualizada em: 30 de Agosto de 2026**
