import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GideonApp());
}

/// ============================================================================
/// CONFIGURAÇÃO DE TEMA E ESTRUTURA GLOBAL DO APLICATIVO GIDEON
/// ============================================================================
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
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
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

/// ============================================================================
/// MODELOS DE DADOS
/// ============================================================================
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
  final bool isBought;

  GroceryItem({
    required this.id,
    required this.name,
    required this.price,
    this.isBought = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'isBought': isBought,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
        isBought: json['isBought'] == true,
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
        category: json['category']?.toString() ?? 'Geral',
      );
}

class MoveTaskItem {
  final String id;
  final String title;
  final String timeframe; // '30_days', '15_days', '2_days', 'day_of_move'
  final bool isDone;

  MoveTaskItem({
    required this.id,
    required this.title,
    required this.timeframe,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timeframe': timeframe,
        'isDone': isDone,
      };

  factory MoveTaskItem.fromJson(Map<String, dynamic> json) => MoveTaskItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        timeframe: json['timeframe']?.toString() ?? '30_days',
        isDone: json['isDone'] == true,
      );
}

class GoalItem {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;

  GoalItem({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
      };

  factory GoalItem.fromJson(Map<String, dynamic> json) => GoalItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        targetAmount: (json['targetAmount'] is num) ? (json['targetAmount'] as num).toDouble() : 0.0,
        currentAmount: (json['currentAmount'] is num) ? (json['currentAmount'] as num).toDouble() : 0.0,
      );
}

class InstallmentItem {
  final String id;
  final String title;
  final double totalAmount;
  final int totalInstallments;
  int paidInstallments;

  InstallmentItem({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.totalInstallments,
    this.paidInstallments = 0,
  });

  double get monthlyValue => totalInstallments > 0 ? totalAmount / totalInstallments : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalAmount': totalAmount,
        'totalInstallments': totalInstallments,
        'paidInstallments': paidInstallments,
      };

  factory InstallmentItem.fromJson(Map<String, dynamic> json) => InstallmentItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : 0.0,
        totalInstallments: (json['totalInstallments'] is num) ? (json['totalInstallments'] as num).toInt() : 1,
        paidInstallments: (json['paidInstallments'] is num) ? (json['paidInstallments'] as num).toInt() : 0,
      );
}

