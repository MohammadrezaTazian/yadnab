import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

class DioNetworkSvgImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final BoxFit fit;

  const DioNetworkSvgImage({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.fit = BoxFit.contain,
  });

  @override
  State<DioNetworkSvgImage> createState() => _DioNetworkSvgImageState();
}

class _DioNetworkSvgImageState extends State<DioNetworkSvgImage> {
  String? _svgString;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSvg();
  }

  Future<void> _fetchSvg() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        widget.imageUrl,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data.toString();
        // Simple validation: check if it looks like SVG
        if (data.contains('<svg')) {
           if (mounted) {
            setState(() {
              _svgString = data;
              _isLoading = false;
            });
           }
        } else {
           if (mounted) {
             setState(() {
               _errorMessage = 'Invalid SVG data';
               _isLoading = false;
             });
           }
        }
      } else {
        if (mounted) {
            setState(() {
              _errorMessage = 'Error ${response.statusCode}';
              _isLoading = false;
            });
        }
      }
    } catch (e) {
      if (mounted) {
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        width: widget.height, 
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(height: 4),
              Text('Error', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_svgString != null) {
      // Clean the SVG - handle both formats: with and without width/height
      var cleanSvg = _svgString!;
      // Remove width/height if present (to rely on viewBox)
      // Regex to match width and height attributes in svg tag, handling various formats
      // e.g. width="100", width='100px', width="100%"
      cleanSvg = cleanSvg.replaceAll(
        RegExp(r'(width|height)=["\K][^"\>]+["\K]'),
        '',
      );
      // Wait, simpler regex: remove width="..." or height="..."
      cleanSvg = cleanSvg.replaceAll(RegExp(r'width="[^"]*"'), '');
      cleanSvg = cleanSvg.replaceAll(RegExp(r"width='[^']*'"), '');
      cleanSvg = cleanSvg.replaceAll(RegExp(r'height="[^"]*"'), '');
      cleanSvg = cleanSvg.replaceAll(RegExp(r"height='[^']*'"), '');

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2), // Debug border
        ),
        child: SvgPicture.string(
          cleanSvg,
          height: widget.height,
          fit: widget.fit,
        ),
      );
    }

    return SizedBox(height: widget.height);
  }
}
