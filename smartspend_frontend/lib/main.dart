import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SmartSpendApp());
}

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSpend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isLogin = true;
  bool _obscurePassword = true;
  static const String _baseUrl = 'http://127.0.0.1:8000';
  String? _token;

  Future<void> _authenticate() async {
    if (_usernameController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final endpoint = _isLogin ? '/auth/login' : '/auth/signup';
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'username': _usernameController.text.trim(), 'password': _passwordController.text.trim()}),
      );

      if (response.statusCode == 200) {
        if (_isLogin) {
          final data = jsonDecode(response.body);
          setState(() {
            _token = data['access_token'];
            _isLoading = false;
          });
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(token: _token!)));
          }
        } else {
          setState(() {
            _isLoading = false;
            _isLogin = true;
            _error = 'Account created! Please login.';
          });
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['detail'] ?? 'Authentication failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('SmartSpend', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  const Text('Track your expenses with AI', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Column(
                      children: [
                        Text(_isLogin ? 'Welcome Back!' : 'Create Account', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Username', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626)))),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _authenticate,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                            child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(onPressed: () => setState(() {_isLogin = !_isLogin; _error = null;}), child: Text(_isLogin ? "Don't have an account? Sign up" : 'Already have an account? Login', style: const TextStyle(color: Color(0xFF6366F1)))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AddExpenseScreen(token: widget.token),
          MonthlySummaryScreen(token: widget.token),
          ExpenseListScreen(token: widget.token),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle, color: Color(0xFF6366F1)), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF6366F1)), label: 'Summary'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF6366F1)), label: 'Expenses'),
        ],
      ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  final String token;
  const AddExpenseScreen({super.key, required this.token});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _result;
  String? _predictedCategory;
  bool _isSuccess = false;

  static const String _baseUrl = 'http://127.0.0.1:8000';

  Future<void> _addExpense() async {
    if (_amountController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      setState(() {_result = 'Please enter amount and description'; _isSuccess = false;});
      return;
    }

    setState(() {_isLoading = true; _result = null; _predictedCategory = null;});

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/expenses/'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
        body: jsonEncode({'amount': double.tryParse(_amountController.text) ?? 0.0, 'description': _descriptionController.text.trim(), 'category': null}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictedCategory = data['category'];
          _result = 'Expense added successfully!';
          _isSuccess = true;
          _isLoading = false;
        });
        _amountController.clear();
        _descriptionController.clear();
      } else {
        setState(() {_result = 'Failed to add expense'; _isSuccess = false; _isLoading = false;});
      }
    } catch (e) {
      setState(() {_result = 'Network error'; _isSuccess = false; _isLoading = false;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8FAFC), Colors.white])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text('Add Expense', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('AI will automatically categorize your expense', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))]),
                  child: Column(
                    children: [
                      TextField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center, decoration: InputDecoration(prefixText: '\$ ', prefixStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)), hintText: '0.00', hintStyle: TextStyle(color: Colors.grey[300], fontSize: 32), border: InputBorder.none, filled: false)),
                      Divider(color: Colors.grey[200]),
                      const SizedBox(height: 16),
                      TextField(controller: _descriptionController, maxLines: 3, decoration: InputDecoration(hintText: 'What did you spend on?', hintStyle: TextStyle(color: Colors.grey[400]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)), filled: true, fillColor: const Color(0xFFF8FAFC), prefixIcon: const Icon(Icons.receipt_outlined, color: Color(0xFF6366F1)))),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addExpense,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                          child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome), SizedBox(width: 8), Text('Add with AI Categorization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: _isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(16), border: Border.all(color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444), width: 2)),
                    child: Column(
                      children: [
                        Icon(_isSuccess ? Icons.check_circle : Icons.error, color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 48),
                        const SizedBox(height: 12),
                        Text(_result!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444)), textAlign: TextAlign.center),
                        if (_predictedCategory != null) ...[
                          const SizedBox(height: 12),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(20)), child: Text(_predictedCategory!.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _buildQuickAddButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    final quickAmounts = [5.0, 10.0, 20.0, 50.0, 100.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Add', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: quickAmounts.map((amount) => ActionChip(label: Text('\$$amount'), onPressed: () {_amountController.text = amount.toString();}, backgroundColor: const Color(0xFFF1F5F9), side: BorderSide.none)).toList()),
      ],
    );
  }
}

class MonthlySummaryScreen extends StatefulWidget {
  final String token;
  const MonthlySummaryScreen({super.key, required this.token});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  Map<String, double>? _summary;
  bool _isLoading = false;
  String? _error;

