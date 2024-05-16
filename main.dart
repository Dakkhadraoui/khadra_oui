import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final String _ipAddress = '192.168.1.10';
  final int _port = 12345;

  void _sendMessage(String message) async {
    try {
      Socket socket = await Socket.connect(_ipAddress, _port);
      socket.write(message);
      socket.close();
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
    }
  }

  String _encryptMessage(String message) {
    final publicKey = encrypt.Key.fromUtf8(
        '01234567890123456789012345678901'); // Clé publique de 32 caractères
    final iv = encrypt.IV.fromUtf8('0123456789012345'); // IV de 16 caractères
    final encrypter = encrypt.Encrypter(encrypt.AES(publicKey));
    final encrypted = encrypter.encrypt(message, iv: iv);
    return 'ENCRYPTED:${encrypted.base64}';
  }

  void _sendClearMessage() {
    Map<String, String> data = {
      'id': _idController.text,
      'name': _nameController.text,
      'surname': _surnameController.text,
      'birthdate': _birthdateController.text,
      'phone': _phoneController.text,
    };
    String jsonMessage = jsonEncode(data);
    _sendMessage(jsonMessage);
  }

  void _sendEncryptedMessage() {
    Map<String, String> data = {
      'id': _idController.text,
      'name': _nameController.text,
      'surname': _surnameController.text,
      'birthdate': _birthdateController.text,
      'phone': _phoneController.text,
    };
    String jsonMessage = jsonEncode(data);
    String encryptedMessage = _encryptMessage(jsonMessage);
    _sendMessage(encryptedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _birthdateController,
              decoration: InputDecoration(labelText: 'Date de naissance'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Téléphone'),
            ),
            ElevatedButton(
              onPressed: _sendClearMessage,
              child: Text('Envoyer en clair'),
            ),
            ElevatedButton(
              onPressed: _sendEncryptedMessage,
              child: Text('Envoyer encrypté'),
            ),
          ],
        ),
      ),
    );
  }
}
