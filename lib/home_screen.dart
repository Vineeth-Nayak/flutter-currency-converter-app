import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fromCurrency = "USD";
  String toCurrency = "EUR";
  double exchangeRate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];

  double _swapAngle = 0;

  @override
  void initState() {
    super.initState();
    _getCurrencies();
  }

  Future<void> _getCurrencies() async {
    var response = await http.get(
      Uri.parse("https://api.exchangerate-api.com/v4/latest/USD"),
    );

    var data = jsonDecode(response.body);
    setState(() {
      currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
      exchangeRate = data['rates'][toCurrency];
    });
  }

  Future<void> _getExchangeRates() async {
    var response = await http.get(
      Uri.parse("https://api.exchangerate-api.com/v4/latest/$fromCurrency"),
    );

    var data = jsonDecode(response.body);
    setState(() {
      exchangeRate = data['rates'][toCurrency];
    });
  }

  void _swapCurrency() async {
    setState(() {
      // Rotate icon 180 degrees on each tap
      _swapAngle += 3.14; // 180 degrees in radians

      // Swap currencies
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
    });

    // Get New Exhange Rate
    await _getExchangeRates();

    // Recalculate total
    final text = amountController.text;
    if (text.isNotEmpty) {
      final amount = double.tryParse(text);
      if (amount != null) {
        setState(() {
          total = amount * exchangeRate;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("Currency Converter"),
      ),
      // BODY
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            spacing: 30,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Image.asset(
                    "images/currencyConverter.png",
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                ),
              ),

              // Widget 2
              TextField(
                controller: amountController,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  label: Text("Amount", style: TextStyle(color: Colors.white)),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),

                onChanged: (value) {
                  if (value != '') {
                    setState(() {
                      double amount = double.parse(value);
                      total = amount * exchangeRate;
                    });
                  }
                },

                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),

              // Widget 3
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 30,
                  children: [
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        dropdownColor: Color(0xFF1d2630),
                        items:
                            currencies.map((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            fromCurrency = newValue!.toString();
                            _getExchangeRates();
                          });
                        },
                        value: fromCurrency,
                        isExpanded: true,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    // ROW  Childeren Widget 2
                    AnimatedRotation(
                      turns:
                          _swapAngle /
                          (2 * 3.14), // Convert radians to full turns
                      duration: Duration(milliseconds: 400),
                      child: IconButton(
                        onPressed: _swapCurrency,
                        icon: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),

                    // ROW Childeren Widget 3
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        dropdownColor: Color(0xFF1d2630),

                        items:
                            currencies.map((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            toCurrency = newValue!.toString();
                            _getExchangeRates();
                          });
                        },
                        value: toCurrency,
                        isExpanded: true,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Widget 4
              Text(
                "Exchange Rate: $exchangeRate",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),

              // Widget 5
              Text(
                total.toStringAsFixed(3),
                style: TextStyle(color: Colors.greenAccent, fontSize: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
