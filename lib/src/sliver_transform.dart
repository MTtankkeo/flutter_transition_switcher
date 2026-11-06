import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Applies a paint transform to a sliver without changing its scroll extent.
class SliverTransform extends SingleChildRenderObjectWidget {
  const SliverTransform({
    super.key,
    required this.transform,
    required Widget sliver,
  }) : super(child: sliver);

  /// The animation that supplies the paint transformation matrix.
  final Animation<Matrix4> transform;

  @override
  RenderSliverTransform createRenderObject(BuildContext context) {
    return RenderSliverTransform(transform);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverTransform renderObject) {
    renderObject.transform = transform;
  }
}

/// Applies a paint transform while preserving the child sliver geometry.
class RenderSliverTransform extends RenderProxySliver {
  RenderSliverTransform(this._transform);

  /// The animation driving the paint transform, observed while attached.
  Animation<Matrix4> _transform;

  /// The current transformation matrix.
  Matrix4 get transform => _transform.value;

  /// The center of the painted region, used as the transform origin.
  Offset get center => switch (constraints.axis) {
    .vertical => .new(
      constraints.crossAxisExtent / 2,
      geometry!.paintOrigin + geometry!.paintExtent / 2,
    ),
    .horizontal => .new(
      geometry!.paintOrigin + geometry!.paintExtent / 2,
      constraints.crossAxisExtent / 2,
    ),
  };

  /// Applies the matrix around the painted center rather than the origin.
  Matrix4 get effectiveTransform {
    return .translationValues(center.dx, center.dy, 0)
      ..multiply(transform)
      ..multiply(.translationValues(-center.dx, -center.dy, 0));
  }

  /// Replaces the animation and moves the listener to the new instance.
  set transform(Animation<Matrix4> value) {
    if (identical(_transform, value)) return;
    if (attached) {
      _transform.removeListener(updateTransform);
    }

    _transform = value;
    if (attached) {
      _transform.addListener(updateTransform);
    }

    updateTransform();
  }

  /// Updates painting and semantics without requesting layout.
  void updateTransform() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// Retains the transform layer for reuse across animation frames.
  final _layer = LayerHandle<TransformLayer>();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _transform.addListener(updateTransform);
  }

  @override
  void detach() {
    _transform.removeListener(updateTransform);
    super.detach();
  }

  @override
  void dispose() {
    _layer.layer = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Skip painting when no visible content remains.
    if (child == null || !geometry!.visible) {
      _layer.layer = null;
      return;
    }

    // Transform the painted child without changing its scroll extent.
    _layer.layer = context.pushTransform(
      needsCompositing,
      offset,
      effectiveTransform,
      (context, offset) => context.paintChild(child!, offset),
      oldLayer: _layer.layer,
    );
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    super.applyPaintTransform(child, transform..multiply(effectiveTransform));
  }
}
