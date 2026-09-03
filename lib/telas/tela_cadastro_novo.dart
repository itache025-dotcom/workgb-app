import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import '../servicos/localizacao_service.dart';
import '../servicos/servico_erros.dart';
import '../servicos/validacao_service.dart';
import '../temas/cores_novo.dart';
import '../widgets/logo_novo.dart';
import '../widgets/botao_novo.dart';
import '../widgets/badge_gb_novo.dart';
import 'professional/tela_dashboard_novo.dart';
import 'tela_login_novo.dart';
import 'tela_feed_novo.dart';

class TelaCadastroNovo extends StatefulWidget {
  final bool profissional;

  const TelaCadastroNovo({super.key, this.profissional = false});

  @override
  State<TelaCadastroNovo> createState() => _TelaCadastroNovoState();
}

class _TelaCadastroNovoState extends State<TelaCadastroNovo> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late String _accountType;
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _acceptTerms = true;
  bool _carregando = false;

  String? _bairroSelecionado;
  String? _profissaoSelecionada;

  final List<String> _bairros = [
    'Bairro Militar', 'Belém', 'Quelélé', 'Luanda', 'Bairro de Ajuda',
    'Antula', 'Bissalanca', 'Cuntum', 'Pefine', 'Cupelom', 'Outro',
  ];

  final List<String> _profissoes = [
    'Canalizador', 'Eletricista', 'Motorista', 'Cozinheira', 'Cabeleireira',
    'Pintor', 'Costureira', 'Babá', 'Jardineiro', 'Lavadeira', 'Outra',
  ];

  @override
  void initState() {
    super.initState();
    _accountType = widget.profissional ? 'Profissional' : 'Cliente';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aceite os termos para continuar')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      double lat = 0;
      double lng = 0;
      try {
        final localizacao = await LocalizacaoService.obterLocalizacao();
        lat = localizacao['lat']!;
        lng = localizacao['lng']!;
      } catch (e) {
        print('Localização não obtida: $e');
      }

      final tipo = _accountType.toLowerCase();
      
      final usuario = await _authService.cadastrarUsuario(
        nomeUsuario: _nomeController.text.trim(),
        emailUsuario: _emailController.text.trim(),
        telefoneUsuario: _telefoneController.text.trim(),
        senhaUsuario: _senhaController.text,
        lat: lat,
        lng: lng,
        tipoUsuario: tipo,
      );

      if (mounted) {
        Provider.of<EstadoGlobal>(context, listen: false).definirUsuarioLogado(usuario);

        if (usuario.tipoUsuario == 'profissional') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TelaDashboardNovo()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TelaFeedNovo()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final mensagem = ServicoErros.obterMensagemAmigavel(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CoresNovo.navyPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const SizedBox(height: 24),
              const LogoNovo(fontSize: 28),
              const SizedBox(height: 20),
              const Text(
                'Criar Conta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CoresNovo.navyPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Junte-se à maior rede de serviços da Guiné-Bissau',
                style: TextStyle(color: CoresNovo.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Account Type Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildAccountTypeButton('Cliente'),
                    _buildAccountTypeButton('Profissional'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildFieldLabel('Nome completo'),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  hintText: 'Ex: Bacar Sanhá',
                  prefixIcon: const Icon(Icons.person, color: CoresNovo.navyPrimary, size: 20),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Email'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'exemplo@email.com',
                  prefixIcon: const Icon(Icons.email, color: CoresNovo.navyPrimary, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email obrigatório';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Telefone (Guiné-Bissau)'),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '955 123 456',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: BadgeGBNovo(),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Telefone obrigatório';
                  if (!ValidacaoService.validarTelefone(v)) return 'Telefone inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Senha'),
              TextFormField(
                controller: _senhaController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock, color: CoresNovo.navyPrimary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: CoresNovo.textSecondary, size: 20),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Confirmar Senha'),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: _obscureConfirmText,
                decoration: InputDecoration(
                  hintText: 'Repita a sua senha',
                  prefixIcon: const Icon(Icons.lock_outline, color: CoresNovo.navyPrimary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmText ? Icons.visibility : Icons.visibility_off, color: CoresNovo.textSecondary, size: 20),
                    onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
                  ),
                ),
                validator: (v) {
                  if (v != _senhaController.text) return 'Senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (_accountType == 'Profissional') ...[
                _buildFieldLabel('Bairro'),
                DropdownButtonFormField<String>(
                  value: _bairroSelecionado,
                  decoration: const InputDecoration(
                    hintText: 'Selecione o seu bairro',
                    prefixIcon: Icon(Icons.location_on_outlined, color: CoresNovo.navyPrimary, size: 20),
                  ),
                  items: _bairros.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (v) => setState(() => _bairroSelecionado = v),
                ),
                if (_bairroSelecionado == 'Outro') ...[
                  const SizedBox(height: 16),
                  _buildFieldLabel('Qual o teu bairro?'),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Digite o nome do seu bairro',
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                _buildFieldLabel('Profissão'),
                DropdownButtonFormField<String>(
                  value: _profissaoSelecionada,
                  decoration: const InputDecoration(
                    hintText: 'Selecione a sua profissão',
                    prefixIcon: Icon(Icons.work_outline, color: CoresNovo.navyPrimary, size: 20),
                  ),
                  items: _profissoes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _profissaoSelecionada = v),
                ),
                if (_profissaoSelecionada == 'Outra') ...[
                  const SizedBox(height: 16),
                  _buildFieldLabel('Qual a tua profissão?'),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Digite a sua profissão',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (v) => setState(() => _acceptTerms = v!),
                    activeColor: CoresNovo.navyPrimary,
                  ),
                  const Expanded(
                    child: Text(
                      'Concordo com os Termos de Serviço e Política de Privacidade do WorkGB',
                      style: TextStyle(fontSize: 12, color: CoresNovo.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              BotaoNovo(
                texto: 'Criar Conta',
                isLoading: _carregando,
                onPressed: _carregando ? null : _cadastrar,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tens uma conta? ', style: TextStyle(fontSize: 14, color: CoresNovo.textSecondary)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TelaLoginNovo()),
                      );
                    },
                    child: const Text(
                      'Entrar',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresNovo.navyPrimary),
        ),
      ),
    );
  }

  Widget _buildAccountTypeButton(String type) {
    final isSelected = _accountType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _accountType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? CoresNovo.navyPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Sou $type',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected ? Colors.white : CoresNovo.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
