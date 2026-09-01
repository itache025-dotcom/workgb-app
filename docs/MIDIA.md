# 📸 Sistema de Upload de Mídia — WorkGB

## 🎯 Objetivo
Permitir que utilizadores e profissionais partilhem evidências visuais, certificados e demonstrações de trabalho diretamente através do chat, enriquecendo a comunicação.

---

## 🏗️ Infraestrutura de Armazenamento (Supabase Storage)

Utilizamos o **Supabase Storage** com um bucket dedicado para garantir a segregação e segurança dos ficheiros.

### Bucket: `chat_midia`
- **Configuração**: Público (Public) para facilitar a visualização rápida no app via URL direta.
- **Organização**:
  - `/imagem/`: Armazena ficheiros JPG, PNG, etc.
  - `/video/`: Armazena ficheiros MP4 e outros formatos de vídeo.

---

## 🛠️ Fluxo de Upload

1.  **Captura**: O utilizador clica no ícone `+` no chat e escolhe entre Galeria ou Câmara.
2.  **Processamento Local**:
    - **Fotos**: São capturadas via `image_picker`. (Nota: O app já possui lógica de compressão para cards que pode ser estendida para o chat).
    - **Vídeos**: Capturados via `image_picker.pickVideo`.
3.  **Transferência**:
    - O `SupabaseService.uploadMidia` envia o ficheiro para o bucket `chat_midia`.
    - O nome do ficheiro é gerado usando o timestamp atual para evitar duplicados: `${DateTime.now().millisecondsSinceEpoch}_nome.ext`.
4.  **Persistência**: Após o upload bem-sucedido, uma mensagem do tipo `imagem` ou `video` é inserida na tabela `mensagens` contendo o URL público gerado.

---

## 📺 Visualização e Playback

### Imagens
- Exibidas em bolhas de chat com tamanho controlado (200x200).
- Suporte a **clique para ampliar**: Abre em ecrã inteiro com `InteractiveViewer` para zoom.
- Indicador de carregamento (`CircularProgressIndicator`) enquanto a imagem é descarregada.

### Vídeos
- **Player Integrado**: Utilizamos o pacote `video_player`.
- **Experiência**: O vídeo carrega uma miniatura e mostra um botão de "Play" central. A reprodução acontece dentro da própria conversa.
- **Gestão de Memória**: O controlador do vídeo é descartado (`dispose`) automaticamente quando a bolha sai do ecrã ou o chat é fechado.

---

## ⚙️ Especificações Técnicas

| Recurso | Tecnologia/Pacote |
|---------|-------------------|
| Seleção | `image_picker` |
| Upload | `supabase_flutter` (Storage API) |
| Player Vídeo | `video_player` |
| Zoom Imagem | `InteractiveViewer` (Nativo Flutter) |

---
**Documento criado em: 31 de Agosto de 2026**
