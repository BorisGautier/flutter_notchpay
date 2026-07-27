import 'package:flutter/material.dart';

import '../../models/notchpay_channel.dart';

/// A small colored badge representing a payment channel (MTN, Orange,
/// Card, ...).
///
/// Drawn entirely with [Icon]s and solid colors rather than bundled
/// trademarked logos, so the package stays lightweight and legally simple
/// to distribute while still giving each channel an instantly recognizable
/// identity.
class NotchPayChannelBadge extends StatelessWidget {
  /// Creates a badge for the given channel [kind], [size] pixels wide/tall.
  const NotchPayChannelBadge({super.key, required this.kind, this.size = 40});

  /// Which channel family to represent.
  final NotchPayChannelKind kind;

  /// The width and height of the badge, in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (kind) {
      NotchPayChannelKind.mtn => 'assets/momo.jpg',
      NotchPayChannelKind.orange => 'assets/om.png',
      NotchPayChannelKind.yoomee => 'assets/yoomee.png',
      NotchPayChannelKind.moov => 'assets/moov.png',
      NotchPayChannelKind.airtel => 'assets/airtel.png',
      NotchPayChannelKind.vodafone => 'assets/vodafone.png',
      NotchPayChannelKind.mpesa => 'assets/mpesa.png',
      NotchPayChannelKind.free => 'assets/free.png',
      NotchPayChannelKind.glo => 'assets/glo.png',
      NotchPayChannelKind.tigo => 'assets/tigo.png',
      _ => null,
    };

    final fallback = _buildFallback(context);

    if (assetPath == null) return fallback;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Image.asset(
        assetPath,
        package: 'flutter_notchpay',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final style = _styleFor(kind);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: style.label != null
          ? Text(
              style.label!,
              style: TextStyle(
                color: style.foreground,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.34,
                letterSpacing: -0.5,
              ),
            )
          : Icon(style.icon, color: style.foreground, size: size * 0.55),
    );
  }

  _BadgeStyle _styleFor(NotchPayChannelKind kind) {
    return switch (kind) {
      NotchPayChannelKind.mtn => const _BadgeStyle(
          background: Color(0xFFFFCC00),
          foreground: Color(0xFF1A1A1A),
          label: 'MTN',
        ),
      NotchPayChannelKind.orange => const _BadgeStyle(
          background: Color(0xFFFF6600),
          foreground: Colors.white,
          label: 'OM',
        ),
      NotchPayChannelKind.yoomee => const _BadgeStyle(
          background: Color(0xFFE20074),
          foreground: Colors.white,
          label: 'YM',
        ),
      NotchPayChannelKind.moov => const _BadgeStyle(
          background: Color(0xFF005CA9),
          foreground: Colors.white,
          label: 'MOOV',
        ),
      NotchPayChannelKind.wave => const _BadgeStyle(
          background: Color(0xFF1DC3F4),
          foreground: Colors.white,
          label: 'WAVE',
        ),
      NotchPayChannelKind.airtel => const _BadgeStyle(
          background: Color(0xFFE2001A),
          foreground: Colors.white,
          label: 'AIRTEL',
        ),
      NotchPayChannelKind.vodafone => const _BadgeStyle(
          background: Color(0xFFE60000),
          foreground: Colors.white,
          label: 'VODA',
        ),
      NotchPayChannelKind.mpesa => const _BadgeStyle(
          background: Color(0xFF4CAF50),
          foreground: Colors.white,
          label: 'MPESA',
        ),
      NotchPayChannelKind.free => const _BadgeStyle(
          background: Color(0xFFE2001A),
          foreground: Colors.white,
          label: 'FREE',
        ),
      NotchPayChannelKind.eumm => const _BadgeStyle(
          background: Color(0xFF008000),
          foreground: Colors.white,
          label: 'EU',
        ),
      NotchPayChannelKind.glo => const _BadgeStyle(
          background: Color(0xFF43B02A),
          foreground: Colors.white,
          label: 'GLO',
        ),
      NotchPayChannelKind.tigo => const _BadgeStyle(
          background: Color(0xFF002A54),
          foreground: Colors.white,
          label: 'TIGO',
        ),
      NotchPayChannelKind.halopesa => const _BadgeStyle(
          background: Color(0xFFFF6600),
          foreground: Colors.white,
          label: 'HALO',
        ),
      NotchPayChannelKind.equitel => const _BadgeStyle(
          background: Color(0xFF7A1C1C),
          foreground: Colors.white,
          label: 'EQUI',
        ),
      NotchPayChannelKind.tkash => const _BadgeStyle(
          background: Color(0xFF0089CF),
          foreground: Colors.white,
          label: 'TKASH',
        ),
      NotchPayChannelKind.green => const _BadgeStyle(
          background: Color(0xFF10B981),
          foreground: Colors.white,
          label: 'GREEN',
        ),
      NotchPayChannelKind.mobileMoney => const _BadgeStyle(
          background: Color(0xFF0EA5E9),
          foreground: Colors.white,
          icon: Icons.phone_iphone_rounded,
        ),
      NotchPayChannelKind.card => const _BadgeStyle(
          background: Color(0xFF6366F1),
          foreground: Colors.white,
          icon: Icons.credit_card_rounded,
        ),
      NotchPayChannelKind.bank => const _BadgeStyle(
          background: Color(0xFF0F766E),
          foreground: Colors.white,
          icon: Icons.account_balance_rounded,
        ),
      NotchPayChannelKind.other => const _BadgeStyle(
          background: Color(0xFF6B7280),
          foreground: Colors.white,
          icon: Icons.payments_rounded,
        ),
    };
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.background,
    required this.foreground,
    this.icon,
    this.label,
  });

  final Color background;
  final Color foreground;
  final IconData? icon;
  final String? label;
}
