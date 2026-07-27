import 'package:flutter/material.dart';

import '../../models/notchpay_channel.dart';
import '../theme/notchpay_theme.dart';
import 'notchpay_channel_badge.dart';

/// A selectable grid of [NotchPayChannel]s, shown as the first step of the
/// checkout sheet.
class NotchPayChannelGrid extends StatelessWidget {
  /// Creates a grid listing [channels], calling [onSelected] when the
  /// customer taps one.
  const NotchPayChannelGrid({
    super.key,
    required this.channels,
    required this.onSelected,
  });

  /// The channels to display, in order.
  final List<NotchPayChannel> channels;

  /// Called with the tapped channel.
  final ValueChanged<NotchPayChannel> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: channels.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return _ChannelTile(
          channel: channel,
          theme: theme,
          onTap: () => onSelected(channel),
        );
      },
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile(
      {required this.channel, required this.theme, required this.onTap});

  final NotchPayChannel channel;
  final NotchPayThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.borderRadius * 0.6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
                color:
                    (theme.mutedColor ?? Colors.grey).withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(theme.borderRadius * 0.6),
          ),
          child: Row(
            children: [
              NotchPayChannelBadge(kind: channel.kind),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  channel.name.isEmpty ? channel.code : channel.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.onSurfaceColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}
