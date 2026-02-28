import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Taller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0C111B),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _leftOperand;
  String? _pendingOperator;
  bool _replaceDisplay = false;
  bool _hasError = false;

  void _handleButtonPress(String label) {
    switch (label) {
      case 'C':
        _clearAll();
        break;
      case 'DEL':
        _backspace();
        break;
      case '.':
        _inputDecimal();
        break;
      case '+':
      case '-':
      case 'x':
      case '/':
        _setOperator(label);
        break;
      case '=':
        _calculate();
        break;
      default:
        _inputDigit(label);
    }
  }

  void _inputDigit(String digit) {
    setState(() {
      if (_hasError) {
        _clearAllInternal();
      }
      if (_replaceDisplay || _display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
      _replaceDisplay = false;
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_hasError) {
        _clearAllInternal();
      }
      if (_replaceDisplay) {
        _display = '0.';
        _replaceDisplay = false;
        return;
      }
      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _setOperator(String operator) {
    setState(() {
      if (_hasError) {
        _clearAllInternal();
      }

      final current = double.tryParse(_display);
      if (current == null) {
        return;
      }

      if (_leftOperand != null &&
          _pendingOperator != null &&
          !_replaceDisplay) {
        final result = _executeOperation(
          _leftOperand!,
          current,
          _pendingOperator!,
        );
        if (result == null) {
          _setDivisionByZeroError();
          return;
        }
        _leftOperand = result;
        _display = _formatNumber(result);
      } else {
        _leftOperand = current;
      }

      _pendingOperator = operator;
      _expression = '${_formatNumber(_leftOperand!)} $operator';
      _replaceDisplay = true;
    });
  }

  void _calculate() {
    setState(() {
      if (_hasError ||
          _leftOperand == null ||
          _pendingOperator == null ||
          _replaceDisplay) {
        return;
      }

      final rightOperand = double.tryParse(_display);
      if (rightOperand == null) {
        return;
      }

      final result = _executeOperation(
        _leftOperand!,
        rightOperand,
        _pendingOperator!,
      );
      if (result == null) {
        _setDivisionByZeroError();
        return;
      }

      _expression =
          '${_formatNumber(_leftOperand!)} $_pendingOperator ${_formatNumber(rightOperand)} =';
      _display = _formatNumber(result);
      _leftOperand = null;
      _pendingOperator = null;
      _replaceDisplay = true;
    });
  }

  void _backspace() {
    setState(() {
      if (_replaceDisplay || _hasError) {
        return;
      }

      if (_display.length <= 1) {
        _display = '0';
        return;
      }

      _display = _display.substring(0, _display.length - 1);
    });
  }

  void _clearAll() {
    setState(_clearAllInternal);
  }

  void _clearAllInternal() {
    _display = '0';
    _expression = '';
    _leftOperand = null;
    _pendingOperator = null;
    _replaceDisplay = false;
    _hasError = false;
  }

  void _setDivisionByZeroError() {
    _display = 'Error';
    _expression = 'No se puede dividir entre 0';
    _leftOperand = null;
    _pendingOperator = null;
    _replaceDisplay = true;
    _hasError = true;
  }

  double? _executeOperation(double left, double right, String operator) {
    switch (operator) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case 'x':
        return left * right;
      case '/':
        if (right == 0) {
          return null;
        }
        return left / right;
      default:
        return null;
    }
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    final fixed = value.toStringAsFixed(10);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  bool _isOperator(String label) {
    return label == '/' ||
        label == 'x' ||
        label == '-' ||
        label == '+' ||
        label == '=';
  }

  bool _isUtility(String label) {
    return label == 'C' || label == 'DEL';
  }

  Widget _buildButton(String label, {int flex = 1}) {
    final isEquals = label == '=';
    final isOperator = _isOperator(label);
    final isUtility = _isUtility(label);

    final backgroundColor = isEquals
        ? const Color(0xFF1E6FDB)
        : isOperator
        ? const Color(0xFF2A5EA8)
        : isUtility
        ? const Color(0xFF45576E)
        : const Color(0xFF273244);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: const Color(0xFF8EA8D6).withValues(alpha: 0.25),
              ),
              elevation: 0,
            ),
            onPressed: () => _handleButtonPress(label),
            child: FittedBox(child: Text(label)),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Expanded(child: Row(children: children));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101827), Color(0xFF0A0F17)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  alignment: Alignment.bottomRight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141E2D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _expression,
                        key: const Key('expression_text'),
                        style: const TextStyle(
                          color: Color(0xFF9CB2CF),
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _display,
                          key: const Key('display_text'),
                          style: const TextStyle(
                            color: Color(0xFFE5EEFF),
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    children: [
                      _buildRow([
                        _buildButton('C'),
                        _buildButton('DEL'),
                        _buildButton('/'),
                        _buildButton('x'),
                      ]),
                      _buildRow([
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('-'),
                      ]),
                      _buildRow([
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('+'),
                      ]),
                      _buildRow([
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('='),
                      ]),
                      _buildRow([
                        _buildButton('0', flex: 2),
                        _buildButton('.'),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
