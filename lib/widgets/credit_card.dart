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
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                credit.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                credit.title,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                '₱${credit.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}