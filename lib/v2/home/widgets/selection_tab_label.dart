import 'package:flutter/material.dart';
import 'selection_indicator_width.dart';

/// Centers the indicator against the label's actual laid-out bounds.
class SelectionTabLabel extends StatelessWidget {
  const SelectionTabLabel(
      {super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final style = DefaultTextStyle.of(context).style.merge(TextStyle(
          color: selected
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: .62),
          fontWeight: FontWeight.w700,
        ));
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 32),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: style),
          ),
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selectionIndicatorWidth(context, label, style),
              height: 3,
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: dark
                            ? const [Color(0xFF12D6DF), Color(0xFFF70FFF)]
                            : const [Color(0xFF00FFED), Color(0xFF9D00C6)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
