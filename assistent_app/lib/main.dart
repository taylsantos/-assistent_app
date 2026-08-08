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
class GideonApp extends StatefulWidget {
  const GideonApp({super.key});

  @override
  State<GideonApp> createState() => _GideonAppState();
}

class _GideonAppState extends State<GideonApp> {
  // CONFIGURAÇÕES DE TEMA E CORES
  String _themeMode = 'dark'; // 'dark', 'light', 'midnight', 'cyberpunk'
  String _colorTheme = 'pink'; // 'pink', 'neon', 'blue', 'orange'

  @override
  void initState() {
    super.initState();
    _loadThemePrefs();
  }

  Future<void> _loadThemePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _themeMode = prefs.getString('themeMode') ?? 'dark';
        _colorTheme = prefs.getString('colorTheme') ?? 'pink';
      });
    } catch (_) {}
  }

  Future<void> _saveThemePrefs(String mode, String color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', mode);
      await prefs.setString('colorTheme', color);
      setState(() {
        _themeMode = mode;
        _colorTheme = color;
      });
    } catch (_) {}
  }

  Color _getPrimaryColor() {
    switch (_colorTheme) {
      case 'neon':
        return const Color(0xFFCCFF00);
      case 'blue':
        return const Color(0xFF00D2D3);
      case 'orange':
        return const Color(0xFFFF9F43);
      case 'pink':
      default:
        return const Color(0xFFE056FD);
    }
  }

  Color _getBackgroundColor() {
    switch (_themeMode) {
      case 'light':
        return const Color(0xFFF7F8FA);
      case 'midnight':
        return const Color(0xFF0F172A);
      case 'cyberpunk':
        return const Color(0xFF180828);
      case 'dark':
      default:
        return const Color(0xFF0D0F12);
    }
  }

  Color _getCardColor() {
    switch (_themeMode) {
      case 'light':
        return const Color(0xFFFFFFFF);
      case 'midnight':
        return const Color(0xFF1E293B);
      case 'cyberpunk':
        return const Color(0xFF28123E);
      case 'dark':
      default:
        return const Color(0xFF151821);
    }
  }

  bool _isLight() => _themeMode == 'light';

  @override
  Widget build(BuildContext context) {
    Color primaryColor = _getPrimaryColor();
    Color bgColor = _getBackgroundColor();
    Color cardColor = _getCardColor();
    bool light = _isLight();

    return MaterialApp(
      title: 'Gideon Financial Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: light ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        primaryColor: primaryColor,
        cardColor: cardColor,
        colorScheme: ColorScheme(
          brightness: light ? Brightness.light : Brightness.dark,
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: primaryColor,
          onSecondary: Colors.white,
          error: const Color(0xFFFF4444),
          onError: Colors.white,
          surface: cardColor,
          onSurface: light ? Colors.black87 : Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: light ? const Color(0xFFEFEFEF) : const Color(0xFF0D0F12),
          hintStyle: TextStyle(color: light ? Colors.grey[600] : Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: light ? const Color(0xFFDDD3EE) : const Color(0xFF232734)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: light ? const Color(0xFFDDD3EE) : const Color(0xFF232734)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
      home: MainHomeScreen(
        themeMode: _themeMode,
        colorTheme: _colorTheme,
        onThemeChanged: _saveThemePrefs,
      ),
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

  GroceryItem({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
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
  final String timeframe;
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

class RepairProItem {
  final String id;
  final String service; // Ex: Pintor, Chaveiro, Eletricista
  final String name;
  final double amount;
  final bool isPaid;

  RepairProItem({
    required this.id,
    required this.service,
    required this.name,
    required this.amount,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'service': service,
        'name': name,
        'amount': amount,
        'isPaid': isPaid,
      };

  factory RepairProItem.fromJson(Map<String, dynamic> json) => RepairProItem(
        id: json['id']?.toString() ?? '',
        service: json['service']?.toString() ?? 'Serviço',
        name: json['name']?.toString() ?? '',
        amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
        isPaid: json['isPaid'] == true,
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
  final String themeMode;
  final String colorTheme;
  final Function(String mode, String color) onThemeChanged;

  const MainHomeScreen({
    super.key,
    required this.themeMode,
    required this.colorTheme,
    required this.onThemeChanged,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedTabIndex = 0; // 0: Chat, 1: Dashboard, 2: Atividades, 3: Metas, 4: Contas, 5: Cartão, 6: Compras, 7: Mudança, 8: Possuo

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
  List<RepairProItem> profissionaisMudanca = [];
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

  // PROs CONTROLLERS
  final TextEditingController _proServiceCtrl = TextEditingController();
  final TextEditingController _proNameCtrl = TextEditingController();
  final TextEditingController _proAmountCtrl = TextEditingController();

  // METAS E PARCELAS CONTROLLERS
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
      'text': 'Perfeitaaa, já estou pronta! 💕 Digite algo como "Gastei 50 no almoço" ou "Recebi 1500" para começarmos.'
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
      MoveTaskItem(id: '6', title: 'Montar Mala/Caixa de Primeira Noite', timeframe: '2_days'),
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

    _proServiceCtrl.dispose();
    _proNameCtrl.dispose();
    _proAmountCtrl.dispose();

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

        String? proStr = prefs.getString('profissionaisMudanca');
        if (proStr != null) {
          List<dynamic> l = jsonDecode(proStr);
          profissionaisMudanca = l.map((e) => RepairProItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
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
      await prefs.setString('profissionaisMudanca', jsonEncode(profissionaisMudanca.map((e) => e.toJson()).toList()));
      await prefs.setString('metas', jsonEncode(metas.map((e) => e.toJson()).toList()));
      await prefs.setString('parcelamentos', jsonEncode(parcelamentos.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Zerar Todos os Dados?'),
        content: const Text('Esta ação apagará todas as informações salvas no aplicativo.'),
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
                profissionaisMudanca.clear();
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

  void _showThemeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎨 Personalizar Tema & Cores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Modo de Visualização:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildThemeChip('Dark Standard', 'dark'),
                _buildThemeChip('Light Clean', 'light'),
                _buildThemeChip('Midnight Blue', 'midnight'),
                _buildThemeChip('Cyberpunk', 'cyberpunk'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Cor de Destaque:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildColorChip('Rosa Magenta', 'pink', const Color(0xFFE056FD)),
                _buildColorChip('Verde Neon', 'neon', const Color(0xFFCCFF00)),
                _buildColorChip('Azul Oceano', 'blue', const Color(0xFF00D2D3)),
                _buildColorChip('Laranja Sunset', 'orange', const Color(0xFFFF9F43)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChip(String label, String value) {
    bool selected = widget.themeMode == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) widget.onThemeChanged(value, widget.colorTheme);
      },
    );
  }

  Widget _buildColorChip(String label, String value, Color color) {
    bool selected = widget.colorTheme == value;
    return ChoiceChip(
      avatar: CircleAvatar(backgroundColor: color, radius: 8),
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) widget.onThemeChanged(widget.themeMode, value);
      },
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
      reply = "Perfeitaaa, já registrei! 💖\n\n💵 R\$ ${val.toStringAsFixed(2)}\n📁 $category\n📅 $dateStr\n\nAdoro ver grana entrando! ✨";
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
      reply = "Anotado, meu bem! 🛍️\n\n💸 R\$ ${val.toStringAsFixed(2)}\n🏷️ $category ($description)\n📅 $dateStr\n\nSaldo atualizado no seu Dashboard!";
    } else if (lower.contains('saldo')) {
      if (val > 0 && !isExpense && !isGain) {
        setState(() {
          saldo = val;
        });
        reply = "✅ Prontinho! Seu saldo foi ajustado manualmente para R\$ ${saldo.toStringAsFixed(2)}.";
      } else {
        reply = "📊 Seu saldo livre em conta no momento é de R\$ ${saldo.toStringAsFixed(2)}.";
      }
    } else if (lower.contains('resumo') || lower.contains('quanto gastei')) {
      reply = "📊 Seu Resumo Rápido ($dateStr):\n• Saldo disponível: R\$ ${saldo.toStringAsFixed(2)}\n• Gastos acumulados: R\$ ${gastos.toStringAsFixed(2)}\n• Fatura do Cartão: R\$ ${fatura.toStringAsFixed(2)}";
    } else {
      reply = "Entendido! Você pode me mandar frases simples como 'Gastei 50 no Uber' ou 'Recebi 1200' que eu registro tudo pra você! ✨";
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
    Color primaryColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                      backgroundColor: color ?? Theme.of(context).inputDecorationTheme.fillColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => onBtnPress(txt),
                    child: Text(txt, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color)),
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
                      Text('🧮 Calculadora Rápida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _calcDisplay,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                  Row(
                    children: [
                      buildBtn('C', color: Colors.redAccent.withOpacity(0.3), textColor: Colors.redAccent),
                      buildBtn('÷', textColor: primaryColor),
                      buildBtn('×', textColor: primaryColor),
                      buildBtn('-', textColor: primaryColor),
                    ],
                  ),
                  Row(
                    children: [
                      buildBtn('7'),
                      buildBtn('8'),
                      buildBtn('9'),
                      buildBtn('+', textColor: primaryColor),
                    ],
                  ),
                  Row(
                    children: [
                      buildBtn('4'),
                      buildBtn('5'),
                      buildBtn('6'),
                      buildBtn('=', color: primaryColor, textColor: Colors.black),
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

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Gideon App', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Temas',
            onPressed: _showThemeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: 'Zerar Tudo',
            onPressed: _resetAll,
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildChatTab(),
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

      /// ======================================================================
      /// BARRA DE NAVEGAÇÃO INFERIOR ESTILO MOCKUP (CLEAN & MODERNA)
      /// ======================================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: const Border(top: BorderSide(color: Color(0x1F888888))),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.chat_bubble_outline, 'Chat'),
              _buildNavItem(1, Icons.grid_view_rounded, 'Dashboard'),
              _buildNavItem(2, Icons.list_alt, 'Extrato'),
              _buildNavItem(3, Icons.savings_outlined, 'Metas'),
              _buildNavItem(4, Icons.calendar_today_outlined, 'Contas'),
              _buildNavItem(5, Icons.credit_card_outlined, 'Parcelas'),
              _buildNavItem(6, Icons.shopping_cart_outlined, 'Compras'),
              _buildNavItem(7, Icons.local_shipping_outlined, 'Mudança'),
              _buildNavItem(8, Icons.inventory_2_outlined, 'Possuo'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool selected = _selectedTabIndex == index;
    Color primaryColor = Theme.of(context).primaryColor;
    Color unselectedColor = Colors.grey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? primaryColor : unselectedColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? primaryColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ABA 0: CHAT MÓVEL DEDICADO (ESTILO BIA)
  // ===========================================================================
  Widget _buildChatTab() {
    Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (ctx, i) {
              bool isUser = messages[i]['sender'] == 'user';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      CircleAvatar(
                        backgroundColor: primaryColor,
                        radius: 16,
                        child: const Icon(Icons.star, color: Colors.white, size: 16),
                      ),
                    if (!isUser) const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUser ? primaryColor : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          messages[i]['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.black : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 14,
                            fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'Digite sua mensagem para a Gideon...',
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: primaryColor,
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  onPressed: _sendMessage,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // ===========================================================================
  // ABA 1: DASHBOARD (INÍCIO)
  // ===========================================================================
  Widget _buildInicioTab() {
    Color primaryColor = Theme.of(context).primaryColor;

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
          Row(
            children: [
              Expanded(
                child: _buildClickableCard(
                  title: 'Saldo em contas',
                  value: 'R\$ ${saldo.toStringAsFixed(2)}',
                  subtitle: 'Saldo disponível',
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClickableCard(
                  title: 'Gastos do mês',
                  value: 'R\$ ${gastos.toStringAsFixed(2)}',
                  subtitle: '${transacoes.length} lançamentos',
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildClickableCard(
                  title: 'Fatura do Cartão',
                  value: 'R\$ ${fatura.toStringAsFixed(2)}',
                  subtitle: 'Cartão principal',
                  icon: Icons.credit_card,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClickableCard(
                  title: 'Balanço Mensal',
                  value: '+R\$ ${saldo.toStringAsFixed(2)}\n-R\$ ${gastos.toStringAsFixed(2)}',
                  subtitle: 'Fluxo de caixa',
                  icon: Icons.swap_vert,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ANÁLISE PERCENTUAL DE GASTOS POR CATEGORIA
          if (catTotals.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('📊 Distribuição por Categoria', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Icon(Icons.pie_chart, color: primaryColor, size: 18),
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
                                Text('${entry.key} (${(pct * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)),
                                Text('R\$ ${entry.value.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              color: primaryColor,
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
          ]
        ],
      ),
    );
  }

  Widget _buildClickableCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Icon(icon, size: 16, color: primaryColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 10, color: primaryColor)),
        ],
      ),
    );
  }

  // ===========================================================================
  // ABA 2: EXTRATO (ATIVIDADES)
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
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  // ABA 3: METAS & CAIXINHAS
  // ===========================================================================
  Widget _buildMetasTab() {
    Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎯 Caixinhas & Metas Financeiras', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 4),
          const Text('Guarde dinheiro para objetivos específicos.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _goalTitleCtrl,
                  decoration: const InputDecoration(hintText: 'Nome da Meta...'),
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
                  backgroundColor: primaryColor,
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
                        Text('Nenhuma meta criada ainda.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: metas.length,
                    itemBuilder: (ctx, i) {
                      var item = metas[i];
                      double pct = item.targetAmount > 0 ? (item.currentAmount / item.targetAmount).clamp(0.0, 1.0) : 0.0;

                      return Card(
                        color: Theme.of(context).cardColor,
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
                                  Text('Guardado: R\$ ${item.currentAmount.toStringAsFixed(2)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                  Text('Meta: R\$ ${item.targetAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: pct,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                color: primaryColor,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(8),
                              ),
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
  // ABA 4: CONTAS
  // ===========================================================================
  Widget _buildContasTab() {
    Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _billTitleCtrl,
                  decoration: const InputDecoration(hintText: 'Conta (Água, Luz)...'),
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
                  decoration: InputDecoration(
                    hintText: 'Vencimento...',
                    suffixIcon: Icon(Icons.calendar_month, color: primaryColor),
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
                  backgroundColor: primaryColor,
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
                        Text('Nenhuma conta a vencer.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: contas.length,
                    itemBuilder: (ctx, i) {
                      var item = contas[i];
                      return Card(
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Vence em: ${item.dueDate}'),
                          trailing: Text('R\$ ${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
  // ABA 5: PARCELAS
  // ===========================================================================
  Widget _buildCartaoTab() {
    Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💳 Compras Parceladas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _instTitleCtrl,
                  decoration: const InputDecoration(hintText: 'Item (TV, Celular)...'),
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
                width: 60,
                child: TextField(
                  controller: _instCountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Parc.'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.all(12)),
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
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('R\$ ${item.monthlyValue.toStringAsFixed(2)}/mês (${item.totalInstallments}x)'),
                          trailing: Text('R\$ ${item.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
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
  // ABA 6: COMPRAS
  // ===========================================================================
  Widget _buildComprasTab() {
    double totalCompras = compras.fold(0.0, (sum, item) => sum + item.price);
    Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total da Lista', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('R\$ ${totalCompras.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
                  ],
                ),
                Text('${compras.length} itens', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _groceryNameCtrl,
                  decoration: const InputDecoration(hintText: 'Item mercado...'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _groceryPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'R\$'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.all(12)),
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
            child: ListView.builder(
              itemCount: compras.length,
              itemBuilder: (ctx, i) {
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(compras[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text('R\$ ${compras[i].price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
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
  // ABA 7: MUDANÇA (COM PROFISSIONAIS & REPAROS)
  // ===========================================================================
  Widget _buildMudancaTab() {
    double custoFixoMensalEstimado = simAluguel + simLuzAgua + simInternet + simTransporte + simIptu;
    double reservaImprevistos = gastosMudanca * 0.15;
    double totalProfissionais = profissionaisMudanca.fold(0.0, (sum, p) => sum + p.amount);
    Color primaryColor = Theme.of(context).primaryColor;

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
                children: [
                  Text('🚚 Planejamento da Mudança', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 4),
                  const Text('Custos, profissionais, imprevistos e prazos.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: _showCalculatorModal,
                icon: const Icon(Icons.calculate, size: 16),
                label: const Text('Calculadora', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SIMULADOR DE CUSTO DE VIDA MENSAIS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🏠 Custo de Vida Mensal (Casa Nova)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('R\$ ${custoFixoMensalEstimado.toStringAsFixed(2)}/mês', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _simAluguelCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Aluguel (R\$)'),
                        onChanged: (val) {
                          setState(() => simAluguel = double.tryParse(val.replaceAll(',', '.')) ?? 0.0);
                          _saveData();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _simLuzAguaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Luz/Água (R\$)'),
                        onChanged: (val) {
                          setState(() => simLuzAgua = double.tryParse(val.replaceAll(',', '.')) ?? 0.0);
                          _saveData();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // GESTOR DE PROFISSIONAIS & REPAROS (PINTOR, CHAVEIRO, LIMPEZA)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🛠️ Profissionais & Reparos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Total: R\$ ${totalProfissionais.toStringAsFixed(2)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _proServiceCtrl,
                        decoration: const InputDecoration(hintText: 'Serviço (Pintor, Chaveiro)...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _proNameCtrl,
                        decoration: const InputDecoration(hintText: 'Nome/Contato...'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _proAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: 'Valor R\$'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.all(12)),
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        if (_proServiceCtrl.text.isNotEmpty) {
                          double val = double.tryParse(_proAmountCtrl.text.replaceAll(',', '.')) ?? 0.0;
                          setState(() {
                            profissionaisMudanca.add(RepairProItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              service: _proServiceCtrl.text,
                              name: _proNameCtrl.text,
                              amount: val,
                            ));
                          });
                          _saveData();
                          _proServiceCtrl.clear();
                          _proNameCtrl.clear();
                          _proAmountCtrl.clear();
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: profissionaisMudanca.length,
                  itemBuilder: (ctx, i) {
                    var p = profissionaisMudanca[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${p.service} • ${p.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('R\$ ${p.amount.toStringAsFixed(2)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                            onPressed: () {
                              setState(() => profissionaisMudanca.removeAt(i));
                              _saveData();
                            },
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CRONOGRAMA REGRESSIVO DE MUDANÇA
          const Text('⏱️ Cronograma Regressivo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTimeframeSection('⏳ Faltam 30 Dias', '30_days'),
          _buildTimeframeSection('📦 Faltam 15 Dias', '15_days'),
          _buildTimeframeSection('🧳 Faltam 2 Dias (Mala da 1ª Noite)', '2_days'),
          _buildTimeframeSection('🚚 Dia da Mudança (Vistoria)', 'day_of_move'),
        ],
      ),
    );
  }

  Widget _buildTimeframeSection(String sectionTitle, String timeframeKey) {
    var filteredList = tarefasMudanca.where((t) => t.timeframe == timeframeKey).toList();
    Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(sectionTitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredList.length,
          itemBuilder: (ctx, i) {
            var item = filteredList[i];
            int realIndex = tarefasMudanca.indexWhere((t) => t.id == item.id);

            return Card(
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                leading: Checkbox(
                  value: item.isDone,
                  activeColor: primaryColor,
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
                title: Text(item.title, style: TextStyle(decoration: item.isDone ? TextDecoration.lineThrough : null, fontSize: 13)),
              ),
            );
          },
        )
      ],
    );
  }

  // ===========================================================================
  // ABA 8: JÁ POSSUO
  // ===========================================================================
  Widget _buildPossuoTab() {
    Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ownedNameCtrl,
                  decoration: const InputDecoration(hintText: 'Item ou móvel...'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.all(12)),
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
            child: ListView.builder(
              itemCount: possuo.length,
              itemBuilder: (ctx, i) {
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(possuo[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(possuo[i].category),
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