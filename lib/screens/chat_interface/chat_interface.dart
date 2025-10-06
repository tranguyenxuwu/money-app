import 'package:flutter/material.dart';

/// Màn hình UI dựng từ Figma — phiên bản responsive
class ChatInterfaceScreen extends StatelessWidget {
  const ChatInterfaceScreen({super.key});

  // Kích thước gốc của artboard Figma bạn gửi (dùng để tính tỉ lệ)
  static const double _designW = 361;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            // Scale theo bề ngang so với Figma
            final scale = (screenW / _designW).clamp(0.7, 1.6);

            // Helper để nhân tỉ lệ nhanh
            double r(double v) => v * scale;

            // Giữ UI nằm giữa + không quá rộng trên tablet
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: EdgeInsets.all(r(12)),
                  child: _FigmaResponsiveCard(r),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Thẻ UI chính (bo góc + viền) — mọi kích thước tính bằng r(...)
class _FigmaResponsiveCard extends StatelessWidget {
  final double Function(double) r;
  const _FigmaResponsiveCard(this.r);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Không đặt width/height cứng — để nó giãn theo parent
      decoration: ShapeDecoration(
        color: const Color(0xFFFEF7FF), // Schemes-Surface
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r(28)),
          side: BorderSide(
            width: r(8),
            color: const Color(0xFFCAC4D0), // Outline-Variant
            // strokeAlignOutside có thể gây warning trên 1 số SDK — bỏ cho an toàn
          ),
        ),
      ),
      child: Column(
        children: [
          // ===== Top status / header (mock) =====
          SizedBox(
            height: r(52),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r(24), vertical: r(10)),
              child: Row(
                children: [
                  Text(
                    '9:30',
                    style: TextStyle(
                      color: const Color(0xFF1D1B20),
                      fontSize: r(14),
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                      letterSpacing: 0.14,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.signal_cellular_alt, size: r(16), color: const Color(0xFF1D1B20)),
                  SizedBox(width: r(8)),
                  Icon(Icons.wifi, size: r(16), color: const Color(0xFF1D1B20)),
                  SizedBox(width: r(8)),
                  Icon(Icons.battery_full, size: r(16), color: const Color(0xFF1D1B20)),
                ],
              ),
            ),
          ),

          // ===== Tab bar =====
          SizedBox(
            height: r(48),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _TabItem(
                        r: r,
                        label: 'Video',
                        active: true,
                      ),
                      _TabItem(r: r, label: 'Photos'),
                      _TabItem(r: r, label: 'Audio'),
                    ],
                  ),
                ),
                Divider(
                  height: r(1),
                  thickness: r(1),
                  color: const Color(0xFFCAC4D0),
                ),
              ],
            ),
          ),

          // ===== Content area: dùng Expanded để tự giãn theo chiều cao =====
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r(12), vertical: r(12)),
              child: _MessageListPlaceholder(r: r),
            ),
          ),

          // ===== Bottom input bar (TextField thật, responsive) =====
          Padding(
            padding: EdgeInsets.fromLTRB(r(12), 0, r(12), r(12)),
            child: Container(
              height: r(56),
              decoration: ShapeDecoration(
                color: const Color(0xFFECE6F0), // Surface-Container-High
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: r(1), color: const Color(0x33000000)),
                  borderRadius: BorderRadius.circular(r(28)),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: r(16)),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration.collapsed(
                        hintText: 'Hinted search text',
                        hintStyle: TextStyle(
                          color: const Color(0xFF49454F),
                          fontSize: r(16),
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: TextStyle(fontSize: r(16)),
                    ),
                  ),
                  SizedBox(width: r(4)),
                  SizedBox(
                    width: r(56),
                    height: r(56),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.send, size: r(22)),
                      splashRadius: r(28),
                      color: const Color(0xFF6750A4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một ô tab (Video/Photos/Audio)
class _TabItem extends StatelessWidget {
  final double Function(double) r;
  final String label;
  final bool active;
  const _TabItem({required this.r, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: r(14)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? const Color(0xFF6750A4) : const Color(0xFF49454F),
                    fontSize: r(14),
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    letterSpacing: 0.10,
                  ),
                ),
              ),
              if (active)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -r(3),
                  child: Center(
                    child: Container(
                      width: r(32),
                      height: r(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6750A4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder danh sách tin nhắn (để bạn thay bằng ListView sau này)
class _MessageListPlaceholder extends StatelessWidget {
  final double Function(double) r;
  const _MessageListPlaceholder({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      // chỉ để dễ nhìn — có thể bỏ
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r(16)),
        color: const Color(0xFFF7F2FA),
      ),
      child: ListView.separated(
        padding: EdgeInsets.all(r(12)),
        itemCount: 8,
        separatorBuilder: (_, __) => SizedBox(height: r(8)),
        itemBuilder: (_, i) {
          final isMe = i.isEven;
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: r(12), vertical: r(8)),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF6750A4) : const Color(0xFFE8DEF8),
                borderRadius: BorderRadius.circular(r(12)),
              ),
              child: Text(
                isMe ? 'Tin nhắn của tôi $i' : 'Tin nhắn của bot $i',
                style: TextStyle(
                  color: isMe ? Colors.white : const Color(0xFF1D1B20),
                  fontSize: r(14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}