  static const String _baseUrl = 'http://127.0.0.1:8000';
  final List<String> _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {_isLoading = true; _error = null;});
    try {
      final response = await http.get(Uri.parse('$_baseUrl/expenses/summary/$_selectedYear/$_selectedMonth'), headers: {'Accept': 'application/json', 'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _summary = Map<String, double>.from((data['categories'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())));
          _isLoading = false;
        });
      } else {
        setState(() {_error = 'Failed to load'; _isLoading = false;});
      }
    } catch (e) {
      setState(() {_error = 'Network error'; _isLoading = false;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8FAFC), Colors.white])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Monthly Summary', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                      child: DropdownButtonHideUnderline(child: DropdownButton<int>(value: _selectedMonth, isExpanded: true, items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_months[i]))), onChanged: (v) => setState(() {_selectedMonth = v!; _loadSummary();}))),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                      child: DropdownButtonHideUnderline(child: DropdownButton<int>(value: _selectedYear, isExpanded: true, items: List.generate(5, (i) => DropdownMenuItem(value: DateTime.now().year - i, child: Text('${DateTime.now().year - i}'))), onChanged: (v) => setState(() {_selectedYear = v!; _loadSummary();}))),
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red))
                else if (_summary != null && _summary!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Column(children: [
                      const Text('Total Spent', style: TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('\$${_summary!.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('${_months[_selectedMonth - 1]} $_selectedYear', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  const Text('By Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...(_summary!.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).map((e) => _buildCategoryCard(e.key, e.value)),
                ] else
                  Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), const Text('No expenses this month', style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8))), const Text('Add some expenses to see your summary', style: TextStyle(color: Color(0xFF94A3B8)))])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, double amount) {
    final total = _summary!.values.fold(0.0, (a, b) => a + b);
    final percentage = (amount / total * 100);
    final colors = [const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF8B5CF6), const Color(0xFFEC4899), const Color(0xFF14B8A6), const Color(0xFFF97316)];
    final color = colors[category.hashCode % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_getCategoryIcon(category), color: color, size: 20)), const SizedBox(width: 12), Text(category, style: const TextStyle(fontWeight: FontWeight.w600))]),
          Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percentage / 100, backgroundColor: const Color(0xFFF1F5F9), valueColor: AlwaysStoppedAnimation(color), minHeight: 6)),
        const SizedBox(height: 4),
        Text('${percentage.toStringAsFixed(1)}% of total', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ]),
    );
  }

  IconData _getCategoryIcon(String category) {
    final icons = {'Food': Icons.restaurant, 'Transportation': Icons.directions_car, 'Entertainment': Icons.movie, 'Shopping': Icons.shopping_bag, 'Utilities': Icons.bolt, 'Health': Icons.favorite, 'Education': Icons.school, 'Housing': Icons.home, 'Personal Care': Icons.spa};
    return icons[category] ?? Icons.category;
  }
}

class ExpenseListScreen extends StatefulWidget {
  final String token;
  const ExpenseListScreen({super.key, required this.token});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<dynamic>? _expenses;
  bool _isLoading = false;
  static const String _baseUrl = 'http://127.0.0.1:8000';
  final List<String> _categories = ['Food', 'Transportation', 'Entertainment', 'Shopping', 'Utilities', 'Health', 'Education', 'Housing', 'Personal Care', 'Uncategorized'];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/expenses/'), headers: {'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        setState(() {_expenses = jsonDecode(response.body); _isLoading = false;});
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editExpense(int id, String currentCategory) async {
    String selectedCategory = currentCategory;
    await showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: const Text('Edit Category'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Select the correct category:', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: _categories.map((cat) => ChoiceChip(label: Text(cat), selected: selectedCategory == cat, selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.2), onSelected: (selected) {if (selected) {setDialogState(() => selectedCategory = cat);}})).toList()),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {Navigator.pop(context); await _updateCategory(id, selectedCategory);}, child: const Text('Save')),
      ],
    )));
  }

  Future<void> _updateCategory(int id, String newCategory) async {
    try {
      final response = await http.put(Uri.parse('$_baseUrl/expenses/$id'), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'}, body: jsonEncode({'category': newCategory}));
      if (response.statusCode == 200) {
        _loadExpenses();
        if (mounted) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category updated to $newCategory'), backgroundColor: const Color(0xFF10B981)));}
      }
    } catch (e) {
      if (mounted) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update'), backgroundColor: Colors.red));}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8FAFC), Colors.white])),
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.all(24), child: Text('All Expenses', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator()) : _expenses == null || _expenses!.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), Text('No expenses yet', style: TextStyle(color: Colors.grey[500], fontSize: 16))])) : RefreshIndicator(onRefresh: _loadExpenses, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 24), itemCount: _expenses!.length, itemBuilder: (context, i) {
                final e = _expenses![i];
                final colors = [const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF8B5CF6)];
                final color = colors[e['category'].hashCode % colors.length];
                return GestureDetector(
                  onTap: () => _editExpense(e['id'], e['category']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(e['category'][0], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e['description'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(e['category'], style: TextStyle(fontSize: 12, color: color))), const SizedBox(width: 8), Icon(Icons.edit, size: 12, color: Colors.grey[400])])])),
                      Text('\$${e['amount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                  ),
                );
              })),
            ),
          ]),
        ),
      ),
    );
  }
}
