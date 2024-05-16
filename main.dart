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
      title: 'Serveur',
      home: ServerManager(),
    );
  }
}

class ServerManager extends StatefulWidget {
  @override
  _ServerManagerState createState() => _ServerManagerState();
}

class _ServerManagerState extends State<ServerManager> {
  late ServerSocket _serverSocket;
  bool _isServerRunning = false;
  String _encryptedMessage = '';
  String _decryptedMessage = '';
  String _clientConnection = ''; // Ajout de cette variable

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    try {
      _serverSocket = await ServerSocket.bind('0.0.0.0', 12345);
      setState(() {
        print('Serveur démarré. En attente de connexion...');
      });
      print('Serveur démarré. En attente de connexion...');
      setState(() {
        _isServerRunning = true;
      });
      _serverSocket.listen((Socket clientSocket) {
        setState(() {
          _clientConnection =
              'Client connecté: ${clientSocket.remoteAddress.address}:${clientSocket.remotePort}';
        });

        print(
            'Client connecté: ${clientSocket.remoteAddress.address}:${clientSocket.remotePort}');
        clientSocket.listen((List<int> data) async {
          String message = utf8.decode(data);

          // Vérifier si le message est crypté
          bool isEncrypted = message.startsWith('ENCRYPTED:');
          if (isEncrypted) {
            setState(() {
              _encryptedMessage = message;
              _decryptedMessage =
                  _decryptMessage(message.substring('ENCRYPTED:'.length));
            });
          } else {
            setState(() {
              _encryptedMessage = '';
              _decryptedMessage = message;
            });
          }
        });
      });
    } catch (e) {
      print('Erreur lors du démarrage du serveur: $e');
    }
  }

  String _decryptMessage(String encryptedMessage) {
    final privateKey = encrypt.Key.fromUtf8(
        '01234567890123456789012345678901'); // Clé privée de 32 caractères
    final iv = encrypt.IV.fromUtf8('0123456789012345'); // IV de 16 caractères
    final encrypter = encrypt.Encrypter(encrypt.AES(privateKey));
    final decrypted = encrypter.decrypt64(encryptedMessage, iv: iv);
    return decrypted;
  }

  @override
  void dispose() {
    if (_isServerRunning) {
      _serverSocket.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serveur')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Serveur a demarrer en attente de connexion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),
            Text(_clientConnection), // Affichage de la connexion client

            SizedBox(height: 20),
            Text(
              'Message reçu en clair:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),
            Text(_decryptedMessage),

            SizedBox(height: 20),
            Text(
              'Message reçu encrypté:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(_encryptedMessage),
          ],
        ),
      ),
    );
  }
}
