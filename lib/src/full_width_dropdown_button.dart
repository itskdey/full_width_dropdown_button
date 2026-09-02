import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

Color _withAlpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

/// A full-width animated dropdown with rich nested menu support.
///
/// The menu is rendered in an [Overlay], follows its trigger while scrolling,
/// and automatically flips above the trigger when there is not enough space
/// below.

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// Describes a top-level item displayed by [FullWidthDropdownButton.rich].
///
/// Items can contain custom leading widgets, nested [subItems], and an optional
/// destructive visual treatment.
class DropdownItem {
  /// Creates a rich dropdown item.
  const DropdownItem({
    required this.label,
    this.leading,
    this.subItems = const [],
    this.isDestructible = false,
  });

  /// Creates a dropdown item that only displays [label].
  factory DropdownItem.simple(String label) {
    return DropdownItem(label: label);
  }

  /// Text displayed for this item.
  final String label;

  /// Optional widget displayed before [label].
  ///
  /// This can be an [Icon], avatar, SVG widget, or any other compact widget.
  final Widget? leading;

  /// Nested actions displayed when this item is expanded.
  ///
  /// Entries can be strings or [DropdownSubItem] instances. Strings are
  /// converted to simple [DropdownSubItem] objects internally.
  final List<dynamic> subItems;

  /// Whether this item should use the destructive-action visual treatment.
  final bool isDestructible;

  /// Whether this item contains one or more nested actions.
  bool get hasSubItems => subItems.isNotEmpty;
}

/// Describes a nested action inside a [DropdownItem].
class DropdownSubItem {
  /// Creates a nested dropdown action.
  const DropdownSubItem({required this.label, this.isDestructible = false});

  /// Creates a nested action that only displays [label].
  factory DropdownSubItem.simple(String label) {
    return DropdownSubItem(label: label);
  }

  /// Text displayed for this nested action.
  final String label;

  /// Whether this nested action should use the destructive visual treatment.
  final bool isDestructible;
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

/// An animated dropdown trigger that opens a full-width overlay menu.
///
/// Use the default constructor for a flat list of strings, or
/// [FullWidthDropdownButton.rich] for leading widgets, nested sub-items, and
/// destructive actions. The overlay tracks the trigger while scrolling and
/// opens below it first, flipping above only when space is limited.
class FullWidthDropdownButton extends StatefulWidget {
  /// Creates a dropdown backed by a flat list of string [items].
  ///
  /// [onSelected] is called with the selected string. Either [child] or
  /// [iconAsset] must be provided as the trigger content.
  FullWidthDropdownButton({
    super.key,
    this.iconAsset,
    this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(14),
    this.decoration,
    this.openDecoration,
    this.iconColor,
    this.openIconColor,
    required List<String> items,
    required ValueChanged<String> onSelected,
    this.selectedItem,
    this.onClose,
  })  : assert(
          child != null || iconAsset != null,
          'Provide either child or iconAsset.',
        ),
        dropdownItems = items.map(DropdownItem.simple).toList(),
        onItemSelected = ((parent, sub) {
          onSelected(sub ?? parent);
        });

  /// Creates a dropdown using rich [dropdownItems].
  ///
  /// Use this constructor for leading widgets, nested actions, or destructive
  /// menu items. Either [child] or [iconAsset] must be provided.
  const FullWidthDropdownButton.rich({
    super.key,
    this.iconAsset,
    this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(14),
    this.decoration,
    this.openDecoration,
    required this.dropdownItems,
    required this.onItemSelected,
    this.selectedItem,
    this.onClose,
    this.iconColor,
    this.openIconColor,
  }) : assert(
          child != null || iconAsset != null,
          'Provide either child or iconAsset.',
        );

  /// Optional SVG asset path used as the trigger when [child] is not provided.
  final String? iconAsset;

  /// Items displayed in the overlay menu.
  final List<DropdownItem> dropdownItems;

  /// Called when a parent item or nested action is selected.
  ///
  /// The second argument is `null` for a parent item and contains the nested
  /// label when a sub-item is selected.
  final void Function(String parent, String? sub) onItemSelected;

  /// Optional label for the currently selected item.
  ///
  /// This value is exposed for consumers that want to keep selection state
  /// alongside the dropdown.
  final String? selectedItem;

  /// Called after an open dropdown is closed.
  final VoidCallback? onClose;

  /// Custom trigger widget.
  ///
  /// When omitted, [iconAsset] must be provided.
  final Widget? child;

  /// Padding applied around the trigger content.
  final EdgeInsetsGeometry padding;

  /// Optional trigger width.
  final double? width;

  /// Optional trigger height.
  final double? height;

