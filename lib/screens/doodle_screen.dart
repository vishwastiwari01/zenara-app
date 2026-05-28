import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';

class StrokeLine {
  final List<Point> points;
  final Color color;
  final double size;
  final bool isEraser;

  StrokeLine({
    required this.points,
    required this.color,
    required this.size,
    this.isEraser = false,
  });
}

class DoodleScreen extends StatefulWidget {
  const DoodleScreen({Key? key}) : super(key: key);

  @override
  State<DoodleScreen> createState() => _DoodleScreenState();
}

class _DoodleScreenState extends State<DoodleScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  
  List<StrokeLine> _lines = [];
  List<StrokeLine> _redoStack = [];
  StrokeLine? _currentLine;

  Color _selectedColor = Colors.white;
  double _selectedSize = 8.0;
  bool _isEraser = false;

  final List<Color> _palette = [
    Colors.white,
    AppColors.purpleLight,
    AppColors.teal,
    AppColors.coral,
    AppColors.peach,
    AppColors.gold,
  ];

  final List<double> _sizes = [4.0, 8.0, 16.0, 24.0];

  void _onPanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Point point = Point(localPosition.dx, localPosition.dy);
    
    setState(() {
      _currentLine = StrokeLine(
        points: [point],
        color: _selectedColor,
        size: _selectedSize,
        isEraser: _isEraser,
      );
      _redoStack.clear();
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentLine == null) return;
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Point point = Point(localPosition.dx, localPosition.dy);
    
    setState(() {
      _currentLine!.points.add(point);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentLine != null) {
      setState(() {
        _lines.add(_currentLine!);
        _currentLine = null;
      });
    }
  }

  void _undo() {
    if (_lines.isNotEmpty) {
      setState(() {
        _redoStack.add(_lines.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _lines.add(_redoStack.removeLast());
      });
    }
  }

  Future<void> _saveAndReturn() async {
    try {
      final directory = await getTemporaryDirectory();
      final String fileName = 'doodle_${DateTime.now().millisecondsSinceEpoch}.png';
      final String fullPath = '${directory.path}/$fileName';
      
      final imageFile = await _screenshotController.captureAndSave(
        directory.path,
        fileName: fileName,
        pixelRatio: 2.0,
      );
      
      if (mounted && imageFile != null) {
        Navigator.of(context).pop(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save drawing: $e')),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_lines.isEmpty) return true;
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Discard drawing?', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24)),
        content: Text('Are you sure you want to exit? Your current drawing will be lost.', style: GoogleFonts.inter(color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.purpleLight, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral.withOpacity(0.2),
              foregroundColor: AppColors.coral,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            // Drawing Canvas
            Positioned.fill(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: AppColors.bg,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: CustomPaint(
                      painter: _DoodlePainter(
                        lines: _lines,
                        currentLine: _currentLine,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
            
            // Top Toolbar
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: _buildTopToolbar().animate().slideY(begin: -1.0, duration: 400.ms, curve: Curves.easeOutQuart),
            ),
            
            // Bottom Tool Palette
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 24,
              right: 24,
              child: _buildBottomPalette().animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutQuart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopToolbar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildIconButton(Icons.close, () async {
                if (await _onWillPop()) {
                  Navigator.of(context).pop();
                }
              }),
              const SizedBox(width: 16),
              Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
              const SizedBox(width: 16),
              _buildIconButton(Icons.undo, _lines.isNotEmpty ? _undo : null),
              const SizedBox(width: 12),
              _buildIconButton(Icons.redo, _redoStack.isNotEmpty ? _redo : null),
            ],
          ),
          GestureDetector(
            onTap: _saveAndReturn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.teal.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
                ],
              ),
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPalette() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ..._sizes.map((size) => _buildSizeButton(size)),
              Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
              _buildEraserButton(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _palette.map((color) => _buildColorButton(color)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap) {
    final bool disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: disabled ? AppColors.muted.withOpacity(0.5) : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSizeButton(double size) {
    final isSelected = _selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: size.clamp(4.0, 16.0),
          height: size.clamp(4.0, 16.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : AppColors.muted,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildEraserButton() {
    return GestureDetector(
      onTap: () => setState(() => _isEraser = !_isEraser),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isEraser ? AppColors.coral.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _isEraser ? AppColors.coral : Colors.transparent),
        ),
        child: Icon(
          Icons.cleaning_services_rounded,
          color: _isEraser ? AppColors.coral : AppColors.muted,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _selectedColor == color && !_isEraser;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedColor = color;
        _isEraser = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : [],
        ),
      ),
    );
  }
}

class _DoodlePainter extends CustomPainter {
  final List<StrokeLine> lines;
  final StrokeLine? currentLine;

  _DoodlePainter({
    required this.lines,
    required this.currentLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // SaveLayer is required for BlendMode.clear to work nicely without turning the canvas black
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final allLines = List<StrokeLine>.from(lines);
    if (currentLine != null) {
      allLines.add(currentLine!);
    }

    for (var line in allLines) {
      if (line.points.isEmpty) continue;

      final strokeData = getStroke(
        line.points,
        options: StrokeOptions(
          size: line.size,
          thinning: 0.6,
          smoothing: 0.5,
          streamline: 0.5,
          simulatePressure: true,
        ),
      );

      final path = Path();
      if (strokeData.isNotEmpty) {
        path.moveTo(strokeData.first.dx, strokeData.first.dy);
        for (var point in strokeData.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        path.close();
      }

      final paint = Paint()
        ..color = line.isEraser ? Colors.transparent : line.color
        ..style = PaintingStyle.fill
        ..blendMode = line.isEraser ? BlendMode.clear : BlendMode.srcOver;

      canvas.drawPath(path, paint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) {
    return true; // Simple approach for now
  }
}
