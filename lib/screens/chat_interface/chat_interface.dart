import 'package:flutter/material.dart';
import 'chat_functions.dart';

/// Màn hình giao diện chat
class ChatInterfaceScreen extends StatefulWidget {
  const ChatInterfaceScreen({super.key});

  @override
  State<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

/// Trạng thái của màn hình chat
class _ChatInterfaceScreenState extends State<ChatInterfaceScreen> {
  final TextEditingController _controller = TextEditingController();

  /// Danh sách tin nhắn với thông tin chi tiết
  List<Map<String, dynamic>> _messages = [];

  /// Biến điều khiển hiển thị tin nhắn mẫu
  bool _showPreloaded = false;

  // Scroll controller to keep view pinned to newest message
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final loadedMessages = await getInitialMessages();
    setState(() {
      _messages = loadedMessages;
    });
    // ensure we scroll to the bottom after the first frame (newest messages visible)
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Phương thức gửi tin nhắn
  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await sendMessage(
      _messages,
      text,
      setState,
      mounted,
      onMessageAdded: _scrollToBottom,
    );
    _controller.clear();
  }

  /// Xây dựng giao diện
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: Colors.green),
        ),
        child: Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            toolbarHeight: 5.0,
            actions: [],
            // bottom: const TabBar(
            //   isScrollable: false,
            //   // tabs: [
            //   //   Tab(text: 'Main'),
            //   //   Tab(text: 'Tab 1'),
            //   //   Tab(text: 'Tab 2'),
            //   // ],
            // ),
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
                              _MessagesPane(
                                messages: _messages,
                                showPreloaded: _showPreloaded,
                                scrollController:
                                    _scrollController, // pass controller down
                              ),
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
      ),
    );
  }
}

/// Widget hiển thị danh sách tin nhắn
class _MessagesPane extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final bool showPreloaded;
  final ScrollController? scrollController;

  const _MessagesPane({
    required this.messages,
    required this.showPreloaded,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final filteredMessages = filterMessages(messages, showPreloaded);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      reverse: false, // keep chronological; UI scrolls to the bottom
      itemCount: filteredMessages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final msg = filteredMessages[i];
        final isMe = msg['isMe'] as bool;

        if (isMe) {
          return _UserMessageBubble(text: msg['text'] as String? ?? 'Unknown');
        } else if (msg['action'] != null) {
          return _BotActionCard(
            action: msg['action'] as String? ?? 'Unknown',
            info: msg['info'] as String? ?? 'Unknown',
            result: msg['result'] as String? ?? 'Unknown',
            direction:
                msg['direction']
                    as String?, // ensure arrow/direction shows correctly
          );
        } else {
          return _BotMessageBubble(text: msg['text'] as String? ?? 'Unknown');
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
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                text,
                style: TextStyle(color: scheme.onPrimary, fontSize: 14),
              ),
            ),
            Positioned(
              right: -8,
              top: 10,
              child: ClipPath(
                clipper: _BubbleTailClipper(),
                child: Container(width: 8, height: 8, color: scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card hành động của bot
class _BotActionCard extends StatelessWidget {
  final String
  action; // This will now hold the transaction type (e.g., "ăn uống", "di chuyển")
  final String info;
  final String result;
  final String? direction;

  const _BotActionCard({
    required this.action,
    required this.info,
    required this.result,
    this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIncome = direction == 'in';

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction type (e.g., "ăn uống", "di chuyển")
                  Row(
                    children: [
                      Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 20,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        action, // Display the guessed transaction type
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Transaction details
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

                  // Result
                  Text(
                    result,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: -8,
              top: 10,
              child: ClipPath(
                clipper: _BubbleTailClipper(),
                child: Container(
                  width: 8,
                  height: 8,
                  color: scheme.surfaceContainerLow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bubble tin nhắn của bot
class _BotMessageBubble extends StatelessWidget {
  final String text;
  const _BotMessageBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                text,
                style: TextStyle(color: scheme.onSurface, fontSize: 14),
              ),
            ),
            Positioned(
              left: -8,
              top: 10,
              child: ClipPath(
                clipper: _BubbleTailClipper(),
                child: Container(
                  width: 8,
                  height: 8,
                  color: scheme.surfaceContainerLow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom clipper for chat bubble tail
class _BubbleTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
