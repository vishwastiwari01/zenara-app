import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class DoodleCanvas extends StatefulWidget {
  final ValueChanged<List<DrawingPoint?>>? onChanged;

  const DoodleCanvas({Key? key, this.onChanged}) : super(key: key);

  @override
  State<DoodleCanvas> createState() => DoodleCanvasState();
}

class DoodleCanvasState extends State<DoodleCanvas> {
  final List<DrawingPoint?> _points = [];
  final List<List<DrawingPoint?>> _undoHistory = [];
  Color _selectedColor = AppColors.purpleLight;
  double _strokeWidth = 3.0;
  bool _isEraser = false;

  final List<Color> _palette = [
    AppColors.purpleLight,
    AppColors.teal,
    AppColors.coral,
    AppColors.pink,
    AppColors.peach,
    AppColors.gold,
    Colors.white,
    const Color(0xFF7C9ABF),
  ];

  void clear() {
    setState(() {
      _undoHistory.add(List.from(_points));
      _points.clear();
    });
    widget.onChanged?.call(_points);
  }

  void undo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _points.clear();
        _points.addAll(_undoHistory.removeLast());
      });
      widget.onChanged?.call(_points);
    }
  }

  bool get hasContent => _points.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drawing area
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF121030),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _undoHistory.add(List.from(_points));
                _points.add(DrawingPoint(
                  offset: details.localPosition,
                  paint: Paint()
                    ..color = _isEraser ? const Color(0xFF121030) : _selectedColor
                    ..strokeCap = StrokeCap.round
                    ..strokeWidth = _isEraser ? _strokeWidth * 3 : _strokeWidth
                    ..isAntiAlias = true
                    ..style = PaintingStyle.stroke,
                ));
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _points.add(DrawingPoint(
                  offset: details.localPosition,
                  paint: Paint()
                    ..color = _isEraser ? const Color(0xFF121030) : _selectedColor
                    ..strokeCap = StrokeCap.round
                    ..strokeWidth = _isEraser ? _strokeWidth * 3 : _strokeWidth
                    ..isAntiAlias = true
                    ..style = PaintingStyle.stroke,
                ));
              });
            },
            onPanEnd: (_) {
              setState(() {
                _points.add(null); // Separator between strokes
              });
              widget.onChanged?.call(_points);
            },
            child: CustomPaint(
              painter: DoodlePainter(points: _points),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Toolbar row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Color palette
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _palette.map((color) {
                      final isSelected = _selectedColor == color && !_isEraser;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                            _isEraser = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 6),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Eraser
              _buildToolBtn(
                icon: Icons.cleaning_services_outlined,
                isActive: _isEraser,
                onTap: () => setState(() => _isEraser = !_isEraser),
              ),
              const SizedBox(width: 4),
              // Undo
              _buildToolBtn(
                icon: Icons.undo,
                isActive: false,
                onTap: undo,
              ),
              const SizedBox(width: 4),
              // Clear
              _buildToolBtn(
                icon: Icons.delete_outline,
                isActive: false,
                onTap: clear,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Stroke width slider
        Row(
          children: [
            Text('Size', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _isEraser ? AppColors.muted : _selectedColor,
                  inactiveTrackColor: Colors.white.withOpacity(0.06),
                  trackHeight: 3.0,
                  thumbColor: _isEraser ? AppColors.muted : _selectedColor,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                  overlayColor: (_isEraser ? AppColors.muted : _selectedColor).withOpacity(0.15),
                ),
                child: Slider(
                  value: _strokeWidth,
                  min: 1.0,
                  max: 12.0,
                  onChanged: (val) => setState(() => _strokeWidth = val),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.purple.withOpacity(0.5) : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.purpleLight : AppColors.muted,
          size: 16,
        ),
      ),
    );
  }
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

class DoodlePainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DoodlePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
          ui.PointMode.points,
          [points[i]!.offset],
          points[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DoodlePainter oldDelegate) => true;
}
