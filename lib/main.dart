// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Calculator',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
            ),
            themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';

  void _onDigitPressed(String digit) {
    setState(() {
      _expression += digit;
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      _expression += operator;
    });
  }

  void _onClearPressed() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  void _onEqualsPressed() {
    try {
      setState(() {
        _result = _calculateResult(_expression);
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  void _onBackspacePressed() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  String _calculateResult(String expression) {
    try {
      expression = expression.replaceAll('x', '*');
      Expression exp = Expression.parse(expression);
      const evaluator = ExpressionEvaluator();
      num result = evaluator.eval(exp, {});
      return result.toString();
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _result,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    CalculatorButton('7', _onDigitPressed),
                    CalculatorButton('8', _onDigitPressed),
                    CalculatorButton('9', _onDigitPressed),
                    CalculatorButton('/', _onOperatorPressed,
                        backgroundColor: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    CalculatorButton('4', _onDigitPressed),
                    CalculatorButton('5', _onDigitPressed),
                    CalculatorButton('6', _onDigitPressed),
                    CalculatorButton('x', _onOperatorPressed,
                        backgroundColor: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    CalculatorButton('1', _onDigitPressed),
                    CalculatorButton('2', _onDigitPressed),
                    CalculatorButton('3', _onDigitPressed),
                    CalculatorButton('-', _onOperatorPressed,
                        backgroundColor: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    CalculatorButton('0', _onDigitPressed),
                    CalculatorButton('.', _onDigitPressed),
                    CalculatorButton('=', (_) => _onEqualsPressed(),
                        backgroundColor: Colors.orange),
                    CalculatorButton('+', _onOperatorPressed,
                        backgroundColor: Colors.orange),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CalculatorButton('Clear', (_) => _onClearPressed(),
                    backgroundColor: Colors.red),
                CalculatorButton('Backspace', (_) => _onBackspacePressed(),
                    backgroundColor: Colors.blueGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final Function(String) onPressed;
  final Color backgroundColor;

  const CalculatorButton(this.text, this.onPressed,
      {this.backgroundColor = const Color(0xFF2D2D2D), super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20.0),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 8, // Add shadow to buttons
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          onPressed: () => onPressed(text),
        ),
      ),
    );
  }
}
