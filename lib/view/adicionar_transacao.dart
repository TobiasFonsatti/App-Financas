import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/message_helpers.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    double value = double.parse(newText) / 100;
    String formattedValue = value.toStringAsFixed(2).replaceAll('.', ',');

    List<String> parts = formattedValue.split(',');
    String intPart = parts[0];
    String decPart = parts[1];

    String finalIntPart = "";
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        finalIntPart = ".$finalIntPart";
        count = 0;
      }
      finalIntPart = intPart[i] + finalIntPart;
      count++;
    }

    String newString = '$finalIntPart,$decPart';

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  String _transactionType = 'expense';

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus && _amountController.text.isEmpty) {
        _amountController.value = const TextEditingValue(
          text: '0,00',
          selection: TextSelection.collapsed(offset: 4),
        );
      } else if (!_amountFocusNode.hasFocus &&
          _amountController.text == '0,00') {
        _amountController.clear();
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      showAppSnackBar(context, 'Transação adicionada com sucesso!');
      Navigator.of(context).pop();
      return;
    }

    showAppSnackBar(
      context,
      'Corrija os campos marcados para salvar a transação.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Transação'), centerTitle: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF133E28), Color(0xFF0E2F1F)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Insira uma descrição válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value == '0,00') {
                      return 'Insira um valor válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('Receita'),
                      selected: _transactionType == 'income',
                      selectedColor: Colors.green.withValues(alpha: 0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _transactionType = 'income');
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Despesa'),
                      selected: _transactionType == 'expense',
                      selectedColor: Colors.red.withValues(alpha: 0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _transactionType = 'expense');
                        }
                      },
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
