import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse('wss://wssimple.arinov.com'));

    _channel.stream.listen((event) {
      setState(() {
        _messages.add(event.toString());
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket ListView Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('WebSocket ListView Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(_messages[index]));
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Kirim pesan',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}