/// ============================================================================
/// TELA PRINCIPAL (MAIN HOME SCREEN)
/// ============================================================================
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedTabIndex = 0;

  // ESTADO FINANCEIRO
  double saldo = 0.0;
  double gastos = 0.0;
  double fatura = 0.0;
  double gastosMudanca = 0.0;

  // CUSTOS ESTIMADOS DO SIMULADOR DA CASA NOVA
  double simAluguel = 0.0;
  double simLuzAgua = 0.0;
  double simInternet = 0.0;
  double simTransporte = 0.0;
  double simIptu = 0.0;

  List<TransactionItem> transacoes = [];
  List<GroceryItem> compras = [];
  List<BillItem> contas = [];
  List<OwnedItem> possuo = [];
  List<MoveTaskItem> tarefasMudanca = [];
  List<GoalItem> metas = [];
  List<InstallmentItem> parcelamentos = [];

  // CONTROLLERS
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _groceryNameCtrl = TextEditingController();
  final TextEditingController _groceryPriceCtrl = TextEditingController();
  final TextEditingController _billTitleCtrl = TextEditingController();
  final TextEditingController _billAmountCtrl = TextEditingController();
  final TextEditingController _billDateCtrl = TextEditingController();
  final TextEditingController _ownedNameCtrl = TextEditingController();
  final TextEditingController _moveTaskCtrl = TextEditingController();
  final TextEditingController _moveExpenseTitleCtrl = TextEditingController();
  final TextEditingController _moveExpenseValCtrl = TextEditingController();

  // CONTROLLERS METAS E PARCELAS
  final TextEditingController _goalTitleCtrl = TextEditingController();
  final TextEditingController _goalTargetCtrl = TextEditingController();
  final TextEditingController _instTitleCtrl = TextEditingController();
  final TextEditingController _instTotalValCtrl = TextEditingController();
  final TextEditingController _instCountCtrl = TextEditingController();

  // SIMULADOR CONTROLLERS
  final TextEditingController _simAluguelCtrl = TextEditingController();
  final TextEditingController _simLuzAguaCtrl = TextEditingController();
  final TextEditingController _simInternetCtrl = TextEditingController();
  final TextEditingController _simTransporteCtrl = TextEditingController();
  final TextEditingController _simIptuCtrl = TextEditingController();

  // CALCULADORA EMBUTIDA
  String _calcDisplay = '0';
  double _calcFirstNum = 0.0;
  String _calcOperator = '';
  bool _calcResetNext = false;

  String _selectedTimeframeAdd = '30_days';

  final List<Map<String, String>> messages = [
    {
      'sender': 'bot',
      'text': 'Olá! Sou a Gideon. Converse comigo para registrar gastos, ganhos, contas, metas ou parcelamentos!'
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialDefaultTasks();
    _loadData();
  }

  void _loadInitialDefaultTasks() {
    tarefasMudanca = [
      MoveTaskItem(id: '1', title: 'Dar aviso prévio no imóvel atual', timeframe: '30_days'),
      MoveTaskItem(id: '2', title: 'Pesquisar e orçar transportadoras / carretos', timeframe: '30_days'),
      MoveTaskItem(id: '3', title: 'Descarte e doação de itens sem uso', timeframe: '30_days'),
      MoveTaskItem(id: '4', title: 'Agendar transferência de Internet/Luz/Água', timeframe: '15_days'),
      MoveTaskItem(id: '5', title: 'Comprar fitas adesivas, plásticos bolha e etiquetas', timeframe: '15_days'),
      MoveTaskItem(id: '6', title: 'Montar Mala/Caixa de Primeira Noite (roupas, toalhas, higiene)', timeframe: '2_days'),
      MoveTaskItem(id: '7', title: 'Confirmar horário do caminhão e regras do condomínio', timeframe: '2_days'),
      MoveTaskItem(id: '8', title: 'Tirar foto dos relógios de luz e água (antigo e novo)', timeframe: 'day_of_move'),
      MoveTaskItem(id: '9', title: 'Fazer vistoria final e entregar chaves', timeframe: 'day_of_move'),
    ];
  }

  @override
  void dispose() {
    _chatController.dispose();
    _groceryNameCtrl.dispose();
    _groceryPriceCtrl.dispose();
    _billTitleCtrl.dispose();
    _billAmountCtrl.dispose();
    _billDateCtrl.dispose();
    _ownedNameCtrl.dispose();
    _moveTaskCtrl.dispose();
    _moveExpenseTitleCtrl.dispose();
    _moveExpenseValCtrl.dispose();

    _goalTitleCtrl.dispose();
    _goalTargetCtrl.dispose();
    _instTitleCtrl.dispose();
    _instTotalValCtrl.dispose();
    _instCountCtrl.dispose();

    _simAluguelCtrl.dispose();
    _simLuzAguaCtrl.dispose();
    _simInternetCtrl.dispose();
    _simTransporteCtrl.dispose();
    _simIptuCtrl.dispose();
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
        gastosMudanca = prefs.getDouble('gastosMudanca') ?? 0.0;

        simAluguel = prefs.getDouble('simAluguel') ?? 0.0;
        simLuzAgua = prefs.getDouble('simLuzAgua') ?? 0.0;
        simInternet = prefs.getDouble('simInternet') ?? 0.0;
        simTransporte = prefs.getDouble('simTransporte') ?? 0.0;
        simIptu = prefs.getDouble('simIptu') ?? 0.0;

        if (simAluguel > 0) _simAluguelCtrl.text = simAluguel.toStringAsFixed(2);
        if (simLuzAgua > 0) _simLuzAguaCtrl.text = simLuzAgua.toStringAsFixed(2);
        if (simInternet > 0) _simInternetCtrl.text = simInternet.toStringAsFixed(2);
        if (simTransporte > 0) _simTransporteCtrl.text = simTransporte.toStringAsFixed(2);
        if (simIptu > 0) _simIptuCtrl.text = simIptu.toStringAsFixed(2);

        String? txStr = prefs.getString('transacoes');
        if (txStr != null) {
          List<dynamic> l = jsonDecode(txStr);
          transacoes = l.map((e) => TransactionItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }

        String? compStr = prefs.getString('compras');
        if (compStr != null) {
          List<dynamic> l = jsonDecode(compStr);
          compras = l.map((e) => GroceryItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }

        String? cntStr = prefs.getString('contas');
        if (cntStr != null) {
          List<dynamic> l = jsonDecode(cntStr);
          contas = l.map((e) => BillItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }

        String? posStr = prefs.getString('possuo');
        if (posStr != null) {
          List<dynamic> l = jsonDecode(posStr);
          possuo = l.map((e) => OwnedItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }

        String? mvdStr = prefs.getString('tarefasMudanca');
        if (mvdStr != null) {
          List<dynamic> l = jsonDecode(mvdStr);
          tarefasMudanca = l.map((e) => MoveTaskItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }

        String? metaStr = prefs.getString('metas');
        if (metaStr != null) {
          List<dynamic> l = jsonDecode(metaStr);
          metas = l.map((e) => GoalItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }

        String? parStr = prefs.getString('parcelamentos');
        if (parStr != null) {
          List<dynamic> l = jsonDecode(parStr);
          parcelamentos = l.map((e) => InstallmentItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
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
      await prefs.setDouble('gastosMudanca', gastosMudanca);

      await prefs.setDouble('simAluguel', simAluguel);
      await prefs.setDouble('simLuzAgua', simLuzAgua);
      await prefs.setDouble('simInternet', simInternet);
      await prefs.setDouble('simTransporte', simTransporte);
      await prefs.setDouble('simIptu', simIptu);

      await prefs.setString('transacoes', jsonEncode(transacoes.map((e) => e.toJson()).toList()));
      await prefs.setString('compras', jsonEncode(compras.map((e) => e.toJson()).toList()));
      await prefs.setString('contas', jsonEncode(contas.map((e) => e.toJson()).toList()));
      await prefs.setString('possuo', jsonEncode(possuo.map((e) => e.toJson()).toList()));
      await prefs.setString('tarefasMudanca', jsonEncode(tarefasMudanca.map((e) => e.toJson()).toList()));
      await prefs.setString('metas', jsonEncode(metas.map((e) => e.toJson()).toList()));
      await prefs.setString('parcelamentos', jsonEncode(parcelamentos.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151821),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Zerar Todos os Dados?'),
        content: const Text('Esta ação apagará transações, metas, parcelas, contas, compras e tarefas.'),
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
                gastosMudanca = 0.0;
                simAluguel = 0.0;
                simLuzAgua = 0.0;
                simInternet = 0.0;
                simTransporte = 0.0;
                simIptu = 0.0;
                _simAluguelCtrl.clear();
                _simLuzAguaCtrl.clear();
                _simInternetCtrl.clear();
                _simTransporteCtrl.clear();
                _simIptuCtrl.clear();
                transacoes.clear();
                compras.clear();
                contas.clear();
                possuo.clear();
                metas.clear();
                parcelamentos.clear();
                _loadInitialDefaultTasks();
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

  /// ============================================================================
  /// MOTOR LOCAL DE INTELIGÊNCIA FINANCEIRA (NLP)
  /// ============================================================================
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

    double val = 0.0;
    RegExp matchK = RegExp(r'(\d+([.,]\d+)?)\s*k', caseSensitive: false);
    var matchKResult = matchK.firstMatch(lower);
    if (matchKResult != null) {
      val = (double.tryParse(matchKResult.group(1)!.replaceAll(',', '.')) ?? 0.0) * 1000;
    } else {
      RegExp numRegex = RegExp(r'(\d+([.,]\d+)?)');
      var match = numRegex.firstMatch(lower.replaceAll('r\$', '').replaceAll('reais', ''));
      if (match != null) {
        val = double.tryParse(match.group(0)!.replaceAll(',', '.')) ?? 0.0;
      }
    }

    DateTime now = DateTime.now();
    String dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}";

    String category = _detectCategory(lower);
    String description = _extractDescription(input, val);

    String reply = "";

    bool isGain = lower.contains('recebi') ||
        lower.contains('ganhei') ||
        lower.contains('salario') ||
        lower.contains('salário') ||
        lower.contains('pix') ||
        lower.contains('deposito') ||
        lower.contains('freela');

    bool isExpense = lower.contains('gastei') ||
        lower.contains('paguei') ||
        lower.contains('comprei') ||
        lower.contains('pago') ||
        lower.contains('custou');

    if (isGain && val > 0) {
      category = 'Renda';
      setState(() {
        saldo += val;
        transacoes.insert(
          0,
          TransactionItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: description.isEmpty ? 'Entrada Registrada' : description,
            value: val,
            category: category,
            date: dateStr,
          ),
        );
      });
      reply = "💰 Ganho de R\$ ${val.toStringAsFixed(2)} ($description) gravado no dia $dateStr! Saldo livre atual: R\$ ${saldo.toStringAsFixed(2)}.";
    } else if (isExpense && val > 0) {
      setState(() {
        gastos += val;
        saldo -= val;
        transacoes.insert(
          0,
          TransactionItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: description.isEmpty ? 'Despesa Registrada' : description,
            value: -val,
            category: category,
            date: dateStr,
          ),
        );
      });
      reply = "💸 Gasto de R\$ ${val.toStringAsFixed(2)} ($category • $description) registrado em $dateStr! Saldo atualizado: R\$ ${saldo.toStringAsFixed(2)}.";
    } else if (lower.contains('saldo')) {
      if (val > 0 && !isExpense && !isGain) {
        setState(() {
          saldo = val;
        });
        reply = "✅ Saldo manualmente ajustado para R\$ ${saldo.toStringAsFixed(2)}.";
      } else {
        reply = "📊 Seu saldo livre em conta é de R\$ ${saldo.toStringAsFixed(2)}.";
      }
    } else if (lower.contains('resumo') || lower.contains('quanto gastei')) {
      reply = "📊 Resumo Geral ($dateStr):\n• Saldo livre: R\$ ${saldo.toStringAsFixed(2)}\n• Gastos do Mês: R\$ ${gastos.toStringAsFixed(2)}\n• Fatura Atual: R\$ ${fatura.toStringAsFixed(2)}";
    } else {
      reply = "Entendido! Você pode me dizer 'Comprei pizza por 50' para saídas ou 'Recebi 1200 de salário' para entradas.";
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
    if (text.contains('pizza') || text.contains('lanche') || text.contains('mercado') || text.contains('padaria') || text.contains('comida') || text.contains('almoço')) return 'Alimentação';
    if (text.contains('luz') || text.contains('agua') || text.contains('água') || text.contains('net') || text.contains('aluguel')) return 'Moradia';
    if (text.contains('uber') || text.contains('gasolina') || text.contains('bus') || text.contains('passagem')) return 'Transporte';
    if (text.contains('farmacia') || text.contains('remedio') || text.contains('médico')) return 'Saúde';
    if (text.contains('cinema') || text.contains('jogo') || text.contains('festa')) return 'Lazer';
    return 'Geral';
  }

  String _extractDescription(String fullText, double parsedVal) {
    String clean = fullText;
    clean = clean.replaceAll(RegExp(r'gastei|paguei|comprei|recebi|ganhei|por|de|reais|r\$', caseSensitive: false), '').trim();
    if (parsedVal > 0) {
      clean = clean.replaceAll(parsedVal.toString(), '').replaceAll(parsedVal.toInt().toString(), '').trim();
    }
    if (clean.length > 2) {
      return clean[0].toUpperCase() + clean.substring(1);
    }
    return fullText;
  }

  void _showCalculatorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151821),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setCalcState) {
            void onBtnPress(String val) {
              setCalcState(() {
                if (val == 'C') {
                  _calcDisplay = '0';
                  _calcFirstNum = 0.0;
                  _calcOperator = '';
                  _calcResetNext = false;
                } else if (val == '+' || val == '-' || val == '×' || val == '÷') {
                  _calcFirstNum = double.tryParse(_calcDisplay) ?? 0.0;
                  _calcOperator = val;
                  _calcResetNext = true;
                } else if (val == '=') {
                  double secondNum = double.tryParse(_calcDisplay) ?? 0.0;
                  double res = 0.0;
                  if (_calcOperator == '+') res = _calcFirstNum + secondNum;
                  if (_calcOperator == '-') res = _calcFirstNum - secondNum;
                  if (_calcOperator == '×') res = _calcFirstNum * secondNum;
                  if (_calcOperator == '÷') res = secondNum != 0 ? _calcFirstNum / secondNum : 0.0;

                  _calcDisplay = res.toStringAsFixed(res.truncateToDouble() == res ? 0 : 2);
                  _calcOperator = '';
                  _calcResetNext = true;
                } else {
                  if (_calcDisplay == '0' || _calcResetNext) {
                    _calcDisplay = val;
                    _calcResetNext = false;
                  } else {
                    _calcDisplay += val;
                  }
                }
              });
            }

            Widget buildBtn(String txt, {Color? color, Color? textColor}) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color ?? const Color(0xFF232734),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => onBtnPress(txt),
                    child: Text(txt, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor ?? Colors.white)),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🧮 Calculadora Rápida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                      IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0F12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF232734)),
                    ),
                    child: Text(
                      _calcDisplay,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00)),
                    ),
                  ),
                  Row(
                    children: [
                      buildBtn('C', color: Colors.redAccent.withOpacity(0.3), textColor: Colors.redAccent),
                      buildBtn('÷', color: const Color(0xFF232734), textColor: const Color(0xFFCCFF00)),
                      buildBtn('×', color: const Color(0xFF232734), textColor: const Color(0xFFCCFF00)),
                      buildBtn('-', color: const Color(0xFF232734), textColor: const Color(0xFFCCFF00)),
                    ],
                  ),
                  Row(
                    children: [
                      buildBtn('7'),
                      buildBtn('8'),
                      buildBtn('9'),
                      buildBtn('+', color: const Color(0xFF232734), textColor: const Color(0xFFCCFF00)),
                    ],
                  ),
                  Row(
                    children: [
                      buildBtn('4'),
                      buildBtn('5'),
                      buildBtn('6'),
                      buildBtn('=', color: const Color(0xFFCCFF00), textColor: Colors.black),
                    ],
                  ),
                  Row(
                    children: [
                      buildBtn('1'),
                      buildBtn('2'),
                      buildBtn('3'),
                      buildBtn('0'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            detailWidget ?? const SizedBox.shrink(),
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
                _buildTabChip(2, 'Metas & Caixinhas', Icons.savings),
                _buildTabChip(3, 'Contas & Dívidas', Icons.calendar_month),
                _buildTabChip(4, 'Cartão & Parcelas', Icons.credit_card),
                _buildTabChip(5, 'Compras', Icons.shopping_cart),
                _buildTabChip(6, 'Mudança', Icons.local_shipping),
                _buildTabChip(7, 'Já Possuo', Icons.inventory_2),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildInicioTab(),
                _buildAtividadesTab(),
                _buildMetasTab(),
                _buildContasTab(),
                _buildCartaoTab(),
                _buildComprasTab(),
                _buildMudancaTab(),
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

  // ===========================================================================
  // ABA 1: INÍCIO (DASHBOARD EXECUTIVO)
  // ===========================================================================
  Widget _buildInicioTab() {
    Map<String, double> catTotals = {};
    double totalSaidasExtrato = 0.0;
    for (var tx in transacoes) {
      if (tx.value < 0) {
        double posVal = tx.value.abs();
        catTotals[tx.category] = (catTotals[tx.category] ?? 0.0) + posVal;
        totalSaidasExtrato += posVal;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Saldo Zerado! Lançamentos automáticos via chat disponíveis abaixo.',
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
                    'Detalhamento do saldo livre disponível.',
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Saldo Livre Principal'),
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
                  subtitle: '${transacoes.length} lançamentos',
                  icon: Icons.trending_down,
                  onTap: () => _showCardDetails(
                    'Gastos do Mês',
                    'Total de despesas registradas no mês.',
                    ElevatedButton.icon(
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildClickableCard(
                  title: 'Fatura Atual',
                  value: 'R\$ ${fatura.toStringAsFixed(2)}',
                  subtitle: 'Clique para ver',
                  icon: Icons.credit_card,
                  onTap: () => _showCardDetails(
                    'Fatura do Cartão',
                    'Acompanhamento do cartão principal.',
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cartão de Crédito'),
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
                    'Balanço comparativo de Entradas (+) vs Saídas (-).',
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Entradas Acumuladas'),
                          trailing: Text('+R\$ ${saldo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Saídas Acumuladas'),
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

          // ANÁLISE PERCENTUAL DE GASTOS POR CATEGORIA (GRÁFICO VISUAL)
          if (catTotals.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151821),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF232734)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('📊 Distribuição de Gastos por Categoria', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Icon(Icons.pie_chart, color: Color(0xFFCCFF00), size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: catTotals.entries.map((entry) {
                      double pct = totalSaidasExtrato > 0 ? (entry.value / totalSaidasExtrato) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${entry.key} (${(pct * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                Text('R\$ ${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: pct,
                              backgroundColor: const Color(0xFF232734),
                              color: const Color(0xFFCCFF00),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // CHAT COM GIDEON
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
                    children: const [
                      CircleAvatar(
                        backgroundColor: Color(0xFFCCFF00),
                        radius: 12,
                        child: Icon(Icons.bolt, color: Colors.black, size: 14),
                      ),
                      SizedBox(width: 8),
                      Text('Chat Gideon (Inteligência NLP com Data)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                            hintText: 'Ex: Comprei pizza por 50 OU Recebi 1200...',
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
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFFCCFF00))),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ABA 2: ATIVIDADES
  // ===========================================================================
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
                  label: const Text('Limpar', style: TextStyle(color: Colors.redAccent)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: transacoes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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

  // ===========================================================================
  // ABA 3: METAS & CAIXINHAS FINANCEIRAS
  // ===========================================================================
  Widget _buildMetasTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯 Caixinhas & Metas Financeiras', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
          const SizedBox(height: 4),
          const Text('Guarde dinheiro para objetivos específicos e acompanhe o progresso.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          // ADICIONAR NOVA META
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _goalTitleCtrl,
                  decoration: const InputDecoration(hintText: 'Nome da Meta (ex: Reserva, Geladeira)...'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _goalTargetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Meta R\$'),
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
                  if (_goalTitleCtrl.text.isNotEmpty) {
                    double target = double.tryParse(_goalTargetCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    setState(() {
                      metas.add(GoalItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _goalTitleCtrl.text,
                        targetAmount: target,
                      ));
                    });
                    _saveData();
                    _goalTitleCtrl.clear();
                    _goalTargetCtrl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: metas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.savings_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhuma meta ou caixinha criada ainda.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: metas.length,
                    itemBuilder: (ctx, i) {
                      var item = metas[i];
                      double pct = item.targetAmount > 0 ? (item.currentAmount / item.targetAmount).clamp(0.0, 1.0) : 0.0;

                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        metas.removeAt(i);
                                      });
                                      _saveData();
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Guardado: R\$ ${item.currentAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFCCFF00), fontWeight: FontWeight.bold)),
                                  Text('Meta: R\$ ${item.targetAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: pct,
                                backgroundColor: const Color(0xFF232734),
                                color: const Color(0xFFCCFF00),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      _showDepositDialog(i, isWithdrawal: true);
                                    },
                                    icon: const Icon(Icons.remove, size: 16),
                                    label: const Text('Resgatar'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFCCFF00),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      _showDepositDialog(i, isWithdrawal: false);
                                    },
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Guardar'),
                                  ),
                                ],
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

  void _showDepositDialog(int metaIndex, {required bool isWithdrawal}) {
    TextEditingController amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151821),
        title: Text(isWithdrawal ? 'Resgatar da Caixinha' : 'Guardar na Caixinha'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Valor R\$'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCCFF00), foregroundColor: Colors.black),
            onPressed: () {
              double v = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
              if (v > 0) {
                setState(() {
                  if (isWithdrawal) {
                    metas[metaIndex].currentAmount = (metas[metaIndex].currentAmount - v).clamp(0.0, double.infinity);
                    saldo += v;
                  } else {
                    metas[metaIndex].currentAmount += v;
                    saldo -= v;
                  }
                });
                _saveData();
              }
              Navigator.pop(ctx);
            },
            child: Text(isWithdrawal ? 'Confirmar Resgate' : 'Confirmar Depósito'),
          )
        ],
      ),
    );
  }

  // ===========================================================================
  // ABA 4: CONTAS & DÍVIDAS A VENCER
  // ===========================================================================
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
                  decoration: const InputDecoration(hintText: 'Conta (Ex: Água, Luz)...'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _billAmountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'R\$'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _billDateCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'Selecione a data de vencimento...',
                    suffixIcon: Icon(Icons.calendar_month, color: Color(0xFFCCFF00)),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _billDateCtrl.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      });
                    }
                  },
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
                    double val = double.tryParse(_billAmountCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    String dt = _billDateCtrl.text.isNotEmpty ? _billDateCtrl.text : 'Em breve';
                    setState(() {
                      contas.add(BillItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _billTitleCtrl.text,
                        amount: val,
                        dueDate: dt,
                      ));
                    });
                    _saveData();
                    _billTitleCtrl.clear();
                    _billAmountCtrl.clear();
                    _billDateCtrl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: contas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhuma conta agendada a vencer.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: contas.length,
                    itemBuilder: (ctx, i) {
                      var item = contas[i];
                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              item.isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: item.isPaid ? Colors.greenAccent : Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                bool nextState = !item.isPaid;
                                contas[i] = BillItem(
                                  id: item.id,
                                  title: item.title,
                                  amount: item.amount,
                                  dueDate: item.dueDate,
                                  isPaid: nextState,
                                );
                                if (nextState) {
                                  saldo -= item.amount;
                                  gastos += item.amount;
                                } else {
                                  saldo += item.amount;
                                  gastos -= item.amount;
                                }
                              });
                              _saveData();
                            },
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: item.isPaid ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text('Vence em: ${item.dueDate} • ${item.isPaid ? "🟢 Paga" : "🔴 A Vencer"}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('R\$ ${item.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: item.isPaid ? Colors.greenAccent : Colors.redAccent)),
                              const SizedBox(width: 8),
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

  // ===========================================================================
  // ABA 5: CARTÃO & PARCELAS SIMULADAS
  // ===========================================================================
  Widget _buildCartaoTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💳 Simulador & Gestão de Compras Parceladas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
          const SizedBox(height: 4),
          const Text('Acompanhe o impacto de compras parceladas nas faturas futuras.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _instTitleCtrl,
                  decoration: const InputDecoration(hintText: 'Item (ex: TV, Sofá)...'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _instTotalValCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Total R\$'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 65,
                child: TextField(
                  controller: _instCountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'x Parc.'),
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
                  if (_instTitleCtrl.text.isNotEmpty) {
                    double tot = double.tryParse(_instTotalValCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    int cnt = int.tryParse(_instCountCtrl.text) ?? 1;
                    setState(() {
                      parcelamentos.add(InstallmentItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _instTitleCtrl.text,
                        totalAmount: tot,
                        totalInstallments: cnt,
                      ));
                    });
                    _saveData();
                    _instTitleCtrl.clear();
                    _instTotalValCtrl.clear();
                    _instCountCtrl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: parcelamentos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.credit_card_off_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhum parcelamento cadastrado.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: parcelamentos.length,
                    itemBuilder: (ctx, i) {
                      var item = parcelamentos[i];
                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Valor Parcela: R\$ ${item.monthlyValue.toStringAsFixed(2)}/mês (${item.paidInstallments}/${item.totalInstallments} pagas)'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Total: R\$ ${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  setState(() {
                                    parcelamentos.removeAt(i);
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

  // ===========================================================================
  // ABA 6: COMPRAS COM SOMA AUTOMÁTICA
  // ===========================================================================
  Widget _buildComprasTab() {
    double totalCompras = compras.fold(0.0, (sum, item) => sum + item.price);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF151821),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCCFF00)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total da Lista de Compras', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('R\$ ${totalCompras.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232734),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${compras.length} itens', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                )
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _groceryNameCtrl,
                  decoration: const InputDecoration(hintText: 'Item mercado (ex: Arroz)...'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _groceryPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Preço R\$'),
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
                    double val = double.tryParse(_groceryPriceCtrl.text.replaceAll(',', '.')) ?? 0.0;
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Sua lista de compras está vazia.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: compras.length,
                    itemBuilder: (ctx, i) {
                      var item = compras[i];
                      return Card(
                        color: const Color(0xFF151821),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('R\$ ${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                              const SizedBox(width: 8),
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

  // ===========================================================================
  // ABA 7: MÓDULO MUDANÇA (SIMULADOR, CALCULADORA, CUSTOS E CRONOGRAMA)
  // ===========================================================================
  Widget _buildMudancaTab() {
    double custoFixoMensalEstimado = simAluguel + simLuzAgua + simInternet + simTransporte + simIptu;
    double reservaImprevistos = gastosMudanca * 0.15;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('🚚 Planejamento da Mudança', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                  SizedBox(height: 4),
                  Text('Simulação de custos, imprevistos e cronograma.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showCalculatorModal,
                icon: const Icon(Icons.calculate, size: 18),
                label: const Text('Calculadora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SIMULADOR DE CUSTO DE VIDA MENSAIS (CASA NOVA)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151821),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCCFF00)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🏠 Custo de Vida Mensal (Casa Nova)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('R\$ ${custoFixoMensalEstimado.toStringAsFixed(2)}/mês', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _simAluguelCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Aluguel / Condomínio (R\$)'),
                        onChanged: (val) {
                          setState(() {
                            simAluguel = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                          });
                          _saveData();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _simLuzAguaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Luz + Água (R\$)'),
                        onChanged: (val) {
                          setState(() {
                            simLuzAgua = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                          });
                          _saveData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _simInternetCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Internet / TV (R\$)'),
                        onChanged: (val) {
                          setState(() {
                            simInternet = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                          });
                          _saveData();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _simTransporteCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Transporte (R\$)'),
                        onChanged: (val) {
                          setState(() {
                            simTransporte = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                          });
                          _saveData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _simIptuCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'IPTU e Taxas Recorrentes (R\$)'),
                  onChanged: (val) {
                    setState(() {
                      simIptu = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                    });
                    _saveData();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CARDS DE RESUMO DE INVESTIMENTO NA MUDANÇA E IMPREVISTOS
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151821),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF232734)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Investido Mudança', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('R\$ ${gastosMudanca.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151821),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF232734)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reserva Imprevistos (+15%)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('R\$ ${reservaImprevistos.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // REGISTRAR CUSTO DIRETO DA MUDANÇA
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF151821),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF232734)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adicionar Custo da Mudança (Frete, Reparo, Fita, etc.)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _moveExpenseTitleCtrl,
                        decoration: const InputDecoration(hintText: 'Ex: Frete Caminhão...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: _moveExpenseValCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        if (_moveExpenseTitleCtrl.text.isNotEmpty) {
                          double val = double.tryParse(_moveExpenseValCtrl.text.replaceAll(',', '.')) ?? 0.0;
                          setState(() {
                            gastosMudanca += val;
                            transacoes.insert(
                              0,
                              TransactionItem(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: 'Mudança: ${_moveExpenseTitleCtrl.text}',
                                value: -val,
                                category: 'Mudança',
                                date: "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}",
                              ),
                            );
                          });
                          _saveData();
                          _moveExpenseTitleCtrl.clear();
                          _moveExpenseValCtrl.clear();
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // CRONOGRAMA REGRESSIVO DE MUDANÇA (CHECKLIST POR PRAZOS)
          const Text('⏱️ Cronograma Regressivo de Mudança', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          // ADICIONAR TAREFA
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _moveTaskCtrl,
                  decoration: const InputDecoration(hintText: 'Nova pendência da mudança...'),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedTimeframeAdd,
                dropdownColor: const Color(0xFF151821),
                style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 12, fontWeight: FontWeight.bold),
                items: const [
                  DropdownMenuItem(value: '30_days', child: Text('-30 Dias')),
                  DropdownMenuItem(value: '15_days', child: Text('-15 Dias')),
                  DropdownMenuItem(value: '2_days', child: Text('-2 Dias')),
                  DropdownMenuItem(value: 'day_of_move', child: Text('No Dia')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedTimeframeAdd = val);
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  if (_moveTaskCtrl.text.isNotEmpty) {
                    setState(() {
                      tarefasMudanca.add(MoveTaskItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _moveTaskCtrl.text,
                        timeframe: _selectedTimeframeAdd,
                      ));
                    });
                    _saveData();
                    _moveTaskCtrl.clear();
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 16),

          _buildTimeframeSection('⏳ Faltam 30 Dias', '30_days'),
          _buildTimeframeSection('📦 Faltam 15 Dias', '15_days'),
          _buildTimeframeSection('🧳 Faltam 2 Dias (Mala da 1ª Noite)', '2_days'),
          _buildTimeframeSection('🚚 Dia da Mudança (Vistoria e Chaves)', 'day_of_move'),
        ],
      ),
    );
  }

  Widget _buildTimeframeSection(String sectionTitle, String timeframeKey) {
    var filteredList = tarefasMudanca.where((t) => t.timeframe == timeframeKey).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(sectionTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFCCFF00))),
        ),
        if (filteredList.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('Nenhuma pendência nesta etapa.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (ctx, i) {
              var item = filteredList[i];
              int realIndex = tarefasMudanca.indexWhere((t) => t.id == item.id);

              return Card(
                color: const Color(0xFF151821),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Checkbox(
                    value: item.isDone,
                    activeColor: const Color(0xFFCCFF00),
                    checkColor: Colors.black,
                    onChanged: (val) {
                      setState(() {
                        if (realIndex != -1) {
                          tarefasMudanca[realIndex] = MoveTaskItem(
                            id: item.id,
                            title: item.title,
                            timeframe: item.timeframe,
                            isDone: val == true,
                          );
                        }
                      });
                      _saveData();
                    },
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: item.isDone ? TextDecoration.lineThrough : null,
                      color: item.isDone ? Colors.grey : Colors.white,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () {
                      setState(() {
                        if (realIndex != -1) tarefasMudanca.removeAt(realIndex);
                      });
                      _saveData();
                    },
                  ),
                ),
              );
            },
          )
      ],
    );
  }

  // ===========================================================================
  // ABA 8: JÁ POSSUO (INVENTÁRIO)
  // ===========================================================================
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inventory, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhum item ou móvel cadastrado no inventário.', style: TextStyle(color: Colors.grey)),
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
