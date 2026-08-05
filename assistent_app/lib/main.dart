import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GideonAssistenteApp());
}

class GideonAssistenteApp extends StatelessWidget {
  const GideonAssistenteApp({super.key});

  static const Color darkBg = Color(0xFF090A0F);
  static const Color cardBg = Color(0xFF13151C);
  static const Color cardBorder = Color(0xFF222634);
  static const Color neonLime = Color(0xFFCCFF00);
  static const Color subtext = Color(0xFF8E96A8);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gideon • Finanças & Assistente IA',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(
          surface: cardBg,
          primary: neonLime,
          onPrimary: Colors.black,
          secondary: Color(0xFF38BDF8),
        ),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  double _saldoEmContas = 131.38;
  double? _gastosMesManual;
  bool _ocultarValores = false;
  String _geminiApiKey = '';
  String _filtroAtividades = '';

  // Transações / Atividades
  final List<Map<String, dynamic>> _despesas = [
    {
      'desc': 'Transferência enviada',
      'category': 'Apostas',
      'amount': 10.00,
      'date': 'Hoje',
      'banco': 'Nubank',
      'pago': true
    },
    {
      'desc': 'Compra no débito via Nu',
      'category': 'Serviços',
      'amount': 11.30,
      'date': 'Ontem',
      'banco': 'Nubank',
      'pago': true
    },
    {
      'desc': 'Supermercado',
      'category': 'Alimentação',
      'amount': 26.68,
      'date': 'Ontem',
      'banco': 'Nubank',
      'pago': true
    },
  ];

  // Lista de Compras Interativa
  final List<Map<String, dynamic>> _listaCompras = [
    {'nome': 'Cama Casal King', 'valor': 1400.00, 'comprado': false},
    {'nome': 'Jogo de Panelas Inox', 'valor': 350.00, 'comprado': true},
    {'nome': 'Kit 6 Copos de Cristal', 'valor': 89.90, 'comprado': false},
  ];

  // Contas & Vencimentos
  final List<Map<String, dynamic>> _contasVencimento = [
    {
      'nome': 'Aluguel do Mês',
      'valor': 1200.0,
      'vencimento': '10/08/2026',
      'paga': false
    },
    {
      'nome': 'Conta de Luz (ENEL)',
      'valor': 185.50,
      'vencimento': '15/08/2026',
      'paga': false
    },
    {
      'nome': 'Internet Fibra 500MB',
      'valor': 119.90,
      'vencimento': '05/08/2026',
      'paga': true
    },
  ];

  // Lista Já Possuo (Inventário)
  final List<String> _jaPossuo = [
    'Geladeira Frost Free 400L',
    'Máquina de Lavar 12kg',
    'Smart TV 55" 4K',
    'Micro-ondas 30L Stainless'
  ];

  // Mensagens do Chat IA
  final List<Map<String, String>> _chatMsgs = [
    {
      'autor': 'bot',
      'texto':
          'Olá, Taylane! Sou a Gideon. Como posso te ajudar nas tuas finanças hoje?'
    },
  ];

  // Controllers para formulários e chat
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollChatController = ScrollController();
  bool _isChatOverlayOpen = false;

  final TextEditingController _editSaldoController = TextEditingController();
  final TextEditingController _editGastadoController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _comprarNomeController = TextEditingController();
  final TextEditingController _comprarValorController = TextEditingController();
  final TextEditingController _contaNomeController = TextEditingController();
  final TextEditingController _contaValorController = TextEditingController();
  final TextEditingController _contaDataController = TextEditingController();
  final TextEditingController _possuoController = TextEditingController();
  final TextEditingController _ofxTextController = TextEditingController();
  final TextEditingController _buscaAtividadesController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    _scrollChatController.dispose();
    _editSaldoController.dispose();
    _editGastadoController.dispose();
    _apiKeyController.dispose();
    _comprarNomeController.dispose();
    _comprarValorController.dispose();
    _contaNomeController.dispose();
    _contaValorController.dispose();
    _contaDataController.dispose();
    _possuoController.dispose();
    _ofxTextController.dispose();
    _buscaAtividadesController.dispose();
    super.dispose();
  }

  // Cálculo automático de todas as despesas lançadas
  double get _totalCalculadoDespesas {
    double sum = 0;
    for (var d in _despesas) {
      sum += (d['amount'] as num).toDouble();
    }
    for (var c in _listaCompras) {
      if (c['comprado'] == true) {
        sum += (c['valor'] as num).toDouble();
      }
    }
    return sum;
  }

  double get _gastosMesFinal => _gastosMesManual ?? _totalCalculadoDespesas;

  // Cálculos dinâmicos da Lista de Compras
  double get _totalComprasEstimado {
    double sum = 0;
    for (var c in _listaCompras) {
      sum += (c['valor'] as num).toDouble();
    }
    return sum;
  }

  double get _totalComprasConcluidas {
    double sum = 0;
    for (var c in _listaCompras) {
      if (c['comprado'] == true) {
        sum += (c['valor'] as num).toDouble();
      }
    }
    return sum;
  }

  int get _qtdComprasConcluidas {
    return _listaCompras.where((c) => c['comprado'] == true).length;
  }

  // Card helpers
  Widget _buildPierreCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    VoidCallback? onTap,
    Color? borderColor,
  }) {
    final cardWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: GideonAssistenteApp.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: cardWidget,
      );
    }
    return cardWidget;
  }

  String _formatMoney(double val) {
    if (_ocultarValores) return '••••••';
    return 'R\$ ${val.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _processarMensagemUser(String input) {
    if (input.trim().isEmpty) return;
    final text = input.trim();

    setState(() {
      _chatMsgs.add({'autor': 'user', 'texto': text});
      _chatController.clear();
    });

    final lower = text.toLowerCase();

    // Comando para ajustar saldo
    final matchSaldo = RegExp(
            r'(?:saldo\s+(?:é|e)|saldo\s+de)\s*R?\$?\s*([\d\.,]+)',
            caseSensitive: false)
        .firstMatch(lower);
    if (matchSaldo != null) {
      final valStr =
          matchSaldo.group(1)!.replaceAll('.', '').replaceAll(',', '.');
      final val = double.tryParse(valStr) ?? 0.0;
      setState(() {
        _saldoEmContas = val;
        _chatMsgs.add({
          'autor': 'bot',
          'texto': '✅ Saldo em contas ajustado para R\$ ${val.toStringAsFixed(2)}!'
        });
      });
      _scrollToBottomChat();
      return;
    }

    // Comando para lançar gastos rápidos
    final matchGasto = RegExp(
            r'(?:gastei|paguei)\s*R?\$?\s*([\d\.,]+)\s*(?:com|no|na|em)?\s*(.*)',
            caseSensitive: false)
        .firstMatch(lower);
    if (matchGasto != null) {
      final valStr =
          matchGasto.group(1)!.replaceAll('.', '').replaceAll(',', '.');
      final val = double.tryParse(valStr) ?? 0.0;
      final desc = matchGasto.group(2)?.trim().isNotEmpty == true
          ? matchGasto.group(2)!.trim()
          : 'Gasto Rápido';
      setState(() {
        _despesas.insert(0, {
          'desc': desc,
          'category': 'Geral',
          'amount': val,
          'date': 'Hoje',
          'banco': 'Nubank',
          'pago': true,
        });
        _saldoEmContas -= val;
        _chatMsgs.add({
          'autor': 'bot',
          'texto': '💸 Lançado R\$ ${val.toStringAsFixed(2)} em "$desc"! Saldo atualizado.'
        });
      });
      _scrollToBottomChat();
      return;
    }

    // Lançamento de saldo / entrada
    final matchRecebi = RegExp(
            r'(?:recebi|ganhei|pix\s+de)\s*R?\$?\s*([\d\.,]+)\s*(?:de|da)?\s*(.*)',
            caseSensitive: false)
        .firstMatch(lower);
    if (matchRecebi != null) {
      final valStr =
          matchRecebi.group(1)!.replaceAll('.', '').replaceAll(',', '.');
      final val = double.tryParse(valStr) ?? 0.0;
      setState(() {
        _saldoEmContas += val;
        _chatMsgs.add({
          'autor': 'bot',
          'texto': '💰 Entrada de R\$ ${val.toStringAsFixed(2)} adicionada ao seu saldo!'
        });
      });
      _scrollToBottomChat();
      return;
    }

    if (_geminiApiKey.isNotEmpty) {
      _chamarGeminiAPI(text);
    } else {
      setState(() {
        _chatMsgs.add({
          'autor': 'bot',
          'texto':
              '🌐 Registrado localmente! Para respostas completas da inteligência artificial ou leitura de fotos, adicione sua chave API no topo.'
        });
      });
      _scrollToBottomChat();
    }
  }

  Future<void> _chamarGeminiAPI(String prompt) async {
    setState(() {
      _chatMsgs.add({'autor': 'bot', 'texto': '⏳ Gideon está analisando...'});
    });
    _scrollToBottomChat();

    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=$_geminiApiKey');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'systemInstruction': {
                'parts': [
                  {
                    'text':
                        'Você é a Gideon, assistente financeira pessoal estilo Pierre. Responda de forma simples, elegante e direta em português.'
                  }
                ]
              }
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        String replyText = 'Sem resposta da IA.';
        if (data.containsKey('candidates') &&
            data['candidates'] is List &&
            (data['candidates'] as List).isNotEmpty) {
          final cand = data['candidates'][0];
          if (cand is Map &&
              cand.containsKey('content') &&
              cand['content'] is Map) {
            final content = cand['content'] as Map;
            if (content.containsKey('parts') &&
                content['parts'] is List &&
                (content['parts'] as List).isNotEmpty) {
              final part = content['parts'][0];
              if (part is Map && part.containsKey('text')) {
                replyText = part['text'].toString();
              }
            }
          }
        }
        setState(() {
          _chatMsgs.removeLast();
          _chatMsgs.add({'autor': 'bot', 'texto': replyText});
        });
      } else {
        setState(() {
          _chatMsgs.removeLast();
          _chatMsgs.add({
            'autor': 'bot',
            'texto':
                '⚠️ Não foi possível conectar ao Gemini. Verifique sua chave API.'
          });
        });
      }
    } catch (_) {
      setState(() {
        _chatMsgs.removeLast();
        _chatMsgs.add({'autor': 'bot', 'texto': '⚠️ Erro ao consultar a IA.'});
      });
    }
    _scrollToBottomChat();
  }

  void _scrollToBottomChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollChatController.hasClients) {
        _scrollChatController.animateTo(
          _scrollChatController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Center(
                              child: Icon(Icons.smart_toy,
                                  color: GideonAssistenteApp.neonLime, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Taylane',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                'Assistente Pessoal & Finanças',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: GideonAssistenteApp.subtext,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                            ),
                            icon: const Icon(Icons.vpn_key_outlined,
                                color: GideonAssistenteApp.neonLime, size: 18),
                            onPressed: _abrirModalChaveApi,
                            tooltip: 'Configurar Chave API',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                            ),
                            icon: Icon(
                              _ocultarValores
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _ocultarValores
                                  ? const Color(0xFFFB7185)
                                  : Colors.white70,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarValores = !_ocultarValores;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Navigation Horizontal Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _buildNavPill(0, 'Início', Icons.pie_chart_outline),
                      const SizedBox(width: 8),
                      _buildNavPill(1, 'Atividades', Icons.list_alt),
                      const SizedBox(width: 8),
                      _buildNavPill(2, 'Compras', Icons.shopping_cart_outlined),
                      const SizedBox(width: 8),
                      _buildNavPill(
                          3, 'Contas', Icons.calendar_today_outlined),
                      const SizedBox(width: 8),
                      _buildNavPill(4, 'Já Possuo', Icons.inventory_2_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          children: [
                            if (_currentTab == 0) _buildTabDashboard(),
                            if (_currentTab == 1) _buildTabAtividades(),
                            if (_currentTab == 2) _buildTabCompras(),
                            if (_currentTab == 3) _buildTabContas(),
                            if (_currentTab == 4) _buildTabPossuo(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Floating Bar: Pergunte à Gideon
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildPierreCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    borderColor: Colors.white.withOpacity(0.12),
                    onTap: () {
                      setState(() {
                        _isChatOverlayOpen = true;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0x22CCFF00),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.qr_code_scanner,
                                  color: GideonAssistenteApp.neonLime,
                                  size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Pergunte à Gideon...',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: GideonAssistenteApp.subtext,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined,
                                  color: Colors.white70, size: 18),
                              onPressed: _simularLeituraPrint,
                              tooltip: 'Ler Print de PIX',
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: GideonAssistenteApp.neonLime,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_upward,
                                  color: Colors.black, size: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isChatOverlayOpen) _buildChatOverlayModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavPill(int index, String label, IconData icon) {
    final isSelected = _currentTab == index;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: isSelected
            ? GideonAssistenteApp.neonLime
            : Colors.white.withOpacity(0.05),
        foregroundColor: isSelected ? Colors.black : Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 14),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      onPressed: () => setState(() => _currentTab = index),
    );
  }

  Widget _buildTabDashboard() {
    final imprevisto = _gastosMesFinal * 0.15;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPierreCard(
                onTap: _abrirModalEditarSaldo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildMiniIconBadge('nu', const Color(0xFF9333EA)),
                            _buildMiniIconBadge('bb', const Color(0xFFFBBF24)),
                            _buildMiniIconBadge('it', const Color(0xFF2563EB)),
                          ],
                        ),
                        const Icon(Icons.chevron_right,
                            size: 14, color: GideonAssistenteApp.subtext),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Saldo em contas',
                        style: TextStyle(
                            fontSize: 11, color: GideonAssistenteApp.subtext)),
                    Text(
                      _formatMoney(_saldoEmContas),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const Text('3 contas conectadas',
                        style: TextStyle(
                            fontSize: 9, color: GideonAssistenteApp.subtext)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPierreCard(
                onTap: _abrirModalEditarGastado,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 8,
                              height: 16,
                              color: GideonAssistenteApp.neonLime),
                          const SizedBox(width: 2),
                          Container(
                              width: 8,
                              height: 24,
                              color: GideonAssistenteApp.neonLime),
                          const SizedBox(width: 2),
                          Container(
                              width: 8,
                              height: 12,
                              color: GideonAssistenteApp.neonLime
                                  .withOpacity(0.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Gastos do mês',
                        style: TextStyle(
                            fontSize: 11, color: GideonAssistenteApp.subtext)),
                    Text(
                      _formatMoney(_gastosMesFinal),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text('${_despesas.length} despesas lançadas',
                        style: const TextStyle(
                            fontSize: 9, color: GideonAssistenteApp.subtext)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPierreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.credit_card,
                                size: 14, color: Color(0xFFFBBF24)),
                            SizedBox(width: 4),
                            Text('•••• 9694',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: GideonAssistenteApp.subtext)),
                          ],
                        ),
                        Icon(Icons.chevron_right,
                            size: 14, color: GideonAssistenteApp.subtext),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Fatura Atual',
                        style: TextStyle(
                            fontSize: 11, color: GideonAssistenteApp.subtext)),
                    Text(
                      _formatMoney(_gastosMesFinal * 1.2),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const Text('Vence em breve',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFFBBF24),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPierreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fluxo de caixa',
                            style: TextStyle(
                                fontSize: 11,
                                color: GideonAssistenteApp.subtext)),
                        Icon(Icons.show_chart,
                            size: 14, color: GideonAssistenteApp.neonLime),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('+R\$ 0,00',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF34D399))),
                    Text('-${_formatMoney(_gastosMesFinal)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFB7185))),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.25,
                        backgroundColor: Colors.white10,
                        color: Color(0xFFFB7185),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPierreCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: GideonAssistenteApp.neonLime, width: 3),
                ),
                child: const Center(
                  child: Text('15%',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: GideonAssistenteApp.neonLime)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fundo de Imprevistos Recomendado',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(
                      'Reserva de ${_formatMoney(imprevisto)} sugerida para custos ocultos.',
                      style: const TextStyle(
                          fontSize: 11, color: GideonAssistenteApp.subtext),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildPierreCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Transações Recentes',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('${_despesas.length}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white)),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentTab = 1),
                    child: const Text('Ver todas',
                        style: TextStyle(
                            color: GideonAssistenteApp.neonLime,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._despesas.take(3).map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildMiniIconBadge('nu', const Color(0xFF9333EA)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d['desc'].toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text('${d['date']} • ${d['category']}',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: GideonAssistenteApp.subtext)),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '-${_formatMoney((d['amount'] as num).toDouble())}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFB7185)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniIconBadge(String text, Color color) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: GideonAssistenteApp.darkBg, width: 1.5),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildTabAtividades() {
    final despesasFiltradas = _despesas.where((d) {
      if (_filtroAtividades.isEmpty) return true;
      final desc = d['desc'].toString().toLowerCase();
      final cat = d['category'].toString().toLowerCase();
      final term = _filtroAtividades.toLowerCase();
      return desc.contains(term) || cat.contains(term);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Atividades & Extrato',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        // Campo de busca em tempo real
        TextField(
          controller: _buscaAtividadesController,
          onChanged: (val) {
            setState(() {
              _filtroAtividades = val;
            });
          },
          style: const TextStyle(fontSize: 12, color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 16, color: GideonAssistenteApp.subtext),
            hintText: 'Buscar despesa ou categoria...',
            hintStyle: const TextStyle(color: GideonAssistenteApp.subtext),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        _buildPierreCard(
          borderColor: const Color(0xFF34D399).withOpacity(0.3),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x2234D399),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.file_present,
                    color: Color(0xFF34D399), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Importar Extrato Bancário',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Ficheiros .OFX ou .CSV do seu banco',
                        style: TextStyle(
                            fontSize: 10, color: GideonAssistenteApp.subtext)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x2234D399),
                  foregroundColor: const Color(0xFF34D399),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _abrirModalImportarOFX,
                child: const Text('Carregar',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (despesasFiltradas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text('Nenhuma transação encontrada.',
                  style: TextStyle(color: GideonAssistenteApp.subtext, fontSize: 12)),
            ),
          )
        else
          ...despesasFiltradas.asMap().entries.map((entry) {
            final idx = entry.key;
            final d = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildPierreCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 18, color: GideonAssistenteApp.subtext),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['desc'].toString(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text('${d['date']} • ${d['category']}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: GideonAssistenteApp.subtext)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '-${_formatMoney((d['amount'] as num).toDouble())}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFB7185)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: GideonAssistenteApp.subtext),
                          onPressed: () {
                            setState(() {
                              _despesas.removeAt(idx);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTabCompras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Lista de Compras',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            if (_listaCompras.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _listaCompras.clear()),
                child: const Text('Limpar tudo',
                    style: TextStyle(color: Color(0xFFFB7185), fontSize: 11)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Cards com a soma total estimada e comprados
        Row(
          children: [
            Expanded(
              child: _buildPierreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Estimado',
                        style: TextStyle(
                            fontSize: 11, color: GideonAssistenteApp.subtext)),
                    const SizedBox(height: 4),
                    Text(_formatMoney(_totalComprasEstimado),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GideonAssistenteApp.neonLime)),
                    Text('${_listaCompras.length} itens no total',
                        style: const TextStyle(
                            fontSize: 9, color: GideonAssistenteApp.subtext)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPierreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Já Comprado',
                        style: TextStyle(
                            fontSize: 11, color: GideonAssistenteApp.subtext)),
                    const SizedBox(height: 4),
                    Text(_formatMoney(_totalComprasConcluidas),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF34D399))),
                    Text('$_qtdComprasConcluidas de ${_listaCompras.length} concluídos',
                        style: const TextStyle(
                            fontSize: 9, color: GideonAssistenteApp.subtext)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Formulário para adicionar novos itens
        _buildPierreCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Adicionar Novo Item',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _comprarNomeController,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ex: Cama Casal, Cortina',
                        hintStyle: const TextStyle(
                            color: GideonAssistenteApp.subtext),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _comprarValorController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Valor (R\$)',
                        hintStyle: const TextStyle(
                            color: GideonAssistenteApp.subtext),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GideonAssistenteApp.neonLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final nome = _comprarNomeController.text.trim();
                    final valor = double.tryParse(_comprarValorController.text
                            .replaceAll(',', '.')) ??
                        0.0;
                    if (nome.isNotEmpty) {
                      setState(() {
                        _listaCompras.add(
                            {'nome': nome, 'valor': valor, 'comprado': false});
                        _comprarNomeController.clear();
                        _comprarValorController.clear();
                      });
                    }
                  },
                  child: const Text('Adicionar à Lista',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Lista interativa de itens
        if (_listaCompras.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text('Sua lista de compras está vazia.',
                  style: TextStyle(color: GideonAssistenteApp.subtext, fontSize: 12)),
            ),
          )
        else
          ..._listaCompras.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final bool comprado = item['comprado'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildPierreCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: comprado,
                          activeColor: GideonAssistenteApp.neonLime,
                          checkColor: Colors.black,
                          onChanged: (val) {
                            setState(() {
                              item['comprado'] = val == true;
                            });
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nome'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: comprado ? Colors.white60 : Colors.white,
                                decoration:
                                    comprado ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(
                                'Est: ${_formatMoney((item['valor'] as num).toDouble())}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: comprado
                                        ? const Color(0xFF34D399)
                                        : GideonAssistenteApp.subtext)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: GideonAssistenteApp.subtext),
                      onPressed: () =>
                          setState(() => _listaCompras.removeAt(idx)),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTabContas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contas & Vencimentos',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildPierreCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agendar Conta',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 10),
              TextField(
                controller: _contaNomeController,
                style: const TextStyle(fontSize: 12, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Descrição (ex: Luz, Aluguel)',
                  hintStyle:
                      const TextStyle(color: GideonAssistenteApp.subtext),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contaValorController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Valor (R\$)',
                        hintStyle: const TextStyle(
                            color: GideonAssistenteApp.subtext),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _contaDataController,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Vencimento (10/08)',
                        hintStyle: const TextStyle(
                            color: GideonAssistenteApp.subtext),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final nome = _contaNomeController.text.trim();
                    final valor = double.tryParse(_contaValorController.text
                            .replaceAll(',', '.')) ??
                        0.0;
                    final data = _contaDataController.text.trim();
                    if (nome.isNotEmpty) {
                      setState(() {
                        _contasVencimento.add({
                          'nome': nome,
                          'valor': valor,
                          'vencimento': data,
                          'paga': false
                        });
                        _contaNomeController.clear();
                        _contaValorController.clear();
                        _contaDataController.clear();
                      });
                    }
                  },
                  child: const Text('Salvar Agendamento',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._contasVencimento.asMap().entries.map((entry) {
          final idx = entry.key;
          final c = entry.value;
          final bool paga = c['paga'] == true;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildPierreCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          paga ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: paga ? const Color(0xFF34D399) : GideonAssistenteApp.subtext,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            c['paga'] = !paga;
                            if (c['paga'] == true) {
                              _despesas.insert(0, {
                                'desc': c['nome'],
                                'category': 'Contas Fixas',
                                'amount': (c['valor'] as num).toDouble(),
                                'date': 'Hoje',
                                'banco': 'Nubank',
                                'pago': true,
                              });
                              _saldoEmContas -= (c['valor'] as num).toDouble();
                            }
                          });
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['nome'].toString(),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: paga ? TextDecoration.lineThrough : null),
                          ),
                          Text(
                            paga ? 'Paga com sucesso' : 'Vence: ${c['vencimento']}',
                            style: TextStyle(
                                fontSize: 10,
                                color: paga ? const Color(0xFF34D399) : GideonAssistenteApp.subtext),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _formatMoney((c['valor'] as num).toDouble()),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: paga ? const Color(0xFF34D399) : const Color(0xFFFB7185)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 16, color: GideonAssistenteApp.subtext),
                        onPressed: () =>
                            setState(() => _contasVencimento.removeAt(idx)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTabPossuo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Objetos & Móveis (Já Possuo)',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildPierreCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _possuoController,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ex: Geladeira, Sofá, Micro-ondas',
                        hintStyle: const TextStyle(
                            color: GideonAssistenteApp.subtext),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_possuoController.text.trim().isNotEmpty) {
                        setState(() {
                          _jaPossuo.add(_possuoController.text.trim());
                          _possuoController.clear();
                        });
                      }
                    },
                    child: const Text('Adicionar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._jaPossuo.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildPierreCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('✔️ $item',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: GideonAssistenteApp.subtext),
                    onPressed: () => setState(() => _jaPossuo.removeAt(idx)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChatOverlayModal() {
    return Container(
      color: GideonAssistenteApp.darkBg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _isChatOverlayOpen = false),
                  ),
                  const Column(
                    children: [
                      Text('Gideon IA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white)),
                      Text('Visão Computacional & Finanças',
                          style: TextStyle(
                              fontSize: 10,
                              color: GideonAssistenteApp.subtext)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => setState(() => _chatMsgs.clear()),
                    child: const Text('Limpar',
                        style: TextStyle(
                            color: GideonAssistenteApp.subtext, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: ListView(
                controller: _scrollChatController,
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Center(
                            child: Icon(Icons.smart_toy,
                                color: GideonAssistenteApp.neonLime, size: 36),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Olá, Taylane',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const Text('Como posso te ajudar hoje?',
                            style: TextStyle(
                                fontSize: 12,
                                color: GideonAssistenteApp.subtext)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildChatPromptChip('Meu saldo é '),
                            _buildChatPromptChip('Gastei R\$ '),
                            ActionChip(
                              backgroundColor: GideonAssistenteApp.neonLime
                                  .withOpacity(0.1),
                              side: BorderSide(
                                  color: GideonAssistenteApp.neonLime
                                      .withOpacity(0.3)),
                              label: const Text('📷 Ler print de PIX',
                                  style: TextStyle(
                                      color: GideonAssistenteApp.neonLime,
                                      fontSize: 11)),
                              onPressed: _simularLeituraPrint,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ..._chatMsgs.map((msg) {
                    final isUser = msg['autor'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          color: isUser
                              ? GideonAssistenteApp.neonLime
                              : GideonAssistenteApp.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: isUser
                              ? null
                              : Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          msg['texto'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.white70),
                    onPressed: _simularLeituraPrint,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Envie uma mensagem...',
                        hintStyle: const TextStyle(
                            color: GideonAssistenteApp.subtext),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _processarMensagemUser,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _processarMensagemUser(_chatController.text),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: GideonAssistenteApp.neonLime,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.black, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPromptChip(String text) {
    return ActionChip(
      backgroundColor: Colors.white.withOpacity(0.05),
      side: BorderSide(color: Colors.white.withOpacity(0.1)),
      label: Text(text,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
      onPressed: () {
        _chatController.text = text;
      },
    );
  }

  void _abrirModalEditarSaldo() {
    _editSaldoController.text = _saldoEmContas.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GideonAssistenteApp.cardBg,
        title: const Text('Editar Saldo em Contas',
            style: TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: _editSaldoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: GideonAssistenteApp.neonLime,
                foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _saldoEmContas =
                    double.tryParse(_editSaldoController.text) ??
                        _saldoEmContas;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _abrirModalEditarGastado() {
    _editGastadoController.text = _gastosMesFinal.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GideonAssistenteApp.cardBg,
        title: const Text('Editar Gastos do Mês',
            style: TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: _editGastadoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: GideonAssistenteApp.neonLime,
                foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _gastosMesManual =
                    double.tryParse(_editGastadoController.text);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _abrirModalChaveApi() {
    _apiKeyController.text = _geminiApiKey;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GideonAssistenteApp.cardBg,
        title: const Text('Configurar Chave Gemini API',
            style: TextStyle(color: Colors.white, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Cole sua chave do Google AI Studio para ativar a IA completa:',
                style: TextStyle(
                    color: GideonAssistenteApp.subtext, fontSize: 11)),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'AIzaSy...'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: GideonAssistenteApp.neonLime,
                foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _geminiApiKey = _apiKeyController.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }

  void _abrirModalImportarOFX() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GideonAssistenteApp.cardBg,
        title: const Text('Importar Extrato Bancário (.OFX/.CSV)',
            style: TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: _ofxTextController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, fontSize: 11),
          decoration: const InputDecoration(
            hintText:
                'Cole o conteúdo do arquivo .OFX ou .CSV do seu banco...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.black),
            onPressed: () {
              final raw = _ofxTextController.text;
              if (raw.isNotEmpty) {
                setState(() {
                  _despesas.insert(0, {
                    'desc': 'Lançamento Bancário Importado',
                    'category': 'Extrato',
                    'amount': 45.00,
                    'date': 'Hoje',
                    'banco': 'Nubank',
                    'pago': true,
                  });
                });
                _ofxTextController.clear();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  void _simularLeituraPrint() {
    setState(() {
      _isChatOverlayOpen = true;
      _chatMsgs
          .add({'autor': 'user', 'texto': '📷 [Print do PIX de R\$ 35,00 em Padaria]'});
      _chatMsgs.add({
        'autor': 'bot',
        'texto':
            '📸 Leitura do print com Gemini: Detectado PIX de R\$ 35,00 em Padaria. Lançado com sucesso!'
      });
      _despesas.insert(0, {
        'desc': 'Padaria (Print PIX)',
        'category': 'Alimentação',
        'amount': 35.00,
        'date': 'Hoje',
        'banco': 'Nubank',
        'pago': true,
      });
      _saldoEmContas -= 35.00;
    });
    _scrollToBottomChat();
  }
}