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
  /// Translation components are fractions of the sliver painted dimensions.
  final Animation<Matrix4> transform;

  @override
  RenderSliverTransform createRenderObject(BuildContext context) {
    return RenderSliverTransform(transform);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverTransform renderObject) {
    renderObject.matrix = transform;
  }
}

/// Applies a paint transform while preserving the child sliver geometry.
class RenderSliverTransform extends RenderProxySliver {
  RenderSliverTransform(this._matrix);

  /// The animation driving the paint transform, observed while attached.
  Animation<Matrix4> _matrix;

  /// The current transformation matrix.
  Matrix4 get matrix => _matrix.value;

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

  /// Replaces the animation and moves the listener to the new instance.
  set matrix(Animation<Matrix4> value) {
    if (identical(_matrix, value)) return;
    if (attached) {
      _matrix.removeListener(updateTransform);
    }

    _matrix = value;
    if (attached) {
      _matrix.addListener(updateTransform);
    }

    updateTransform();
  }

  /// Applies the matrix around the painted center rather than the origin.
  Matrix4 get transform {
    final copyMatrix = Matrix4.copy(matrix);
    final size = switch (constraints.axis) {
      .vertical => Size(constraints.crossAxisExtent, geometry!.paintExtent),
      .horizontal => Size(geometry!.paintExtent, constraints.crossAxisExtent),
    };

    copyMatrix.setTranslationRaw(
      copyMatrix.storage[12] * size.width,
      copyMatrix.storage[13] * size.height,
      copyMatrix.storage[14],
    );

    return .translationValues(center.dx, center.dy, 0)
      ..multiply(copyMatrix)
      ..multiply(.translationValues(-center.dx, -center.dy, 0));
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
    _matrix.addListener(updateTransform);
  }

  @override
  void detach() {
    _matrix.removeListener(updateTransform);
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
      transform,
      (context, offset) => context.paintChild(child!, offset),
      oldLayer: _layer.layer,
    );
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    super.applyPaintTransform(child, transform..multiply(this.transform));
  }
}
