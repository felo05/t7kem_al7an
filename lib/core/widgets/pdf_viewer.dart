import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

// =============================================================================
// Cache Service
// =============================================================================

class PdfCacheService {
  PdfCacheService._();
  static final PdfCacheService instance = PdfCacheService._();

  final Dio _dio = Dio();

  Future<File> getOrDownload(
      String url, {
        void Function(double progress)? onProgress,
      }) async {
    final cacheFile = await _cacheFileForUrl(url);
    if (await cacheFile.exists()) return cacheFile;

    await _dio.download(
      url,
      cacheFile.path,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress?.call(received / total);
      },
    );
    return cacheFile;
  }

  Future<File> _cacheFileForUrl(String url) async {
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/pdf_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    // Use hashCode as the cache key — no crypto needed
    final key = url.hashCode.abs();
    return File('${dir.path}/$key.pdf');
  }
}

// =============================================================================
// Viewer Screen
// =============================================================================

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  _ViewState _state = const _Loading(progress: 0);
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() => _state = const _Loading(progress: 0));
    try {
      final file = await PdfCacheService.instance.getOrDownload(
        widget.url,
        onProgress: (p) {
          if (mounted) setState(() => _state = _Loading(progress: p));
        },
      );
      if (mounted) setState(() => _state = _Ready(file: file));
    } catch (e) {
      if (mounted) setState(() => _state = _Failed(error: e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181825),
        foregroundColor: Colors.white,
        title: Text(
          widget.title ?? 'PDF Viewer',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_state is _Ready && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          if (_state is _Failed)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPdf,
            ),
        ],
      ),
      body: switch (_state) {
        _Loading(:final progress) => _buildLoading(progress),
        _Ready(:final file)      => _buildViewer(file),
        _Failed(:final error)    => _buildError(error),
      },
    );
  }

  Widget _buildLoading(double progress) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 5,
              color: const Color(0xFF89B4FA),
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            progress > 0
                ? 'Downloading… ${(progress * 100).toStringAsFixed(0)}%'
                : 'Loading PDF…',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildViewer(File file) {
    return PDFView(
      filePath: file.path,
      enableSwipe: true,
      autoSpacing: true,
      pageFling: true,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) {
        if (mounted) setState(() => _totalPages = pages ?? 0);
      },
      onPageChanged: (page, total) {
        if (mounted) {
          setState(() {
            _currentPage = page ?? 0;
            _totalPages = total ?? 0;
          });
        }
      },
      onError: (e) {
        if (mounted) setState(() => _state = _Failed(error: e.toString()));
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFF38BA8), size: 56),
            const SizedBox(height: 16),
            const Text(
              'Failed to load PDF',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF89B4FA),
                foregroundColor: Colors.black,
              ),
              onPressed: _loadPdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// State (sealed)
// =============================================================================

sealed class _ViewState { const _ViewState(); }

class _Loading extends _ViewState {
  const _Loading({required this.progress});
  final double progress;
}

class _Ready extends _ViewState {
  const _Ready({required this.file});
  final File file;
}

class _Failed extends _ViewState {
  const _Failed({required this.error});
  final String error;
}