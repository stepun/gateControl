import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Управление калиткой',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GateControlScreen(),
    );
  }
}

class GateControlScreen extends StatefulWidget {
  const GateControlScreen({super.key});

  @override
  State<GateControlScreen> createState() => _GateControlScreenState();
}

class _GateControlScreenState extends State<GateControlScreen> {
  bool _isLoading = false;
  bool _isOpen = false;

  Future<void> _controlGate() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Используем CORS-прокси для обхода ограничений браузера
      final proxyUrl = 'https://cors-anywhere.herokuapp.com/';
      final targetUrl = 'http://dev138.sh3.su/cm?cmnd=Power%20On&user=admin&password=pi98nhr38';
      
      // Отправляем запрос на открытие калитки
      final openResponse = await http.get(
        Uri.parse('$targetUrl'),
      );

      if (openResponse.statusCode != 200) {
        throw Exception('Ошибка при открытии калитки: ${openResponse.statusCode}');
      }

      setState(() {
        _isOpen = true;
      });

      // Ждем 2 секунды
      await Future.delayed(const Duration(seconds: 2));

      // Отправляем запрос на закрытие калитки
      final closeUrl = 'http://dev138.sh3.su/cm?cmnd=Power%20Off&user=admin&password=pi98nhr38';
      final closeResponse = await http.get(
        Uri.parse('$closeUrl'),
      );

      if (closeResponse.statusCode != 200) {
        throw Exception('Ошибка при закрытии калитки: ${closeResponse.statusCode}');
      }

      setState(() {
        _isOpen = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Калитка успешно открыта и закрыта'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при управлении калиткой: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление калиткой'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _controlGate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _isOpen ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isOpen ? Colors.green : Colors.red).withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isOpen ? Icons.lock_open : Icons.lock,
                        size: 100,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 