import 'package:aqar_app/features/auth/services/socket_service.dart';
import 'package:aqar_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../../models/message_model.dart';


class ChatScreen extends StatefulWidget {
  final int chatId;
  final int currentUserId;
  final int offerId; 
  final String currentUserRole; 

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.offerId,
    required this.currentUserRole, 
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _socketService.connectAndListen();
    _socketService.socket.onConnect((_) {
      _socketService.joinRoom(widget.chatId);
      _socketService.listenForNewMessages((newMessage) {
        if (mounted) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        }
      });
    });
  }

  @override
  void dispose() {
    _socketService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final messageContent = _messageController.text;
      _socketService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        content: messageContent,
      );
      setState(() {
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch,
          chatId: widget.chatId,
          senderId: widget.currentUserId,
          content: messageContent,
          createdAt: DateTime.now(),
        ));
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showRequestClosureDialog(BuildContext context) {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('طلب إغلاق الصفقة'),
          content: TextField(
            controller: priceController,
            decoration: const InputDecoration(labelText: 'السعر النهائي (اختياري)'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = await _storage.read(key: 'jwt_token');
                if (token == null || !mounted) return;
                
                final response = await _apiService.requestDealClosure(
                  token: token,
                  offerId: widget.offerId,
                  finalPrice: double.tryParse(priceController.text),
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال طلب إغلاق الصفقة بنجاح!')),
                    );
                  } else {
                     final error = response.data?['error'] ?? 'فشل إرسال الطلب.';
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                }
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المحادثة للطلب رقم ${widget.chatId}'),
        actions: [
          if (widget.currentUserRole == 'agent')
            IconButton(
              icon: const Icon(Icons.handshake),
              onPressed: () => _showRequestClosureDialog(context),
              tooltip: 'طلب إغلاق الصفقة',
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message.senderId == widget.currentUserId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}