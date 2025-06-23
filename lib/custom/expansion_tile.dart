import 'package:flutter/material.dart';

/// A custom expansion tile that uses ListView.builder for its children
class ListExpansionTile extends StatefulWidget {
  /// Creates a [ListExpansionTile].
  const ListExpansionTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.textColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.shape,
    this.collapsedShape,
    this.clipBehavior,
    this.controlAffinity,
    this.trailing,
    this.childCount = 0,
    required this.builder,
    this.listPadding = EdgeInsets.zero,
    this.header,
    this.physics,
    this.shrinkWrap = true,
    this.maxListHeight,
    this.scrollController,
  });

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the list tile.
  final Widget title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// Called when the tile expands or collapses.
  final ValueChanged<bool>? onExpansionChanged;

  /// Whether the tile is initially expanded.
  final bool initiallyExpanded;

  /// Whether the state of the children is maintained when the tile expands and collapses.
  final bool maintainState;

  /// Specifies padding for the [ListTile].
  final EdgeInsetsGeometry? tilePadding;

  /// Specifies the alignment of [children], which are arranged in a column when
  /// the tile is expanded.
  final CrossAxisAlignment? expandedCrossAxisAlignment;

  /// Specifies the alignment of [children] within the main axis.
  final Alignment? expandedAlignment;

  /// Specifies padding for [children].
  final EdgeInsetsGeometry? childrenPadding;

  /// The color to display behind the sublist when expanded.
  final Color? backgroundColor;

  /// The color to display behind the sublist when collapsed.
  final Color? collapsedBackgroundColor;

  /// The color of the tile's titles when the sublist is expanded.
  final Color? textColor;

  /// The color of the tile's titles when the sublist is collapsed.
  final Color? collapsedTextColor;

  /// The color of the expansion arrow icon.
  final Color? iconColor;

  /// The color of the expansion arrow icon when the sublist is collapsed.
  final Color? collapsedIconColor;

  /// The shape of the expansion tile when it is expanded.
  final ShapeBorder? shape;

  /// The shape of the expansion tile when it is collapsed.
  final ShapeBorder? collapsedShape;

  /// The clip behavior used by the expansion tile.
  final Clip? clipBehavior;

  /// Typically used to force the expansion arrow icon to the tile's leading or trailing edge.
  final ListTileControlAffinity? controlAffinity;

  /// A widget to display after the title.
  final Widget? trailing;

  /// The number of children to be built using the [builder].
  final int childCount;

  /// A builder function to create children widgets.
  final IndexedWidgetBuilder builder;

  /// Optional padding for the ListView.
  final EdgeInsetsGeometry listPadding;

  /// Optional header widget to display above the ListView.
  final Widget? header;

  /// The physics of the ListView.
  final ScrollPhysics? physics;

  /// Whether the ListView should shrink wrap its contents.
  final bool shrinkWrap;

  /// Optional maximum height for the ListView. If null, ListView will use shrinkWrap.
  final double? maxListHeight;

  /// Optional ScrollController to be attached to the ListView.
  final ScrollController? scrollController;

  @override
  State<ListExpansionTile> createState() => _ListExpansionTileState();
}

class _ListExpansionTileState extends State<ListExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween = CurveTween(
    curve: Curves.easeIn,
  );
  static final Animatable<double> _halfTween = Tween<double>(
    begin: 0.0,
    end: 0.5,
  );

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));

    // Try to read the expanded state from PageStorage, or use the initiallyExpanded value
    _isExpanded = widget.initiallyExpanded;
    try {
      _isExpanded =
          PageStorage.of(context).readState(context) as bool? ??
          widget.initiallyExpanded;
    } catch (e) {
      // PageStorage might not be available in initState
      _isExpanded = widget.initiallyExpanded;
    }

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe place to access PageStorage
    if ((PageStorage.of(context).readState(context) as bool?) != null) {
      _isExpanded =
          PageStorage.of(context).readState(context) as bool? ??
          widget.initiallyExpanded;
      if (_isExpanded) {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  // Build the expandable content only when needed
  Widget? _buildExpandableContent() {
    final bool closed = !_isExpanded && _controller.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;

    if (shouldRemoveChildren) {
      return null;
    }

    Widget listView = ListView.builder(
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.listPadding,
      itemCount: widget.childCount,
      itemBuilder: widget.builder,
    );

    // If maxListHeight is provided, constrain the ListView height
    if (widget.maxListHeight != null) {
      listView = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxListHeight!),
        child: listView,
      );
    }

    return Padding(
      padding: widget.childrenPadding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment:
            widget.expandedCrossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [if (widget.header != null) widget.header!, listView],
      ),
    );
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final ShapeBorder effectiveShape =
        _isExpanded
            ? widget.shape ?? const RoundedRectangleBorder()
            : widget.collapsedShape ?? const RoundedRectangleBorder();

    return Container(
      clipBehavior: widget.clipBehavior ?? Clip.none,
      decoration: ShapeDecoration(
        color:
            _isExpanded
                ? widget.backgroundColor
                : widget.collapsedBackgroundColor,
        shape: effectiveShape,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor:
                _isExpanded ? widget.iconColor : widget.collapsedIconColor,
            textColor:
                _isExpanded ? widget.textColor : widget.collapsedTextColor,
            child: ListTile(
              onTap: _handleTap,
              contentPadding: widget.tilePadding,
              leading: widget.leading,
              title: widget.title,
              subtitle: widget.subtitle,
              trailing:
                  widget.trailing ??
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.expand_more),
                  ),
            ),
            controlAffinity: widget.controlAffinity,
          ),
          ClipRect(
            child: Align(
              alignment: widget.expandedAlignment ?? Alignment.center,
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget? expandableContent = _buildExpandableContent();

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child:
          expandableContent != null
              ? Offstage(
                offstage: !_isExpanded && _controller.isDismissed,
                child: TickerMode(
                  enabled: _isExpanded,
                  child: expandableContent,
                ),
              )
              : null,
    );
  }
}
