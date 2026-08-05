import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GideonAssistenteApp());
}

class GideonAssistenteApp extends StatefulWidget {
  const GideonAssistenteApp({super.key});

  @override
  State<GideonAssistenteApp> createState() => _GideonAssistenteAppState();
}

class _GideonAssistenteAppState extends State<GideonAssistenteApp> {
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gideon • Assistente Virtual do Lar',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: HomeScreen(
        onToggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navegação Principal (0: Mudança, 1: Finanças, 2: Caixas & Inventário, 3: Contas, 4: Casal/Frete)
  int _currentTab = 0;

  // Estado da Mudança
  double _saldoMudanca = 2500.00;
  double _totalGastadoMudanca = 850.00;
  final double _progressoMudanca = 0.45; // 45% concluído

  // Estado de Finanças Pessoais
  double _saldoDisponivel = 3200.00; // ESQUERDA (Saldo Disponível)
  double _faturasGastos = 1450.00;   // DIREITA (Faturas & Dívidas / Gastos)

  // Listas de Contas Pessoais e Fixas
  final List<Map<String, dynamic>> _contasVencimento = [
    {'id': 1, 'nome': 'Aluguel do Mês', 'valor': 1200.0, 'vencimento': '10/08/2026', 'paga': false, 'categoria': 'Moradia'},
    {'id': 2, 'nome': 'Conta de Luz (ENEL)', 'valor': 185.50, 'vencimento': '15/08/2026', 'paga': false, 'categoria': 'Serviços'},
    {'id': 3, 'nome': 'Internet Fibra 500MB', 'valor': 119.90, 'vencimento': '05/08/2026', 'paga': true, 'categoria': 'Serviços'},
  ];

  // Listas de Caixas e Inventário
  final List<Map<String, dynamic>> _caixasMudanca = [
    {
      'codigo': 'CX-01',
      'comodo': 'Cozinha',
      'descricao': 'Pratos, Copos de Cristal e Taças',
      'fragil': true,
      'status': 'Embalado',
      'itens': ['6 Pratos Rasos', '6 Taças de Vinho', 'Jogo de Copos']
    },
    {
      'codigo': 'CX-02',
      'comodo': 'Quarto Casal',
      'descricao': 'Roupas de Cama e Edredom',
      'fragil': false,
      'status': 'Pronto para Transporte',
      'itens': ['2 Edredons', '4 Jogos de Lençol', 'Travesseiros']
    },
    {
      'codigo': 'CX-03',
      'comodo': 'Sala',
      'descricao': 'Eletrônicos e Modems',
      'fragil': true,
      'status': 'Aberto',
      'itens': ['Roteador Wi-Fi', 'Controles Remotos', 'Fios e Cabos']
    },
  ];

  final List<Map<String, dynamic>> _orcamentosFrete = [
    {'empresa': 'TransMudanças VIP', 'valor': 1200.0, 'ajudantes': 3, 'montagem': true, 'seguro': true, 'recomendado': true},
    {'empresa': 'Frete Rápido Express', 'valor': 750.0, 'ajudantes': 1, 'montagem': false, 'seguro': false, 'recomendado': false},
    {'empresa': 'Mudanças & Cia', 'valor': 950.0, 'ajudantes': 2, 'montagem': true, 'seguro': false, 'recomendado': false},
  ];

  final List<Map<String, dynamic>> _garantiasEletros = [
    {'item': 'Geladeira Frost Free 400L', 'loja': 'Magalu', 'garantia': '12 meses', 'vencimento': '10/12/2026', 'valor': 3200.0},
    {'item': 'Máquina de Lavar 11kg', 'loja': 'Casas Bahia', 'garantia': '24 meses', 'vencimento': '15/05/2027', 'valor': 2100.0},
    {'item': 'Smart TV 55" 4K', 'loja': 'Amazon', 'garantia': '12 meses', 'vencimento': '20/01/2027', 'valor': 2400.0},
  ];

  // Divisão de Casal / Roommates
  final double _rendaPessoa1 = 4500.0;
  final double _rendaPessoa2 = 2500.0;
  final double _totalContasCasa = 2800.0;

  // Controllers do Chat e Busca
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _buscaCaixaController = TextEditingController();
  final ScrollController _scrollChatController = ScrollController();
  String _filtroBuscaCaixa = '';

