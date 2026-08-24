# Resumo Técnico: Causa Raiz e Resolução de Problemas (v1.0.1)

Este documento detalha os problemas críticos identificados durante o desenvolvimento e como foram resolvidos para estabilizar a aplicação WorkGB.

## 1. Problema: Falha no Carregamento de Cards (Erro de Tipo)
**Sintoma:** O Feed mostrava "Erro ao carregar trabalhadores" ou "Nenhum trabalhador disponível".
**Logs:** `type 'int' is not a subtype of type 'double'`.

### Causa Raiz
O Supabase armazena números decimais como `float8`. No entanto, quando um valor é um número redondo (ex: `0`, `1`, `10`), o JSON retornado pelo Supabase trata-os como `int`. O Dart, sendo fortemente tipado, lança uma exceção ao tentar mapear um `int` diretamente para um campo declarado como `double?` no modelo.

### Resolução
Implementada a classe utilitária `Conversao.converterParaDouble()`. Esta função verifica o tipo em tempo de execução:
- Se for `int`, chama `.toDouble()`.
- Se for `null`, mantém `null`.
- Se for `String`, tenta fazer `parse`.
- Se já for `double`, mantém o valor.

## 2. Problema: Falha de Autenticação (Credenciais Inválidas)
**Sintoma:** Utilizadores não conseguiam fazer login mesmo com a senha correta.

### Causa Raiz
A instabilidade foi causada por sessões locais corrompidas após múltiplos testes com fluxos de **OTP (One-Time Password)** e **Magic Links**. O Supabase Auth mantinha tokens de sessão expirados ou inválidos no armazenamento local do dispositivo, que entravam em conflito com as novas tentativas de login por senha tradicional.

### Resolução
- Simplificação total do `AuthService` para remover métodos de OTP e recuperação complexos.
- Adição de logs de depuração para monitorizar a resposta bruta do servidor Auth.
- Instrução de limpeza de cache/reinstalação para os dispositivos de teste, garantindo que o `signInWithPassword` comece com um estado limpo.

## 3. Mensagem de Commit Sugerida
```text
refactor: simplificar login e corrigir erro de tipos Supabase

- Implementar conversão segura de int para double (corrige crash nos cards)
- Remover fluxo de login OTP/Link instável (volta para Email+Senha)
- Adicionar sistema de avaliações completo (Feed, Perfil, Painel)
- Criar tela "Minhas Avaliações" no Painel do Profissional
- Limpar configurações de Deep Link no AndroidManifest
- Incrementar versão para 1.0.1+2
```

## 4. Lista de Ficheiros Alterados
- `pubspec.yaml` (Versão 1.0.1+2)
- `lib/servicos/conversao.dart` (Novo: Blindagem de tipos)
- `lib/servicos/supabase_service.dart` (Mapeamento seguro e novos métodos de avaliação)
- `lib/servicos/auth_service.dart` (Simplificação e logs)
- `lib/modelos/trabalhador_model.dart` (Novos campos de avaliação)
- `lib/telas/tela_feed.dart` (UI de estrelas)
- `lib/telas/tela_perfil.dart` (Avaliações anónimas)
- `lib/telas/tela_avaliar.dart` (Novo: Fluxo de avaliação)
- `lib/telas/tela_minhas_avaliacoes.dart` (Novo: Gestão para profissionais)
- `lib/main.dart` (Restauração da estabilidade)
- `android/app/src/main/AndroidManifest.xml` (Limpeza)
