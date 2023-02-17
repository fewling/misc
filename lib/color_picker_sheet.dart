import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misc/providers.dart';

class ColorPickerSheet extends ConsumerWidget {
  const ColorPickerSheet(this.scrollController, {required this.onColorSelected, super.key});
  final ScrollController scrollController;

  final void Function(int colorCode) onColorSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorSeed = ref.watch(colorSchemeProvider);

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Opacity(
              opacity: 0.4,
              child: Align(
                child: Container(
                  color: colorScheme.onSurfaceVariant,
                  width: 32,
                  height: 4,
                ),
              ),
            ),
          ),
        ),
        SliverGrid.builder(
          itemCount: Colors.primaries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (_, index) {
            final color = Colors.primaries[index % Colors.primaries.length];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Material(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => onColorSelected(color.value),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  if (colorSeed.value == color.value)
                    const Positioned.fill(child: Icon(Icons.check))
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
