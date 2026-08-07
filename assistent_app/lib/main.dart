import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GideonApp());
}

class GideonApp extends StatelessWidget {
  const GideonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gideon Financial Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0F12),
        primaryColor: const Color(0xFFCCFF00),
        cardColor: const Color(0xFF151821),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFCCFF00),
          secondary: Color(0xFF00FF88),
          surface: Color(0xFF151821),
          error: Color(0xFFFF4444),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0D0F12),
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF232734)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF232734)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFCCFF00)),
          ),
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class TransactionItem {
  final String id;
  final String title;
  final double value;
  final String category;
  final String date;

  TransactionItem({
    required this.id,
    required this.title,
    required this.value,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'value': value,
        'category': category,
        'date': date,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        value: (json['value'] is num) ? (json['value'] as num).toDouble() : 0.0,
        category: json['category']?.toString() ?? 'Geral',
        date: json['date']?.toString() ?? '',
      );
}

class GroceryItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  GroceryItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
        quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
      );
}

class BillItem {
  final String id;
  final String title;
  final double amount;
  final String dueDate;
  final bool isPaid;

  BillItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'dueDate': dueDate,
        'isPaid': isPaid,
      };

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
        dueDate: json['dueDate']?.toString() ?? '',
        isPaid: json['isPaid'] == true,
      );
}

class OwnedItem {
  final String id;
  final String name;
  final String category;

  OwnedItem({
    required this.id,
    required this.name,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
      };

  factory OwnedItem.fromJson(Map<String, dynamic> json) => OwnedItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? 'Outros',
      );
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedTabIndex = 0;

  // Estado zerado por padrão
  double saldo = 0.0;
  double gastos = 0.0;
  double fatura = 0.0;

  List<TransactionItem> transacoes = [];
  List<GroceryItem> compras = [];
  List<BillItem> contas = [];
  List<OwnedItem> possuo = [];

  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _groceryNameCtrl = TextEditingController();
  final TextEditingController _groceryPriceCtrl = TextEditingController();
  final TextEditingController _billTitleCtrl = TextEditingController();
  final TextEditingController _billAmountCtrl = TextEditingController();
  final TextEditingController _ownedNameCtrl = TextEditingController();

