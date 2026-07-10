import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';
import '../../../../../core/di/service_locator.dart';
import '../../model/church_average.dart';
import '../../view_model/collection_results/collection_results_cubit.dart';
import '../../view_model/export_pdf/export_pdf_cubit.dart';
import 'church_details_screen.dart';

class CollectionDetailsScreen extends StatelessWidget {
  final String collectionName;
  final String displayName;

  const CollectionDetailsScreen(
      {super.key, required this.collectionName, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => CollectionResultsCubit(sl<IAdminRepository>())
              ..watch(collectionName)),
        BlocProvider(create: (_) => ExportPdfCubit()),
      ],
      child: _CollectionDetailsBody(
          collectionName: collectionName, displayName: displayName),
    );
  }
}

class _CollectionDetailsBody extends StatefulWidget {
  const _CollectionDetailsBody(
      {required this.collectionName, required this.displayName});
  final String collectionName;
  final String displayName;

  @override
  State<_CollectionDetailsBody> createState() => _CollectionDetailsBodyState();
}

class _CollectionDetailsBodyState extends State<_CollectionDetailsBody> {
  bool _isSelectionMode = false;
  final Set<String> _selectedChurches = {};
  List<ChurchAverage> _lastRankings = [];

  void _saveSelectedChurches() {
    if (_selectedChurches.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedChurchesDisplayScreen(
          selectedChurches: _selectedChurches.toList(),
          collectionName: widget.collectionName,
        ),
      ),
    );
  }

  void _exportPdf(BuildContext context) {
    // reuse already-streamed docs — no extra Firestore read for export
    final allDocs = _lastRankings.expand((avg) => avg.allDocuments).toList();
    context.read<ExportPdfCubit>().exportCollection(
          collectionName: widget.collectionName,
          displayName: widget.displayName,
          allDocs: allDocs,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportPdfCubit, ExportPdfState>(
      listener: (context, state) {
        if (state is ExportPdfError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('خطأ في تصدير PDF: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isSelectionMode
                ? '${_selectedChurches.length} كنيسة محددة'
                : widget.displayName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          actions: _isSelectionMode
              ? [
                  IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: _selectedChurches.isNotEmpty
                          ? _saveSelectedChurches
                          : null),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _isSelectionMode = false;
                      _selectedChurches.clear();
                    }),
                  ),
                ]
              : [
                  BlocBuilder<ExportPdfCubit, ExportPdfState>(
                    builder: (context, state) {
                      final isExporting = state is ExportPdfLoading;
                      return IconButton(
                        icon: isExporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.picture_as_pdf),
                        tooltip: 'تصدير النتائج كـ PDF',
                        onPressed:
                            isExporting ? null : () => _exportPdf(context),
                      );
                    },
                  ),
                  IconButton(
                      icon: const Icon(Icons.check_box),
                      onPressed: () => setState(() => _isSelectionMode = true)),
                ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orange.shade700, Colors.orange.shade50]),
          ),
          child: BlocBuilder<CollectionResultsCubit, CollectionResultsState>(
            builder: (context, state) {
              if (state is CollectionResultsLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              final rankings = (state as CollectionResultsSuccess).rankings;
              _lastRankings = rankings;

              if (rankings.isEmpty) {
                return const Center(
                    child: Text('لا توجد بيانات متاحة',
                        style: TextStyle(color: Colors.white, fontSize: 18)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: rankings.length,
                itemBuilder: (context, index) {
                  final avg = rankings[index];
                  final churchName = avg.churchName;
                  final total =
                      "%${(100 * avg.averagePercent).toStringAsFixed(2)}";
                  final isWinner = index == 0;
                  final isSelected = _selectedChurches.contains(churchName);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected && _isSelectionMode
                          ? Colors.orange.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isWinner
                          ? Border.all(color: Colors.amber, width: 2)
                          : isSelected && _isSelectionMode
                              ? Border.all(
                                  color: Colors.orange.shade300, width: 2)
                              : null,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: InkWell(
                      onTap: _isSelectionMode
                          ? () => setState(() {
                                isSelected
                                    ? _selectedChurches.remove(churchName)
                                    : _selectedChurches.add(churchName);
                              })
                          : null,
                      child: Row(
                        children: [
                          if (_isSelectionMode) ...[
                            Checkbox(
                              value: isSelected,
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selectedChurches.add(churchName);
                                } else {
                                  _selectedChurches.remove(churchName);
                                }
                              }),
                              activeColor: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isWinner
                                  ? Colors.amber
                                  : index == 1
                                      ? Colors.grey.shade400
                                      : index == 2
                                          ? Colors.orange.shade300
                                          : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: isWinner
                                  ? const Icon(Icons.emoji_events,
                                      color: Colors.white, size: 20)
                                  : Text('${index + 1}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: index <= 2
                                              ? Colors.white
                                              : Colors.grey.shade600)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isSelectionMode
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChurchDetailsScreen(
                                            churchName: churchName,
                                            collectionName:
                                                widget.collectionName,
                                            initialDocuments: avg.allDocuments,
                                          ),
                                        ),
                                      );
                                    },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            churchName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isWinner
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isWinner
                                                  ? Colors.amber.shade700
                                                  : Colors.blue.shade700,
                                              decoration: _isSelectionMode
                                                  ? TextDecoration.none
                                                  : TextDecoration.underline,
                                              decorationColor: isWinner
                                                  ? Colors.amber.shade700
                                                  : Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                        if (!_isSelectionMode)
                                          Icon(Icons.arrow_forward_ios,
                                              size: 12,
                                              color: Colors.grey.shade400),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (isWinner)
                                      Text(
                                          '🏆 الفائز الأول (متوسط من ${avg.documentCount} استمارة)',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber.shade600,
                                              fontWeight: FontWeight.w500))
                                    else
                                      Text(
                                        _isSelectionMode
                                            ? 'متوسط من ${avg.documentCount} استمارة'
                                            : 'متوسط من ${avg.documentCount} استمارة - انقر للتفاصيل',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                            fontStyle: FontStyle.italic),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: isWinner
                                    ? Colors.amber.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: [
                                Text(total,
                                    style: TextStyle(
                                        color: isWinner
                                            ? Colors.amber.shade700
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text('متوسط',
                                    style: TextStyle(
                                        color: isWinner
                                            ? Colors.amber.shade600
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class SelectedChurchesDisplayScreen extends StatefulWidget {
  final List<String> selectedChurches;
  final String collectionName;

  const SelectedChurchesDisplayScreen({
    super.key,
    required this.selectedChurches,
    required this.collectionName,
  });

  @override
  State<SelectedChurchesDisplayScreen> createState() =>
      _SelectedChurchesDisplayScreenState();
}

class _SelectedChurchesDisplayScreenState
    extends State<SelectedChurchesDisplayScreen> {
  bool _isLoading = false;
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الكنائس المحددة",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade700,
                Colors.green.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  RepaintBoundary(
                      key: _globalKey, child: _buildCertificateDesign()),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveToGalleryAndFirestore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isLoading
                            ? 'جاري الحفظ...'
                            : 'حفظ في المعرض وإضافة للمجموعات',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateDesign() {
    String levelName = _formatCollectionName(widget.collectionName);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Image.asset('assets/images/logo2.jpg', width: 60, height: 60),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'الكنائس المصعدة للتصفيات النهائية\nيوم السبت 2 اغسطس 2025 بكنيسة القديسة دميانة بالهرم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        levelName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset('assets/images/logo.png', width: 60, height: 60),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade200,
                  Colors.green.shade600,
                  Colors.green.shade200,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: widget.selectedChurches.length *
                      42.0, // Approximate height per item
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.selectedChurches.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade100,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.selectedChurches[index],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCollectionName(String collection) {
    String name = collection.replaceAll('ResultsFinal', '');
    switch (name) {
      case 'kg1':
        return 'حضانة المستوى الأول';
      case 'kg2':
        return 'حضانة المستوى الثاني';
      case 'kgG':
        return 'حضانة موهوبين جماعي';
      case 'kgF':
        return 'حضانة موهوبين فردي';
      case 'oulaTanya1':
        return 'أولى وثانية المستوى الأول';
      case 'oulaTanya2':
        return 'أولى وثانية المستوى الثاني';
      case 'oulaTanyaG':
        return 'أولى وثانية موهوبين جماعي';
      case 'oulaTanyaF':
        return 'أولى وثانية موهوبين فردي';
      case 'taltaRaba1':
        return 'ثالثة ورابعة المستوى الأول';
      case 'taltaRaba2':
        return 'ثالثة ورابعة المستوى الثاني';
      case 'taltaRabaG':
        return 'ثالثة ورابعة موهوبين جماعي';
      case 'taltaRabaF':
        return 'ثالثة ورابعة موهوبين فردي';
      case 'khamsaSadsa1':
        return 'خامسة وسادسة المستوى الأول';
      case 'khamsaSadsa2':
        return 'خامسة وسادسة المستوى الثاني';
      case 'khamsaSadsaG':
        return 'خامسة وسادسة موهوبين جماعي';
      case 'khamsaSadsaF':
        return 'خامسة وسادسة موهوبين فردي';
      default:
        return name;
    }
  }

  Future<void> _saveToGalleryAndFirestore() async {
    setState(() => _isLoading = true);

    try {
      await _captureAndSave();
      // await _saveToFirestore();
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الكنائس المختارة في المعرض بنجاح!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _captureAndSave() async {
    try {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Ensure build is complete
      final boundary = _globalKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        await SaverGallery.saveImage(
          pngBytes,
          fileName: "form_${DateTime.now().millisecondsSinceEpoch}.jpg",
          skipIfExists: true,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
