import 'package:flutter/material.dart';

import '../models/game_credit.dart';
import '../theme/app_theme.dart';

/// Shows a product's asset image, or a generated platform card when the
/// product (added in Supabase) has no image of its own.
class CreditImage extends StatelessWidget {
  final GameCredit credit;
  final BoxFit fit;

  const CreditImage({
    super.key,
    required this.credit,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final image = credit.image;

    if (image != null && image.isNotEmpty) {
      return Image.asset(
        image,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _Placeholder(credit),
      );
    }

    return _Placeholder(credit);
  }
}

class _Placeholder extends StatelessWidget {
  final GameCredit credit;

  const _Placeholder(this.credit);

  @override
  Widget build(BuildContext context) {
    final isSteam = credit.platform == 'Steam';

    final colors = isSteam
        ? const [AppTheme.steamDark, AppTheme.steamBlue]
        : const [AppTheme.valorantDark, AppTheme.valorantRed];

    // Short label: "₱2000" for Steam, "3650 VP" for Valorant.
    final label = isSteam
        ? credit.title.replaceAll('Steam Wallet', '').trim()
        : '${credit.title.split(' ').first} VP';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSteam
                      ? Icons.sports_esports_rounded
                      : Icons.diamond_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  credit.platform.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
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
