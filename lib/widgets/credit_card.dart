import 'package:flutter/material.dart';

import '../models/game_credit.dart';

class CreditCard extends StatelessWidget {
  final GameCredit credit;
  final VoidCallback onTap;

  const CreditCard({
    super.key,
    required this.credit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSteam = credit.platform == 'Steam';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: credit.id,
                      child: Container(
                        color: Colors.black12,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            credit.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSteam
                            ? const Color(0xFF00ADFF)
                            : const Color(0xFFFF4654),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        credit.platform,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                credit.title,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                '₱${credit.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isSteam
                      ? const Color(0xFF00ADFF)
                      : const Color(0xFFFF4654),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}