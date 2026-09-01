# 📋 Sistema de Notificações Push — WorkGB

## 🎯 Objetivo
Garantir que os profissionais e clientes nunca percam uma oportunidade de negócio, recebendo alertas em tempo real sobre novas mensagens, mesmo com o app fechado ou telemóvel bloqueado.

---

## 🏗️ Fluxo de Entrega (Full Stack)

### 1. Mensagem Enviada
Quando um utilizador envia uma mensagem via `TelaChat`, o registo é inserido na tabela `mensagens` do Supabase.

### 2. Gatilho SQL (Trigger)
Um gatilho no PostgreSQL deteta a nova linha e chama uma **Edge Function** via `pg_net`.
```sql
CREATE TRIGGER trigger_notificar_mensagem
AFTER INSERT ON mensagens
FOR EACH ROW EXECUTE FUNCTION notificar_mensagem_function();
```

### 3. Supabase Edge Function
A função escrita em TypeScript:
1. Identifica o recetor (cliente ou dono do card).
2. Procura o Token FCM na tabela `tokens_push`.
3. Se o token existir: Envia a notificação via Firebase API V1 com autenticação **OAuth2**.
4. Se o envio falhar (recetor offline): Regista o alerta na tabela `notificacoes_pendentes`.

### 4. Entrega em Cascata (Offline Mode)
Se o utilizador estava sem internet e volta a ligar o app:
- O `main.dart` consulta a tabela `notificacoes_pendentes`.
- Dispara notificações locais para cada mensagem perdida.
- Limpa o histórico de pendentes no servidor.

---

## ⚙️ Regras de Notificação

1. **Canal de Notificação**: No Android, utilizamos o canal `mensagens_channel` com importância máxima para garantir que o utilizador ouça e veja o alerta imediatamente.
2. **Bloqueio de Auto-Notificação**: O sistema deteta quem enviou a mensagem e nunca envia notificação push para o próprio remetente.
3. **Ciclo de Vida do Token**:
   - **Login**: Token é capturado e guardado/atualizado.
   - **Logout**: O token é removido da base de dados para que o telemóvel pare de receber alertas daquela conta.
4. **Prioridade Máxima**: Configurado para `high priority`, garantindo que o alerta apareça mesmo em modo de poupança de bateria.

---

## 🛠️ Tecnologias Envolvidas

- **Firebase Cloud Messaging (FCM)**: Canal de transporte.
- **Flutter Local Notifications**: Exibição visual quando o app está em primeiro plano ou a recuperar mensagens offline.
- **Deno / TypeScript**: Lógica da Edge Function.
- **PostgreSQL (Supabase)**: Gestão de tokens e gatilhos de eventos.

---

## 🐛 Histórico de Resolução de Problemas

- **Notificações não chegavam em background**: Corrigido o formato do JSON enviado ao Firebase (priority movida para o bloco `android`).
- **Sessões corrompidas**: Implementada limpeza forçada de tokens no logout para evitar notificações em contas erradas.
- **Deep Link Invalido**: Removido redirecionamento complexo em favor de abertura direta no ecrã de mensagens.

---
**Documentação atualizada em: 31 de Agosto de 2026**
