# 🇬🇼 WorkGB — Marketplace de Talentos da Guiné-Bissau

**WorkGB** é uma aplicação móvel moderna desenvolvida em Flutter, concebida para conectar prestadores de serviços (profissionais) e clientes na Guiné-Bissau. O projeto resolve a dificuldade de encontrar mão-de-obra qualificada e de confiança, oferecendo uma plataforma centralizada para a descoberta, contacto e avaliação de talentos locais.

---

## 🚀 Visão Geral

O WorkGB funciona como um marketplace onde profissionais de diversas áreas (desde eletricistas a cabeleireiras) podem publicar os seus serviços através de "cards" digitais. Os clientes podem navegar por estes cards, filtrar por profissão ou bairro, ver certificados, ler avaliações e iniciar conversas diretas via chat ou chamadas.

---

## ✅ Funcionalidades Atuais

### 👤 Para Clientes
- **Feed de Talentos:** Visualização em grid estilo Pinterest de todos os profissionais com média de avaliações (estrelas).
- **Pesquisa Inteligente:** Procura por nome, profissão ou palavras-chave na descrição.
- **Filtros Dinâmicos:** Filtragem rápida por Profissão e Bairro de Bissau.
- **Perfil Completo:** Acesso a detalhes, fotos, localização e disponibilidade.
- **Chat Privado:** Comunicação em tempo real com suporte a fotos, vídeos e indicadores de estado (✔ enviado, ✔✔ entregue, ✔✔ lido).
- **Badges de Mensagens:** Indicadores numéricos de mensagens pendentes em tempo real.
- **Contacto Direto:** Botões de atalho para chamadas telefónicas e WhatsApp com rastreio inteligente.
- **Avaliações:** Sistema de feedback com estrelas e comentários, permitindo avaliações mesmo sem login para facilitar o uso.

### 💼 Para Profissionais
- **Painel de Gestão:** Dashboard centralizado para gerir serviços, mensagens e reputação.
- **Publicação de Cards:** Criação simplificada de anúncios de serviço com foto e detalhes.
- **Gestão de Serviços:** Editar ou eliminar cards existentes a qualquer momento.
- **Controlo de Disponibilidade:** Definição de dias da semana e horários de atendimento.
- **Gestão de Reputação:** Visualização de avaliações recebidas e possibilidade de resposta direta.
- **Centro de Mensagens Pro:** Organização multi-nível (Card → Cliente → Chat) para gerir volume de contactos.
- **Notificações Push:** Alertas em tempo real (mesmo com o app fechado) para novas mensagens.

### ⚙️ Funcionalidades Gerais
- **🌙 Modo Dark Automático:** O app adapta-se ao tema do sistema do utilizador.
- **📱 Responsividade:** Design otimizado para telemóveis, tablets e visualização em desktop.
- **📸 Upload Inteligente:** Compressão automática de imagens para poupança de dados.
- **📎 Suporte Multi-Ficheiro:** Upload de PDF, DOCX, XLSX, PPTX e imagens para certificados.
- **🔄 Atualização Automática:** Verificação de novas versões via GitHub Releases.

---

## 🛠️ Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend (BaaS):** [Supabase](https://supabase.com/)
  - Base de Dados (PostgreSQL)
  - Autenticação (Auth)
  - Storage (Buckets `fotos`, `documentos`, `chat_midia`)
  - Notificações em Tempo Real (Realtime)
  - Edge Functions (TypeScript/Deno)
- **Notificações:** [Firebase Cloud Messaging (FCM)](https://firebase.google.com/docs/cloud-messaging)
- **Gestão de Estado:** [Provider](https://pub.dev/packages/provider)
- **Base de Dados Offline/Cache:** [Shared Preferences](https://pub.dev/packages/shared_preferences)

---

## 📖 Documentação Detalhada

Para aprofundar o conhecimento sobre módulos específicos, consulte:
- [🏗️ Arquitetura do Sistema](ARQUITETURA.md)
- [💬 Chat e Mensagens](CHAT.md)
- [📸 Gestão de Mídia](MIDIA.md)
- [📋 Sistema de Notificações](NOTIFICACOES.md)
- [🔴 Sistema de Badges](BADGES.md)

---
**Documentação atualizada em: 31 de Agosto de 2026**
