part of '../flutter_advanced_drawer.dart';

/// AdvancedDrawer widget.
class AdvancedDrawer extends StatefulWidget {
  const AdvancedDrawer({
    Key? key,
    required this.child,
    required this.drawer,
    this.controller,
    this.backdropColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve,
    this.childDecoration,
    this.animateChildDecoration = true,
    this.rtlOpening = false,
    this.disabledGestures = false,
  }) : super(key: key);

  /// Child widget. (Usually widget that represent a screen)
  final Widget child;

  /// Drawer widget. (Widget behind the [child]).
  final Widget drawer;

  /// Controller that controls widget state.
  final AdvancedDrawerController? controller;

  /// Backdrop color.
  final Color? backdropColor;

  /// Animation duration.
  final Duration animationDuration;

  /// Animation curve.
  final Curve? animationCurve;

  /// Child container decoration in open widget state.
  final BoxDecoration? childDecoration;

  /// Indicates that [childDecoration] might be animated or not.
  /// NOTICE: It may cause animation jerks.
  final bool animateChildDecoration;

  /// Opening from Right-to-left.
  final bool rtlOpening;

  /// Disable gestures.
  final bool disabledGestures;

  @override
  _AdvancedDrawerState createState() => _AdvancedDrawerState();
}

class _AdvancedDrawerState extends State<AdvancedDrawer> with SingleTickerProviderStateMixin {
  late final AdvancedDrawerController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _parentAnimation;
  late final Animation<double> _drawerScaleAnimation;
  late final Animation<double> _childScaleAnimation;
  late Animation<RelativeRect> _childRelativeRectAnimation;
  late final Animation<double> _childRotationAnimation;
  late double _offsetValue;
  late Offset _freshPosition;
  Offset? _startPosition;
  bool _captured = false;

  /// Динамически определенный размер шторки
  Size? _drawerSize;

  /// Состояние, полностью ли закрыта шторка, необходимо для оптимизации
  /// анимации невидимых элементов. Если шторка полностью закрыта (т.е. ее не видно),
  /// то останавливаются все анимации на фоне, если шторка начинает открываться,
  /// анимации продолжаются
  late final ValueNotifier<bool> _drawerVisibilityNotifier;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? AdvancedDrawerController();
    _controller.addListener(handleControllerChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _controller.value.visible ? 1 : 0,
    );

    _drawerVisibilityNotifier = ValueNotifier(_controller.value.visible);
    _animationController.addListener(_handleDrawerVisibilityListener);

    _parentAnimation = widget.animationCurve != null
        ? CurvedAnimation(
            curve: widget.animationCurve!,
            parent: _animationController,
          )
        : _animationController;

    _drawerScaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(_parentAnimation);

    _childScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.65,
    ).animate(_parentAnimation);

    _childRelativeRectAnimation = RelativeRectTween(
      begin: const RelativeRect.fromLTRB(0, 0, 0, 0),
      end: RelativeRect.fromLTRB(_drawerSize?.width ?? 0, 0, -(_drawerSize?.width ?? 0), 0),
    ).animate(_parentAnimation);

    _childRotationAnimation = Tween<double>(
      begin: 0,
      end: 45 * math.pi / 180,
    ).animate(_parentAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backdropColor,
      child: GestureDetector(
        onHorizontalDragStart: widget.disabledGestures ? null : _handleDragStart,
        onHorizontalDragUpdate: widget.disabledGestures ? null : _handleDragUpdate,
        onHorizontalDragEnd: widget.disabledGestures ? null : _handleDragEnd,
        onHorizontalDragCancel: widget.disabledGestures ? null : _handleDragCancel,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              // -------- DRAWER
              Align(
                alignment: widget.rtlOpening ? Alignment.centerRight : Alignment.centerLeft,
                child: ScaleTransition(
                  scale: _drawerScaleAnimation,
                  alignment: widget.rtlOpening ? Alignment.centerLeft : Alignment.centerRight,
                  child: WidgetSize(
                    onSizeChange: _updateDrawerSize,
                    // Стоп/запуск всех анимаций в поддереве, оптимизация производительности,
                    // чтобы не дергать Ticker на невидимых элементах
                    child: ValueListenableBuilder(
                      valueListenable: _drawerVisibilityNotifier,
                      builder: (_, bool value, child) => TickerMode(
                        enabled: value,
                        child: child!,
                      ),
                      child: widget.drawer,
                    ),
                  ),
                ),
              ),
              // -------- CHILD
              PositionedTransition(
                rect: _childRelativeRectAnimation,
                child: AnimatedBuilder(
                  animation: _childRotationAnimation,
                  builder: (context, child) => Transform.scale(
                    alignment: Alignment.centerLeft,
                    scale: _childScaleAnimation.value,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_childRotationAnimation.value),
                      alignment: Alignment.centerLeft,
                      child: child,
                    ),
                  ),
                  child: Stack(
                    children: [
                      widget.child,
                      ValueListenableBuilder<AdvancedDrawerValue>(
                        valueListenable: _controller,
                        builder: (_, value, __) {
                          if (!value.visible) {
                            return const SizedBox();
                          }

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _controller.hideDrawer,
                              highlightColor: Colors.transparent,
                              child: Container(),
                            ),
                          );
                        },
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

  void handleControllerChanged() {
    _controller.value.visible ? _animationController.forward() : _animationController.reverse();
  }

  void _handleDragStart(DragStartDetails details) {
    _captured = true;
    _startPosition = details.globalPosition;
    _offsetValue = _animationController.value;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_captured) return;

    final screenSize = MediaQuery.of(context).size;

    _freshPosition = details.globalPosition;

    final diff = (_freshPosition - _startPosition!).dx;

    // 0.5 коэффициент от ширины экрана до которой нужно провести, чтобы раскрыть Drawer
    _animationController.value = _offsetValue + (diff / (screenSize.width * 0.5)) * (widget.rtlOpening ? -1 : 1);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_captured) return;

    _captured = false;

    if (_animationController.value >= 0.5) {
      if (_controller.value.visible) {
        _animationController.forward();
      } else {
        _controller.showDrawer();
      }
    } else {
      if (!_controller.value.visible) {
        _animationController.reverse();
      } else {
        _controller.hideDrawer();
      }
    }
  }

  void _handleDragCancel() {
    _captured = false;
  }

  /// Метод прослушивания состояния контроллера анимации,
  /// который напрямую связан с состояние шторки. Если текущее значение 0,
  /// то шторка полностью закрыта, если больше нуля то видима и можно
  /// запускать анимации шторки
  void _handleDrawerVisibilityListener() {
    if (_animationController.value > 0) {
      _drawerVisibilityNotifier.value = true;
    } else {
      _drawerVisibilityNotifier.value = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(handleControllerChanged);
    _animationController.removeListener(_handleDrawerVisibilityListener);
    _animationController.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  /// Обновления ширины шторки для корректной работы анимации
  void _updateDrawerSize(Size? size) {
    if (_drawerSize != size) {
      setState(() {
        _drawerSize = size;
        _childRelativeRectAnimation = RelativeRectTween(
          begin: const RelativeRect.fromLTRB(0, 0, 0, 0),
          end: RelativeRect.fromLTRB(_drawerSize?.width ?? 0, 0, -(_drawerSize?.width ?? 0), 0),
        ).animate(_parentAnimation);
      });
    }
  }
}
