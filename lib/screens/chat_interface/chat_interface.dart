import 'package:flutter/material.dart';

/// Chat UI dựng lại theo Material 3 (ít custom nhất có thể)
class ChatInterfaceScreen extends StatefulWidget {
  const ChatInterfaceScreen({super.key});

  @override
  State<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends State<ChatInterfaceScreen> {
  final TextEditingController _controller = TextEditingController();

  // Danh sách tin nhắn với thông tin chi tiết
  final List<Map<String, dynamic>> _messages = List.generate(
    15,
    (i) => i.isEven
        ? {'isMe': true, 'text': 'Tin nhắn của tôi $i'}
        : {
            'isMe': false,
            'action': 'Tạo ảnh',
            'info': 'Đang xử lý yêu cầu của bạn...',
            'result': 'Ảnh đã được tạo thành công với prompt: "A beautiful sunset"',
          },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'isMe': true, 'text': text});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: 'Main'),
              Tab(text: 'Tab 1'),
              Tab(text: 'Tab 2'),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          children: [
                            _MessagesPane(messages: _messages),
                            const Center(child: Text('Tab 1')),
                            const Center(child: Text('Tab 2')),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _send(),
                                decoration: InputDecoration(
                                  hintText: 'Nhập tin nhắn...',
                                  isDense: true,
                                  filled: true,
                                  fillColor: scheme.surfaceContainerHigh,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: _send,
                                    icon: const Icon(Icons.send),
                                    tooltip: 'Gửi',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget hiển thị danh sách tin nhắn
class _MessagesPane extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  const _MessagesPane({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final msg = messages[i];
        final isMe = msg['isMe'] as bool;

        if (isMe) {
          return _UserMessageBubble(text: msg['text'] as String);
        } else {
          return _BotActionCard(
            action: msg['action'] as String,
            info: msg['info'] as String,
            result: msg['result'] as String,
          );
        }
      },
    );
  }
}

/// Bubble tin nhắn của người dùng
class _UserMessageBubble extends StatelessWidget {
  final String text;
  const _UserMessageBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          color: scheme.primary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              text,
              style: TextStyle(color: scheme.onPrimary, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card hành động của bot
class _BotActionCard extends StatelessWidget {
  final String action;
  final String info;
  final String result;

  const _BotActionCard({
    required this.action,
    required this.info,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          color: scheme.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề hành động
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 20, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      action,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Thông tin
                Text(
                  info,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 8),

                // Divider
                Divider(color: scheme.outlineVariant, height: 1),
                const SizedBox(height: 8),

                // Kết quả
                Text(
                  result,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}