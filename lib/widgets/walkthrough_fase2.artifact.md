# Walkthrough - Feed e Perfil com Dados Reais (Fase 2)

As novas telas de Feed e Perfil foram totalmente integradas ao Supabase, permitindo que os utilizadores visualizem profissionais reais e os seus detalhes.

## Alterações Realizadas

### 1. Feed do Cliente (`tela_feed_novo.dart`)
- **Carregamento Dinâmico:** Integrado o `SupabaseService` para listar profissionais reais em vez de usar dados estáticos.
- **Estado Global:** Os dados são sincronizados com o `EstadoGlobal` para persistência e performance.
- **Filtros Inteligentes:**
    - Os dropdowns de **Profissão** e **Bairro** agora são gerados dinamicamente com base nos dados presentes no banco de dados.
    - A filtragem local foi implementada para uma resposta instantânea ao utilizador.
- **UI Adaptativa:**
    - Cards de profissionais agora mostram a foto real, nome, bairro (extraído da descrição) e média de avaliações dinâmica.
    - Adicionado suporte a placeholders visuais caso o profissional não tenha foto.

### 2. Perfil do Profissional (`tela_perfil_novo.dart`)
- **Conversão para Dinâmico:** A tela agora recebe um objeto `TrabalhadorModel` e exibe os seus dados reais.
- **Avaliações Reais:** Implementada a busca de comentários e notas diretamente do banco de dados.
- **Canais de Contacto:**
    - **Ligar:** Abre o discador com o número extraído do perfil.
    - **WhatsApp:** Inicia uma conversa direta com o prefixo da Guiné-Bissau (+245).
    - **Chat:** Navega para a `TelaChat` funcional para mensagens em tempo real.
- **Galeria:** O campo de documentos agora alimenta a secção de galeria de trabalhos concluídos.

## Verificação Técnica

- **Navegação:** O fluxo Feed -> Perfil está a passar o modelo de dados corretamente.
- **Performance:** Uso de `FutureBuilder` para carregar avaliações e média de estrelas sem bloquear a UI principal.
- **Robustez:** Implementado tratamento para casos de descrição vazia ou falta de geolocalização.

> [!NOTE]
> O visual "Pinterest" e o design moderno foram mantidos, apenas os dados por trás dos widgets foram substituídos por informação real do sistema.
