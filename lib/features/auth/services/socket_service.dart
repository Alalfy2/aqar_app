
import 'package:aqar_app/models/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  IO.Socket get socket => _socket!;

  void connectAndListen() {
    // 'http://10.0.2.2:3001' محاكي أندرويد
    _socket = IO.io('http://localhost:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false, 
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Flutter: Connected to Socket.IO Server');
    });

    _socket!.onDisconnect((_) => print('❌ Flutter: Disconnected'));
  }

  void joinRoom(int chatId) {
    _socket?.emit('join_room', chatId.toString());
  }

  void sendMessage({
    required int chatId,
    required int senderId,
    required String content,
  }) {
    _socket?.emit('send_message', {
      'chatId': chatId.toString(),
      'senderId': senderId,
      'content': content,
    });
  }

  void listenForNewMessages(Function(MessageModel) onNewMessage) {
    _socket?.on('new_message', (data) {
      print("New message received from server: $data");
      onNewMessage(MessageModel.fromJson(data));
    });
  }

  void dispose() {
    _socket?.dispose();
  }
}