  /// Decoration used while the dropdown is closed.
  final BoxDecoration? decoration;

  /// Decoration used while the dropdown is open.
  final BoxDecoration? openDecoration;

  /// Icon color used while the dropdown is closed.
  final Color? iconColor;

  /// Icon color used while the dropdown is open.
  final Color? openIconColor;

  @override
  State<FullWidthDropdownButton> createState() =>
      _FullWidthDropdownButtonState();
}

// ---------------------------------------------------------------------------
// Button state
// ---------------------------------------------------------------------------

class _FullWidthDropdownButtonState extends State<FullWidthDropdownButton>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _entry;
  bool _isOpen = false;
  bool _openAbove = false;
  double _horizontalFollowerOffset = 0;
  double _panelWidth = 0;

  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  Future<void> _toggle() async {
    HapticFeedback.lightImpact();

    await _pressController.forward();
    _pressController.reverse();

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => _isOpen = true);
    FocusScope.of(context).unfocus();
    _show();
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    setState(() => _isOpen = false);
    _hide();
    widget.onClose?.call();
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  double _estimatedPanelHeight() {
    // Only estimate the panel as it appears when it FIRST opens.
    // Submenus start collapsed, so including their height here makes the
    // dropdown flip upward much too early.
    final parentRows = widget.dropdownItems.length * 61.0;
    final dividers = widget.dropdownItems.length > 1
        ? (widget.dropdownItems.length - 1) * 1.0
        : 0.0;

    return parentRows + dividers;
  }

  void _show() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final targetOffset = box.localToGlobal(Offset.zero);
    final targetSize = box.size;
    final media = MediaQuery.of(context);

    const screenHorizontalMargin = 16.0;
    const dropdownGap = 12.0;

    _panelWidth = media.size.width - (screenHorizontalMargin * 2);

    // The follower is positioned relative to the trigger's left edge.
    // Shift it back so the dropdown always stays at 16px from screen left.
    _horizontalFollowerOffset = screenHorizontalMargin - targetOffset.dx;

    final safeBottom = media.size.height - media.padding.bottom - 8;

    final availableBelow =
        safeBottom - (targetOffset.dy + targetSize.height) - dropdownGap;

    final wantedHeight = _estimatedPanelHeight();

    // DOWN-FIRST behavior:
    // Always open below the button when the collapsed dropdown fits there.
    // Only flip above when there genuinely is not enough room below.
    _openAbove = availableBelow < wantedHeight;

    _entry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDropdown,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

