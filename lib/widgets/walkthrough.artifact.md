# Walkthrough - Implementação da Autenticação (Fase 1)

As novas telas de Login e Cadastro foram vinculadas com sucesso ao backend do Supabase, utilizando os serviços existentes de autenticação, validação e localização.

## Alterações Realizadas

### 1. Login (`tela_login_novo.dart`)
- **Controladores:** Adicionados `TextEditingController` para capturar email e senha.
- **Método `_login()`:** Implementada a chamada ao `AuthService().loginUsuario`.
- **Navegação:**
    - Se for **Profissional**, redireciona para `TelaDashboardNovo`.
    - Se for **Cliente**, redireciona para `TelaFeedNovo`.
- **Feedback:** Adicionado estado de carregamento (`CircularProgressIndicator`) no botão e exibição de erros amigáveis via `SnackBar`.

### 2. Cadastro (`tela_cadastro_novo.dart`)
- **Formulário:** Implementada validação de campos obrigatórios e validação de telefone GB (95/96).
- **GPS:** Adicionada captura automática de latitude/longitude via `LocalizacaoService`.
- **Mapeamento de Conta:** O botão seletor de "Cliente/Profissional" agora define corretamente o tipo de utilizador no backend.
- **Fluxo:** Utilizador é logado e redirecionado automaticamente após o cadastro bem-sucedido.

## Verificação Técnica

- **Limpeza e Dependências:** Executados `flutter clean` e `flutter pub get` sem erros.
- **Validações:**
    - Email inválido ou campos vazios são bloqueados.
    - Senhas que não coincidem são bloqueadas.
    - Erros do Supabase (ex: email já existente) são traduzidos para o utilizador.

> [!TIP]
> O design visual das telas permaneceu intacto, apenas a lógica funcional foi "injetada" nos widgets existentes.
