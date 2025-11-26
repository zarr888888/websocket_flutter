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
  // Kontroler untuk input teks pesan yang akan dikirim
  final TextEditingController _controller = TextEditingController();
  // Channel untuk koneksi WebSocket
  late WebSocketChannel _channel;
  // List untuk menyimpan semua pesan yang diterima
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    // Ganti URL dengan URL server WebSocket Anda
    // Contoh URL dari gambar: 'wss://wssimple.arinov.com'
    _channel = WebSocketChannel.connect(Uri.parse('wss://wssimple.arinov.com'));

    // Mendengarkan pesan dari WebSocket
    _channel.stream.listen((event) {
      setState(() {
        // Menambahkan pesan yang diterima ke dalam list
        _messages.add(event.toString());
      });
    });
  }

  // Fungsi untuk mengirim pesan
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // Mengirim pesan ke server melalui sink (sink) channel
      _channel.sink.add(_controller.text);
      // Menghapus teks dari input setelah dikirim
      _controller.clear();
    }
  }

  @override
  void dispose() {
    // Menutup koneksi WebSocket dan controller ketika widget dibuang
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
              // Bagian untuk menampilkan daftar pesan
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    // Menampilkan setiap pesan sebagai ListTile
                    return ListTile(title: Text(_messages[index]));
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Bagian untuk input pesan
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
                onSubmitted: (_) => _sendMessage(), // Mengirim saat 'Enter'
              ),
              const SizedBox(height: 10),
              // Tombol untuk mengirim pesan (alternatif)
              // ElevatedButton(
              //   onPressed: _sendMessage,
              //   child: const Text('Kirim'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}