  final List<Map<String, String>> messages = [
    {
      'sender': 'bot',
      'text': 'Olá! Sou a Gideon. Todos os valores foram zerados. Como posso te ajudar hoje?'
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _groceryNameCtrl.dispose();
    _groceryPriceCtrl.dispose();
    _billTitleCtrl.dispose();
    _billAmountCtrl.dispose();
    _ownedNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        saldo = prefs.getDouble('saldo') ?? 0.0;
        gastos = prefs.getDouble('gastos') ?? 0.0;
        fatura = prefs.getDouble('fatura') ?? 0.0;

        String? txStr = prefs.getString('transacoes');
        if (txStr != null) {
          List<dynamic> l = jsonDecode(txStr);
          transacoes = l
              .map((e) => TransactionItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }

        String? compStr = prefs.getString('compras');
        if (compStr != null) {
          List<dynamic> l = jsonDecode(compStr);
          compras = l
              .map((e) => GroceryItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }

        String? cntStr = prefs.getString('contas');
        if (cntStr != null) {
          List<dynamic> l = jsonDecode(cntStr);
          contas = l
              .map((e) => BillItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }

        String? posStr = prefs.getString('possuo');
        if (posStr != null) {
          List<dynamic> l = jsonDecode(posStr);
          possuo = l
              .map((e) => OwnedItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      });
    } catch (_) {}
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('saldo', saldo);
      await prefs.setDouble('gastos', gastos);
      await prefs.setDouble('fatura', fatura);
      await prefs.setString('transacoes', jsonEncode(transacoes.map((e) => e.toJson()).toList()));
      await prefs.setString('compras', jsonEncode(compras.map((e) => e.toJson()).toList()));
      await prefs.setString('contas', jsonEncode(contas.map((e) => e.toJson()).toList()));
      await prefs.setString('possuo', jsonEncode(possuo.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151821),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Zerar Todos os Dados?'),
        content: const Text('Esta ação apagará todas as transações, listas de compras, contas a vencer e inventário.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                saldo = 0.0;
                gastos = 0.0;
                fatura = 0.0;
                transacoes.clear();
                compras.clear();
                contas.clear();
                possuo.clear();
              });
              _saveData();
              Navigator.pop(ctx);
            },
            child: const Text('Zerar Tudo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'text': text});
      _chatController.clear();
    });

    _processLocalAI(text);
  }

  void _processLocalAI(String input) {
    String lower = input.toLowerCase();
    RegExp numRegex = RegExp(r'\d+([.,]\d+)?');
    var match = numRegex.firstMatch(input);
    double val = match != null ? double.parse(match.group(0)!.replaceAll(',', '.')) : 0.0;

    String reply = "";

    if (lower.contains('gastei') || lower.contains('paguei') || lower.contains('comprei')) {
      setState(() {
        gastos += val;
        saldo -= val;
        transacoes.insert(
          0,
          TransactionItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: input,
            value: -val,
            category: _detectCategory(lower),
            date: 'Hoje',
          ),
        );
      });
      reply = "Entendido! Lancei a despesa de R\$ ${val.toStringAsFixed(2)}. Seu saldo atual é de R\$ ${saldo.toStringAsFixed(2)}.";
    } else if (lower.contains('saldo') || lower.contains('tenho') || lower.contains('recebi')) {
      if (val > 0) {
        setState(() {
          saldo = val;
        });
        reply = "Saldo ajustado para R\$ ${saldo.toStringAsFixed(2)}.";
      } else {
        reply = "Seu saldo atual disponível em conta é de R\$ ${saldo.toStringAsFixed(2)}.";
      }
    } else if (lower.contains('quanto gastei') || lower.contains('resumo') || lower.contains('relatorio')) {
      reply = "📊 Resumo Financeiro:\n• Saldo em conta: R\$ ${saldo.toStringAsFixed(2)}\n• Gastos do Mês: R\$ ${gastos.toStringAsFixed(2)}\n• Fatura Atual: R\$ ${fatura.toStringAsFixed(2)}";
    } else if (lower.contains('dica') || lower.contains('conselho')) {
      reply = saldo <= 0
          ? "💡 Dica: Seu saldo está zerado. Evite novos compromissos financeiros até registrar novas entradas."
          : "💡 Dica: Recomendo separar 15% do seu saldo (R\$ ${(saldo * 0.15).toStringAsFixed(2)}) para o seu fundo de imprevistos.";
    } else {
      reply = "Entendido! Você pode me pedir para lançar compras, ajustar saldo ou ver seu resumo financeiro a qualquer momento.";
    }

    _saveData();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        messages.add({'sender': 'bot', 'text': reply});
      });
    });
  }

  String _detectCategory(String text) {
    if (text.contains('mercado') || text.contains('padaria') || text.contains('comida')) return 'Alimentação';
    if (text.contains('luz') || text.contains('agua') || text.contains('net')) return 'Contas Fixas';
    if (text.contains('uber') || text.contains('gasolina')) return 'Transporte';
    return 'Geral';
  }

  void _showCardDetails(String title, String description, Widget? detailWidget) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151821),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            if (detailWidget != null) detailWidget,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F12),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFF00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Gideon App', style: TextStyle(color: Color(0xFFCCFF00), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: 'Zerar Tudo',
            onPressed: _resetAll,
          )
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabChip(0, 'Início', Icons.home),
                _buildTabChip(1, 'Atividades', Icons.list_alt),
                _buildTabChip(2, 'Compras Supermercado', Icons.shopping_cart),
                _buildTabChip(3, 'Contas', Icons.calendar_today),
                _buildTabChip(4, 'Já Possuo', Icons.inventory_2),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildInicioTab(),
                _buildAtividadesTab(),
                _buildComprasTab(),
                _buildContasTab(),
                _buildPossuoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    bool selected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Row(
          children: [
            Icon(icon, size: 16, color: selected ? Colors.black : Colors.white70),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: selected,
        selectedColor: const Color(0xFFCCFF00),
        backgroundColor: const Color(0xFF151821),
        labelStyle: TextStyle(
          color: selected ? Colors.black : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildInicioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (saldo <= 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x80FF5252)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Saldo Zerado ou Negativo! Registre novas entradas no chat.',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: _buildClickableCard(
                  title: 'Saldo em contas',
                  value: 'R\$ ${saldo.toStringAsFixed(2)}',
                  subtitle: 'Clique para detalhes',
                  icon: Icons.account_balance_wallet,
                  onTap: () => _showCardDetails(
                    'Saldo em Contas',
                    'Detalhamento das entradas e saldos consolidados.',
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Saldo Principal Disponível'),
                      trailing: Text('R\$ ${saldo.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClickableCard(
                  title: 'Gastos do mês',
                  value: 'R\$ ${gastos.toStringAsFixed(2)}',
                  subtitle: '${transacoes.length} despesas lançadas',
                  icon: Icons.trending_down,
                  onTap: () => _showCardDetails(
                    'Gastos do Mês',
                    'Acompanhamento de todas as despesas acumuladas no mês.',
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCCFF00), foregroundColor: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _selectedTabIndex = 1);
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Ver Extrato Completo'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildClickableCard(
                  title: 'Fatura Atual',
                  value: 'R\$ ${fatura.toStringAsFixed(2)}',
                  subtitle: 'Clique para ver compras',
                  icon: Icons.credit_card,
                  onTap: () => _showCardDetails(
                    'Fatura do Cartão',
                    'Acompanhamento do cartão de crédito cadastrado.',
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cartão Principal (•••• 9694)'),
                      subtitle: const Text('Vence em breve'),
                      trailing: Text('R\$ ${fatura.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClickableCard(
                  title: 'Fluxo de caixa',
                  value: '+R\$ ${saldo.toStringAsFixed(2)}\n-R\$ ${gastos.toStringAsFixed(2)}',
                  subtitle: 'Balanço mensal',
                  icon: Icons.swap_vert,
                  onTap: () => _showCardDetails(
                    'Fluxo de Caixa',
                    'Balanço comparativo entre entradas acumuladas (+) e saídas (-).',
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Total de Entradas'),
                          trailing: Text('+R\$ ${saldo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Total de Saídas'),
                          trailing: Text('-R\$ ${gastos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFF151821),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF232734)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF232734))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt, color: Colors.black, size: 14),
                      ),
                      const SizedBox(width: 8),
                      const Text('Chat Gideon (Inteligência Local)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (ctx, i) {
                      bool isUser = messages[i]['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFFCCFF00) : const Color(0xFF232734),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            messages[i]['text'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.black : Colors.white,
                              fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Pergunte à Gideon ou lance valores...',
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFCCFF00),
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.arrow_upward, color: Colors.black),
                        onPressed: _sendMessage,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildClickableCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151821),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF232734)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, size: 16, color: const Color(0xFFCCFF00)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFFCCFF00))),
          ],
        ),
      ),
    );
  }

  Widget _buildAtividadesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Histórico de Transações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (transacoes.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      transacoes.clear();
                      gastos = 0.0;
                    });
                    _saveData();
                  },
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                  label: const Text('Limpar Transações', style: TextStyle(color: Colors.redAccent)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: transacoes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhuma transação lançada ainda.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transacoes.length,
                    itemBuilder: (ctx, i) {
                      var item = transacoes[i];
                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.category} • ${item.date}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R\$ ${item.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: item.value < 0 ? Colors.redAccent : Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                onPressed: () {
                                  setState(() {
                                    transacoes.removeAt(i);
                                  });
                                  _saveData();
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildComprasTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _groceryNameCtrl,
                  decoration: const InputDecoration(hintText: 'Item supermercado...'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _groceryPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'R\$'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  if (_groceryNameCtrl.text.isNotEmpty) {
                    double val = double.tryParse(_groceryPriceCtrl.text) ?? 0.0;
                    setState(() {
                      compras.add(GroceryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _groceryNameCtrl.text,
                        price: val,
                      ));
                    });
                    _saveData();
                    _groceryNameCtrl.clear();
                    _groceryPriceCtrl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: compras.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Sua lista de compras está vazia.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: compras.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(compras[i].name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('R\$ ${compras[i].price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  setState(() {
                                    compras.removeAt(i);
                                  });
                                  _saveData();
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildContasTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _billTitleCtrl,
                  decoration: const InputDecoration(hintText: 'Nome da conta (Ex: Luz)...'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _billAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'R\$'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  if (_billTitleCtrl.text.isNotEmpty) {
                    double val = double.tryParse(_billAmountCtrl.text) ?? 0.0;
                    setState(() {
                      contas.add(BillItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _billTitleCtrl.text,
                        amount: val,
                        dueDate: 'Em breve',
                      ));
                    });
                    _saveData();
                    _billTitleCtrl.clear();
                    _billAmountCtrl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: contas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhuma conta agendada a vencer.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: contas.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(contas[i].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Vence em: ${contas[i].dueDate}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('R\$ ${contas[i].amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  setState(() {
                                    contas.removeAt(i);
                                  });
                                  _saveData();
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildPossuoTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ownedNameCtrl,
                  decoration: const InputDecoration(hintText: 'Item ou móvel cadastrado...'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  if (_ownedNameCtrl.text.isNotEmpty) {
                    setState(() {
                      possuo.add(OwnedItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _ownedNameCtrl.text,
                        category: 'Geral',
                      ));
                    });
                    _saveData();
                    _ownedNameCtrl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: possuo.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhum item ou imóvel cadastrado no inventário.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: possuo.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(possuo[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(possuo[i].category),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setState(() {
                                possuo.removeAt(i);
                              });
                              _saveData();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}