import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

const String apiKey = 'VOTRE_CLE_API'; 

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  
  String _selectedModel = 'gemini-2.5-flash';
  PlatformFile? _attachedFile;

  final List<String> _models = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'txt'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _attachedFile = result.files.first;
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedFile == null) return;
    if (_isLoading) return;

    final userMessage = {
      'text': text,
      'sender': 'user',
      'fileName': _attachedFile?.name,
    };

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _controller.clear();
    final fileToSend = _attachedFile;
    setState(() => _attachedFile = null);

    final response = await _getGeminiResponse(text, fileToSend);

    setState(() {
      _messages.add({'text': response, 'sender': 'bot'});
      _isLoading = false;
    });
  }

  Future<String> _getGeminiResponse(String query, PlatformFile? file) async {
    final url = 'https://generativelanguage.googleapis.com/v1/models/$_selectedModel:generateContent?key=$apiKey';

    try {
      List<Map<String, dynamic>> parts = [];

      if (query.isNotEmpty) {
        parts.add({"text": query});
      }

      if (file != null && file.bytes != null) {
        String base64File = base64Encode(file.bytes!);
        String mimeType = _getMimeType(file.extension);
        parts.add({
          "inlineData": {
            "mimeType": mimeType,
            "data": base64File
          }
        });
      }

      if (parts.isEmpty) return "Veuillez entrer un message ou un fichier.";

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": parts
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'] ?? "Réponse vide.";
        }
        return "Le modèle n'a pas renvoyé de réponse (filtres de sécurité ?).";
      } else {
        final errorBody = response.body;
        print("Erreur API : ${response.statusCode} - $errorBody");
        return "Erreur API (${response.statusCode}) : Quota dépassée ou modèle indisponible.\nDétails : $errorBody\nEssayez un modèle plus léger ou activez la facturation.";
      }
    } catch (e) {
      print("Exception: $e");
      return "Erreur réseau : $e";
    }
  }

  String _getMimeType(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'txt': return 'text/plain';
      default: return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedModel,
            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            items: _models.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => _selectedModel = val!),
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: Colors.grey), onPressed: () => setState(() => _messages.clear())),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),

          if (_isLoading) LinearProgressIndicator(backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation(Colors.blueAccent)),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isUser = msg['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (msg['fileName'] != null)
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.attach_file, size: 16), Text(msg['fileName'])]),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
                bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Text(
              msg['text'] ?? '',
              style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: SafeArea(
        child: Column(
          children: [
            if (_attachedFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.file_present, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(_attachedFile!.name, style: TextStyle(fontSize: 12)),
                    IconButton(icon: Icon(Icons.close, size: 16), onPressed: () => setState(() => _attachedFile = null)),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.blueAccent), onPressed: _pickFile),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écrivez votre message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(icon: Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendMessage),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
