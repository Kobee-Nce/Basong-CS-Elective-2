import 'package:flutter/material.dart';

import '../state/products_controller.dart';

/// Price range slider. Dragging only updates the labels (previewRange);
/// the Supabase query runs once the thumb is released (applyRange).
class PriceFilterPanel extends StatelessWidget {
  final ProductsController controller;

  const PriceFilterPanel({super.key, required this.controller});

  static String peso(double value) => '₱${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final range = controller.selectedRange;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Price',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${peso(range.start)} – ${peso(range.end)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              if (controller.isFiltered)
                TextButton(
                  onPressed: controller.resetFilter,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset'),
                ),
            ],
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              valueIndicatorColor: Colors.black87,
              // Hide the tick marks of the ₱50 steps.
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: RangeSlider(
              min: controller.minPrice,
              max: controller.maxPrice,
              divisions: controller.sliderDivisions,
              values: range,
              labels: RangeLabels(peso(range.start), peso(range.end)),
              onChanged: controller.previewRange,
              onChangeEnd: controller.applyRange,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 6),
            child: Row(
              children: [
                Text(
                  peso(controller.minPrice),
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  peso(controller.maxPrice),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