  // Histórico de Mensagens do Chat com a Gideon
  final List<Map<String, String>> _chatMsgs = [
    {'autor': 'bot', 'texto': 'Olá! Sou a Gideon 🌐. Como posso te ajudar na mudança ou na gestão financeira hoje?'},
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _buscaCaixaController.dispose();
    _scrollChatController.dispose();
    super.dispose();
  }

  void _processUserMessage(String input) {
    if (input.trim().isEmpty) return;
    final text = input.trim();
    final lower = text.toLowerCase();

    double valor = 0.0;
    final matchK = RegExp(r'(\d+([.,]\d+)?)\s*k').firstMatch(lower);
    if (matchK != null) {
      valor = (double.tryParse(matchK.group(1)!.replaceAll(',', '.')) ?? 0.0) * 1000.0;
    } else {
      final matchNum = RegExp(r'(\d+([.,]\d+)?)').firstMatch(lower);
      if (matchNum != null) {
        valor = double.tryParse(matchNum.group(1)!.replaceAll(',', '.')) ?? 0.0;
      }
    }

    setState(() {
      _chatMsgs.add({'autor': 'user', 'texto': text});
      _chatController.clear();

      if (lower.contains('recebi') || lower.contains('salário') || lower.contains('salario') || lower.contains('pix') || lower.contains('ganhei')) {
        if (valor > 0) _saldoDisponivel += valor;
        _chatMsgs.add({
          'autor': 'bot',
          'texto': '💰 Entrada de R\$ ${valor.toStringAsFixed(2)} adicionada ao seu Saldo Disponível!'
        });
      } else if (lower.contains('gastei') || lower.contains('comprei') || lower.contains('almoço') || lower.contains('ifood') || lower.contains('mercado') || lower.contains('paguei')) {
        if (valor > 0) {
          _faturasGastos += valor;     // Acumula no Card DIREITO (Faturas & Dívidas)
          _saldoDisponivel -= valor;  // Abate do Card ESQUERDO (Saldo Disponível)
        }
        _chatMsgs.add({
          'autor': 'bot',
          'texto': '💸 Lançado R\$ ${valor.toStringAsFixed(2)} em Faturas & Dívidas (Card Direito)! Saldo atualizado.'
        });
      } else if (lower.contains('mudança') || lower.contains('frete') || lower.contains('caixa')) {
        if (valor > 0) {
          _totalGastadoMudanca += valor;
          _saldoMudanca -= valor;
        }
        _chatMsgs.add({
          'autor': 'bot',
          'texto': '🚚 Lançamento de R\$ ${valor.toStringAsFixed(2)} associado ao orçamento da Mudança!'
        });
      } else {
        _chatMsgs.add({
          'autor': 'bot',
          'texto': '🌐 Entendido! Registrei sua mensagem na central de controle.'
        });
      }

      Timer(const Duration(milliseconds: 100), () {
        if (_scrollChatController.hasClients) {
          _scrollChatController.animateTo(
            _scrollChatController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _exportarRelatorio() {
    double margemReserva = _totalGastadoMudanca * 0.15;
    final String relatorio = '''
📊 *RELATÓRIO COMPLETO GIDEON*
---------------------------------------------------
🚚 *PLANEJAMENTO DE MUDANÇA:*
• Saldo Reservado: R\$ ${_saldoMudanca.toStringAsFixed(2)}
• Gastos Acumulados: R\$ ${_totalGastadoMudanca.toStringAsFixed(2)}
• Margem de Imprevistos (+15%): R\$ ${margemReserva.toStringAsFixed(2)}
• Progresso de Embalagem: ${(_progressoMudanca * 100).toStringAsFixed(0)}%

💰 *FINANÇAS PESSOAIS:*
• Saldo Disponível (Livre): R\$ ${_saldoDisponivel.toStringAsFixed(2)}
• Faturas & Dívidas (Gastos): R\$ ${_faturasGastos.toStringAsFixed(2)}

📦 *ORGANIZAÇÃO DE CAIXAS:*
• Total de Caixas Cadastradas: ${_caixasMudanca.length}
---------------------------------------------------
Gerado por Gideon • Assistente Virtual 🌐
''';

    Clipboard.setData(ClipboardData(text: relatorio));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Relatório copiado com sucesso! Prontinho para colar no WhatsApp.'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _darBaixaConta(int id) {
    setState(() {
      for (var c in _contasVencimento) {
        if ((c['id'] as num).toInt() == id) {
          bool estaPaga = c['paga'] == true;
          c['paga'] = !estaPaga;
          double valorConta = (c['valor'] as num).toDouble();
          if (c['paga'] == true) {
            _faturasGastos += valorConta;
            _saldoDisponivel -= valorConta;
          } else {
            _faturasGastos -= valorConta;
            _saldoDisponivel += valorConta;
          }
        }
      }
    });
  }

  Card _buildCustomCard({required Widget child, Color? color, bool isDark = true}) {
    return Card(
      elevation: 0,
      color: color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Principal
                _buildCustomCard(
                  isDark: isDark,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🌐 ', style: TextStyle(fontSize: 22)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gideon App',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Assistente Virtual do Lar & Finanças',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share_outlined),
                              tooltip: 'Exportar Relatório',
                              onPressed: _exportarRelatorio,
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: widget.onToggleTheme,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isDark ? '☀️ Tema' : '🌙 Tema',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNavButton(0, '🚚 Mudança', isDark),
                      const SizedBox(width: 8),
                      _buildNavButton(1, '💰 Finanças', isDark),
                      const SizedBox(width: 8),
                      _buildNavButton(2, '📦 Caixas & QR', isDark),
                      const SizedBox(width: 8),
                      _buildNavButton(3, '📅 Contas', isDark),
                      const SizedBox(width: 8),
                      _buildNavButton(4, '🤝 Casal & Frete', isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Renderiza a aba ativa
                if (_currentTab == 0) _buildTabMudanca(isDark),
                if (_currentTab == 1) _buildTabFinancas(isDark),
                if (_currentTab == 2) _buildTabCaixas(isDark),
                if (_currentTab == 3) _buildTabContas(isDark),
                if (_currentTab == 4) _buildTabCasalEFrete(isDark),

                const SizedBox(height: 16),

                // Chat da Gideon Inteligente (Fixo na parte inferior)
                _buildChatGideon(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, String label, bool isDark) {
    final isSelected = _currentTab == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isSelected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF1E293B) : Colors.white),
        foregroundColor: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isSelected ? 2 : 0,
      ),
      onPressed: () => setState(() => _currentTab = index),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildTabMudanca(bool isDark) {
    double fundoReserva = _totalGastadoMudanca * 0.15;

    return Column(
      children: [
        _buildCustomCard(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('📦 Progresso Geral da Mudança', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${(_progressoMudanca * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: _progressoMudanca,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    color: const Color(0xFF2563EB),
                    minHeight: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildCustomCard(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Saldo Reservado', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${_saldoMudanca.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCustomCard(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Total Gastado', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${_totalGastadoMudanca.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildCustomCard(
          isDark: isDark,
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    'Fundo de Imprevistos Recomendado (+15%): R\$ ${fundoReserva.toStringAsFixed(2)} para custos ocultos.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabFinancas(bool isDark) {
    return _buildCustomCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('💳 ', style: TextStyle(fontSize: 18)),
                Text('Balanço Geral das Finanças', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Text('Saldo Disponível (Livre)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(
                          'R\$ ${_saldoDisponivel.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _saldoDisponivel >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Text('Faturas & Dívidas (Gastos)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(
                          'R\$ ${_faturasGastos.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCaixas(bool isDark) {
    final caixasFiltradas = _caixasMudanca.where((c) {
      if (_filtroBuscaCaixa.isEmpty) return true;
      final q = _filtroBuscaCaixa.toLowerCase();
      final List itemsList = (c['itens'] as List);
      final itemsStr = itemsList.map((e) => e.toString()).join(' ').toLowerCase();
      return c['codigo'].toString().toLowerCase().contains(q) ||
          c['comodo'].toString().toLowerCase().contains(q) ||
          c['descricao'].toString().toLowerCase().contains(q) ||
          itemsStr.contains(q);
    }).toList();

    return Column(
      children: [
        TextField(
          controller: _buscaCaixaController,
          decoration: InputDecoration(
            hintText: '🔍 Buscar por item (ex: taças, edredom, cabo)...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (val) => setState(() => _filtroBuscaCaixa = val),
        ),
        const SizedBox(height: 12),

        ...caixasFiltradas.map((cx) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildCustomCard(
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2, size: 28, color: Color(0xFF2563EB)),
                        Text(cx['codigo'].toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(cx['comodo'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            if (cx['fragil'] == true) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                                child: const Text('⚠️ FRÁGIL', style: TextStyle(color: Color(0xFFDC2626), fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(cx['descricao'].toString(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Itens: ${(cx['itens'] as List).map((e) => e.toString()).join(', ')}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTabContas(bool isDark) {
    return Column(
      children: [
        _buildCustomCard(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📅 Contas & Vencimentos do Mês', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ..._contasVencimento.map((c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: c['paga'] == true ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                    child: Icon(
                      c['paga'] == true ? Icons.check : Icons.priority_high,
                      color: c['paga'] == true ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                  title: Text(c['nome'].toString(), style: TextStyle(decoration: c['paga'] == true ? TextDecoration.lineThrough : null)),
                  subtitle: Text('Vence: ${c['vencimento']} | Categoria: ${c['categoria']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'R\$ ${(c['valor'] as num).toDouble().toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(c['paga'] == true ? Icons.undo : Icons.check_circle_outline),
                        color: c['paga'] == true ? Colors.grey : const Color(0xFF10B981),
                        tooltip: c['paga'] == true ? 'Desfazer' : 'Dar Baixa (Paga)',
                        onPressed: () => _darBaixaConta((c['id'] as num).toInt()),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabCasalEFrete(bool isDark) {
    double totalRenda = _rendaPessoa1 + _rendaPessoa2;
    double percP1 = totalRenda > 0 ? (_rendaPessoa1 / totalRenda) : 0.5;
    double percP2 = totalRenda > 0 ? (_rendaPessoa2 / totalRenda) : 0.5;

    return Column(
      children: [
        _buildCustomCard(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🤝 ', style: TextStyle(fontSize: 18)),
                    Text('Divisão Proporcional de Contas (Casal)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Contas Totais da Casa: R\$ ${_totalContasCasa.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                const Divider(),
                ListTile(
                  title: const Text('Pessoa 1 (R\$ 4.500)'),
                  subtitle: Text('${(percP1 * 100).toStringAsFixed(0)}% da renda familiar'),
                  trailing: Text('Paga R\$ ${(_totalContasCasa * percP1).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                ),
                ListTile(
                  title: const Text('Pessoa 2 (R\$ 2.500)'),
                  subtitle: Text('${(percP2 * 100).toStringAsFixed(0)}% da renda familiar'),
                  trailing: Text('Paga R\$ ${(_totalContasCasa * percP2).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildCustomCard(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🚚 ', style: TextStyle(fontSize: 18)),
                    Text('Comparador de Orçamentos de Frete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                ..._orcamentosFrete.map((f) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${f['empresa']} - R\$ ${(f['valor'] as num).toDouble().toStringAsFixed(2)}'),
                  subtitle: Text('Ajudantes: ${f['ajudantes']} | Montagem: ${f['montagem'] == true ? "Sim" : "Não"}'),
                  trailing: f['recomendado'] == true
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(12)),
                          child: const Text('Melhor Opção', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      : null,
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildCustomCard(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🏷️ ', style: TextStyle(fontSize: 18)),
                    Text('Controle de Garantias de Eletros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                ..._garantiasEletros.map((g) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(g['item'].toString()),
                  subtitle: Text('Loja: ${g['loja']} | Prazo: ${g['garantia']}'),
                  trailing: Text('Vence: ${g['vencimento']}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatGideon(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🤖 ', style: TextStyle(fontSize: 18)),
                Text(
                  'Fale com a Gideon (Assistente IA)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: ListView.builder(
                controller: _scrollChatController,
                itemCount: _chatMsgs.length,
                itemBuilder: (context, index) {
                  final msg = _chatMsgs[index];
                  final isUser = msg['autor'] == 'user';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 340),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF2563EB)
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isUser ? 12.0 : 2.0),
                          bottomRight: Radius.circular(isUser ? 2.0 : 12.0),
                        ),
                        border: isUser
                            ? null
                            : Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        msg['texto'] ?? '',
                        style: TextStyle(
                          color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickPill('💵 Recebi 1500 do PIX', () => _processUserMessage('Recebi 1500 do PIX'), isDark),
                  const SizedBox(width: 8),
                  _buildQuickPill('🍔 Gastei 25 no almoço', () => _processUserMessage('Gastei 25 no almoço'), isDark),
                  const SizedBox(width: 8),
                  _buildQuickPill('🚚 Paguei 400 no frete', () => _processUserMessage('Paguei 400 no frete'), isDark),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Recebi 2000 ou gastei 50 no mercado...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: _processUserMessage,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _processUserMessage(_chatController.text),
                  child: const Text('Enviar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}