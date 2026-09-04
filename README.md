# 🇬🇼 Lirify — Marketplace de Talentos da Guiné-Bissau

**Lirify** é uma aplicação móvel moderna desenvolvida em Flutter, concebida para conectar prestadores de serviços (profissionais) e clientes na Guiné-Bissau. O projeto resolve a dificuldade de encontrar mão-de-obra qualificada e de confiança, oferecendo uma plataforma centralizada para a descoberta, contacto e avaliação de talentos locais.

---

## 🚀 Visão Geral

O Lirify funciona como um marketplace onde profissionais de diversas áreas (desde eletricistas a cabeleireiras) podem publicar os seus serviços através de "cards" digitais. Os clientes podem navegar por estes cards, filtrar por profissão ou bairro, ver certificados, ler avaliações e iniciar conversas diretas via chat ou chamadas.

---

## ✅ Funcionalidades Atuais

### 👤 Para Clientes
- **Feed de Talentos:** Visualização em grid estilo Pinterest de todos os profissionais.
- **Pesquisa Inteligente:** Procura por nome, profissão ou palavras-chave na descrição.
- **Filtros Dinâmicos:** Filtragem rápida por Profissão e Bairro de Bissau.
- **Perfil Completo:** Acesso a detalhes, fotos, localização e disponibilidade.
- **Chat Interno:** Comunicação em tempo real sem partilhar dados pessoais imediatamente.
- **Contacto Direto:** Botões de atalho para chamadas telefónicas e WhatsApp.
- **Avaliações:** Sistema de feedback com estrelas e comentários para garantir qualidade.
- **Documentação:** Visualização de certificados e documentos enviados pelo profissional.
- **Gestão de Conta:** Criação de perfil de cliente e histórico de conversas.

### 💼 Para Profissionais
- **Painel de Gestão:** Dashboard centralizado para gerir todos os serviços.
- **Publicação de Cards:** Criação simplificada de anúncios de serviço com foto e detalhes.
- **Gestão de Serviços:** Editar ou eliminar cards existentes a qualquer momento.
- **Controlo de Disponibilidade:** Definição de dias da semana e horários de atendimento.
- **Gestão de Reputação:** Visualização de avaliações recebidas e possibilidade de resposta.
- **Centro de Mensagens:** Acesso a todas as conversas iniciadas por potenciais clientes.
- **Notificações Push:** Alertas em tempo real (mesmo com o app fechado) para novas mensagens.

### ⚙️ Funcionalidades Gerais
- **🌙 Modo Dark Automático:** O app adapta-se ao tema do sistema do utilizador.
- **📱 Responsividade:** Design otimizado para telemóveis, tablets e visualização em desktop.
- **📸 Upload Inteligente:** Compressão automática de imagens para poupança de dados.
- **📎 Suporte Multi-Ficheiro:** Upload de PDF, DOCX, XLSX, PPTX e imagens para certificados.
- **🔄 Verificação de Versão:** Alerta automático quando uma nova versão do app está disponível.

---

## 🛠️ Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend (BaaS):** [Supabase](https://supabase.com/)
  - Base de Dados (PostgreSQL)
  - Autenticação (Auth)
  - Armazenamento de Ficheiros (Storage)
  - Notificações em Tempo Real (Realtime)
  - Edge Functions (TypeScript/Deno)
- **Notificações:** [Firebase Cloud Messaging (FCM)](https://firebase.google.com/docs/cloud-messaging)
- **Gestão de Estado:** [Provider](https://pub.dev/packages/provider)
- **Base de Dados Offline/Cache:** [Shared Preferences](https://pub.dev/packages/shared_preferences)

---

## 🏗️ Arquitetura do Projeto

A estrutura segue as melhores práticas de organização do Flutter:

```text
lib/
├── modelos/       # Classes de dados (UsuarioModel, TrabalhadorModel)
├── provedores/    # Estado global da aplicação (EstadoGlobal)
├── servicos/      # Lógica de negócio e integrações (Supabase, Firebase, Auth)
├── telas/         # Interface do utilizador (Toda a UI dividida por ecrãs)
└── main.dart      # Ponto de entrada e configuração de serviços
```

### Principais Serviços
- `AuthService`: Gestão de sessões, login, registo e segurança.
- `SupabaseService`: CRUD de cards, mensagens, avaliações e uploads.
- `ServicoErros`: Tradução de erros técnicos para mensagens humanas em português.
- `ImagemService`: Processamento e compressão de ficheiros media.

---

## 📦 Instalação e Configuração

### Pré-requisitos
- Flutter SDK instalado.
- Android Studio ou VS Code configurado.

### Passos
1. Clone o repositório:
   ```bash
   git clone https://github.com/itache025-dotcom/workgb-app.git
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Configure o Firebase:
   - Coloque o ficheiro `google-services.json` em `android/app/`.
4. Execute a aplicação:
   ```bash
   flutter run
   ```

---

## 📌 Versões
- **v1.0.1+2** — Implementação do Modo Dark, Sistema de Chat Interno e Notificações Push estáveis.
- **v1.0.2** — Correções de permissões Android e melhorias na sessão persistente.
- **v1.0.1** — Refatoração do sistema de filtros e carregamento de imagens.
- **v1.0.0** — Lançamento inicial do marketplace.

---

## 📝 Licença

Este projeto é de uso interno e privado para a plataforma Lirify.

---
**Lirify — Conectando a Guiné-Bissau ao talento que precisa.** 😊🇬🇼