            // Problem #2 fixed: this is linked to the real button instead of
            // using a one-time global Y position. If the page scrolls, the
            // dropdown follows the button automatically.
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor:
                  _openAbove ? Alignment.topLeft : Alignment.bottomLeft,
              followerAnchor:
                  _openAbove ? Alignment.bottomLeft : Alignment.topLeft,
              offset: Offset(
                _horizontalFollowerOffset,
                _openAbove ? -dropdownGap : dropdownGap,
              ),
              child: _AnimatedDropdownPanel(
                items: widget.dropdownItems,
                panelWidth: _panelWidth,
                openAbove: _openAbove,
                onSelected: (parent, sub) {
                  widget.onItemSelected(parent, sub);
                  _closeDropdown();
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedBuilder(
          animation: _pressScale,
          builder: (context, child) {
            return Transform.scale(
              scale: _pressScale.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                decoration: _isOpen
                    ? widget.openDecoration ??
                        BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: _withAlpha(Colors.black, 0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        )
                    : widget.decoration ??
                        BoxDecoration(
                          color: _withAlpha(Colors.black, 0.05),
                          borderRadius: BorderRadius.circular(100),
                        ),
                child: widget.child != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: _isOpen
                              ? widget.openIconColor ?? Colors.white
                              : widget.iconColor ?? Colors.grey,
                        ),
                        child: widget.child!,
                      )
                    : SvgPicture.asset(
                        widget.iconAsset!,
                        colorFilter: ColorFilter.mode(
                          _isOpen
                              ? widget.openIconColor ?? Colors.white
                              : widget.iconColor ?? Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated Dropdown Panel
// ---------------------------------------------------------------------------

class _AnimatedDropdownPanel extends StatefulWidget {
  const _AnimatedDropdownPanel({
    required this.items,
    required this.panelWidth,
    required this.openAbove,
    required this.onSelected,
  });

  final List<DropdownItem> items;
  final double panelWidth;
  final bool openAbove;
  final void Function(String parent, String? sub) onSelected;

  @override
  State<_AnimatedDropdownPanel> createState() => _AnimatedDropdownPanelState();
}

class _AnimatedDropdownPanelState extends State<_AnimatedDropdownPanel>
    with TickerProviderStateMixin {
  static const Color _destructibleColor = Color(0xFFE53935);

  late final AnimationController _panelController;
  late final Animation<double> _scaleY;
  late final Animation<double> _opacity;

  late final List<AnimationController> _itemControllers;
  late final List<Animation<Offset>> _itemSlide;
  late final List<Animation<double>> _itemOpacity;

  late final List<AnimationController> _subControllers;

  int? _hoveredIndex;
  int? _hoveredSubKey;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleY = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _panelController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _itemControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
      ),
    );

    _itemSlide = _itemControllers
        .map(
          (controller) => Tween<Offset>(
            begin: Offset(0, widget.openAbove ? 0.25 : -0.25),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          ),
        )
        .toList();

    _itemOpacity = _itemControllers
        .map(
          (controller) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    _subControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      ),
    );

    _panelController.forward();

    for (var i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 55), () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _panelController.dispose();

    for (final controller in _itemControllers) {
      controller.dispose();
    }

    for (final controller in _subControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  DropdownSubItem _subItemFrom(dynamic value) {
    if (value is DropdownSubItem) return value;
    return DropdownSubItem.simple(value.toString());
  }

  void _toggleExpand(int index) {
    if (!widget.items[index].hasSubItems) return;

    setState(() {
      if (_expandedIndex == index) {
        _subControllers[index].reverse();
        _expandedIndex = null;
      } else {
        if (_expandedIndex != null) {
          _subControllers[_expandedIndex!].reverse();
        }
        _expandedIndex = index;
        _subControllers[index].forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _panelController,
      builder: (context, child) {
        final alignment =
            widget.openAbove ? Alignment.bottomCenter : Alignment.topCenter;
        final dy = (widget.openAbove ? 1 : -1) * (1.0 - _scaleY.value) * 20;

        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(
              scaleX: 1.0,
              scaleY: _scaleY.value,
              alignment: alignment,
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.panelWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 12),
                color: _withAlpha(Colors.black, 0.10),
              ),
              BoxShadow(
                blurRadius: 8,
                offset: const Offset(0, 2),
                color: _withAlpha(Colors.black, 0.06),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.items.length; i++) ...[
                _buildParentItem(i),
                _buildSubPanel(i),
                if (i < widget.items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: _withAlpha(Colors.black, 0.06),
                    indent: 20,
                    endIndent: 20,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Parent item
  // ---------------------------------------------------------------------------

  Widget _buildParentItem(int i) {
    final item = widget.items[i];
    final isHovered = _hoveredIndex == i;
    final isExpanded = _expandedIndex == i;
    final isActive = isHovered || isExpanded;

    final actionColor = item.isDestructible ? _destructibleColor : Colors.black;

    return AnimatedBuilder(
      animation: _itemControllers[i],
      builder: (context, child) {
        return FadeTransition(
          opacity: _itemOpacity[i],
          child: SlideTransition(position: _itemSlide[i], child: child),
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _hoveredIndex = i);
        },
        onExit: (_) {
          setState(() => _hoveredIndex = null);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();

            if (item.hasSubItems) {
              _toggleExpand(i);
            } else {
              widget.onSelected(item.label, null);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            color: isExpanded
                ? _withAlpha(Colors.black, 0.025)
                : isHovered
                    ? _withAlpha(
                        actionColor, item.isDestructible ? 0.06 : 0.025)
                    : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                _buildLeadingBox(
                  index: i,
                  item: item,
                  isActive: isActive,
                  isDestructible: item.isDestructible,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.15,
                      color: item.isDestructible
                          ? actionColor
                          : _withAlpha(Colors.black, 0.88),
                    ),
                  ),
                ),
                if (item.hasSubItems)
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: isExpanded
                          ? 1.0
                          : isHovered
                              ? 0.8
                              : 0.42,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 21,
                        color: actionColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Leading icon / number
  // ---------------------------------------------------------------------------

  Widget _buildLeadingBox({
    required int index,
    required DropdownItem item,
    required bool isActive,
    required bool isDestructible,
  }) {
    final actionColor = isDestructible ? _destructibleColor : Colors.black;
    final foregroundColor = isActive ? Colors.white : actionColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? actionColor : _withAlpha(actionColor, 0.055),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(size: 16, color: foregroundColor),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: foregroundColor,
          ),
          child: item.leading ??
              Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Expanded sub panel
  // ---------------------------------------------------------------------------

  Widget _buildSubPanel(int parentIndex) {
    final item = widget.items[parentIndex];

    if (!item.hasSubItems) {
      return const SizedBox.shrink();
    }

    final totalCount = item.subItems.length;
    final sizeFactor = CurvedAnimation(
      parent: _subControllers[parentIndex],
      curve: Curves.easeInOutCubic,
    );

    return AnimatedBuilder(
      animation: sizeFactor,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _subControllers[parentIndex],
          curve: Curves.easeOut,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 18,
            bottom: 8,
            top: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var j = 0; j < totalCount; j++)
                _buildThreadSubItem(
                  parentIndex: parentIndex,
                  subIndex: j,
                  totalCount: totalCount,
                  subItem: _subItemFrom(item.subItems[j]),
                ),
            ],
          ),
        ),
      ),
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: sizeFactor.value,
            child: child,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Thread-style sub item
  // ---------------------------------------------------------------------------

  Widget _buildThreadSubItem({
    required int parentIndex,
    required int subIndex,
    required int totalCount,
    required DropdownSubItem subItem,
  }) {
    final hoverKey = parentIndex * 1000 + subIndex;
    final isHovered = _hoveredSubKey == hoverKey;

    final actionColor =
        subItem.isDestructible ? _destructibleColor : Colors.black;

    final isFirst = subIndex == 0;
    final isLast = subIndex == totalCount - 1;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredSubKey = hoverKey);
      },
      onExit: (_) {
        setState(() => _hoveredSubKey = null);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onSelected(widget.items[parentIndex].label, subItem.label);
        },
        child: SizedBox(
          height: 52,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 52,
                child: CustomPaint(
                  painter: _ThreadReplyConnectorPainter(
                    isFirst: isFirst,
                    isLast: isLast,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? _withAlpha(
                            actionColor,
                            subItem.isDestructible ? 0.07 : 0.035,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          subItem.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                                isHovered ? FontWeight.w600 : FontWeight.w500,
                            color: subItem.isDestructible
                                ? _withAlpha(
                                    actionColor,
                                    isHovered ? 1.0 : 0.80,
                                  )
                                : _withAlpha(
                                    Colors.black,
                                    isHovered ? 0.90 : 0.58,
                                  ),
                          ),
                        ),
                      ),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        offset: isHovered ? Offset.zero : const Offset(0.25, 0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: isHovered ? 1.0 : 0.0,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: _withAlpha(actionColor, 0.65),
                          ),
                        ),
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Thread-style curved submenu connector
// ---------------------------------------------------------------------------

class _ThreadReplyConnectorPainter extends CustomPainter {
  const _ThreadReplyConnectorPainter({
    required this.isFirst,
    required this.isLast,
  });

  final bool isFirst;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFD8D8D8);
    const strokeWidth = 1.5;

    // Parent item: left padding 20 + 30px icon / 2 = x 35.
    // Sub panel: left padding 20 + trunkX 15 = x 35.
    // So this spine is exactly centered below the black leading box.
    const trunkX = 15.0;

    const nodeRadius = 3.2;
    const holeRadius = 1.2;
    const startNodeY = 6.0;

    // Each sub item is exactly 52px tall, and its text is vertically centered.
    // Therefore the branch node and text share the same center line.
    final branchY = size.height / 2;
    final endX = size.width - 3.5;

    const radius = 8.0;
    final curveStartY = branchY - radius;
    final curveEndX = trunkX + radius;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Vertical spine.
    canvas.drawLine(
      Offset(trunkX, isFirst ? startNodeY : 0),
      Offset(trunkX, isLast ? curveStartY : size.height),
      linePaint,
    );

    // Exact quarter-circle style bend into the sub-item center.
    const kappa = 0.5522847498;

    final path = Path()
      ..moveTo(trunkX, curveStartY)
      ..cubicTo(
        trunkX,
        curveStartY + radius * kappa,
        curveEndX - radius * kappa,
        branchY,
        curveEndX,
        branchY,
      )
      ..lineTo(endX, branchY);

    canvas.drawPath(path, linePaint);

    if (isFirst) {
      canvas.drawCircle(
        const Offset(trunkX, startNodeY),
        nodeRadius,
        nodePaint,
      );
      canvas.drawCircle(
        const Offset(trunkX, startNodeY),
        holeRadius,
        holePaint,
      );
    }

    canvas.drawCircle(Offset(endX, branchY), nodeRadius, nodePaint);
    canvas.drawCircle(Offset(endX, branchY), holeRadius, holePaint);
  }

  @override
  bool shouldRepaint(covariant _ThreadReplyConnectorPainter oldDelegate) {
    return oldDelegate.isFirst != isFirst || oldDelegate.isLast != isLast;
  }
}
