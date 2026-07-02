import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'church_details_screen.dart';

class CheckStatusScreen extends StatefulWidget {
  const CheckStatusScreen({super.key});

  @override
  State<CheckStatusScreen> createState() => _CheckStatusScreenState();
}

class _CheckStatusScreenState extends State<CheckStatusScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Collection names for the 16 stat cards
  final List<String> _collections = [
    'kg1ResultsFinal',
    'kg2ResultsFinal',
    'kgGResultsFinal',
    'kgFResultsFinal',
    'oulaTanya1ResultsFinal',
    'oulaTanya2ResultsFinal',
    'oulaTanyaGResultsFinal',
    'oulaTanyaFResultsFinal',
    'taltaRaba1ResultsFinal',
    'taltaRaba2ResultsFinal',
    'taltaRabaGResultsFinal',
    'taltaRabaFResultsFinal',
    'khamsaSadsa1ResultsFinal',
    'khamsaSadsa2ResultsFinal',
    'khamsaSadsaGResultsFinal',
    'khamsaSadsaFResultsFinal',
  ];

  // Store the maximum document data for each collection
  final Map<String, Map<String, dynamic>> _collectionMaxData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch maximum document for each collection
      for (String collection in _collections) {
        await _fetchMaxDocumentForCollection(collection);
      }
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMaxDocumentForCollection(String collectionName) async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      if (snapshot.docs.isNotEmpty) {
        // Group documents by church name and calculate averages
        Map<String, List<Map<String, dynamic>>> churchGroups = {};

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final churchName = data['churchName'] ?? data['church'] ?? 'غير محدد';

          if (!churchGroups.containsKey(churchName)) {
            churchGroups[churchName] = [];
          }

          churchGroups[churchName]!.add({
            'id': doc.id,
            'percent': data['percent'] ?? 0,
            'data': data,
          });
        }

        // Find the church with highest average total
        String topChurch = 'غير محدد';
        double highestAverage = 0;
        Map<String, dynamic> topData = {};

        for (var entry in churchGroups.entries) {
          final churchName = entry.key;
          final documents = entry.value;

          // Calculate average total for this church
          double totalSum = 0;
          int validDocs = 0;
          for (var doc in documents) {
            final percent = (doc['percent'] as num?)?.toDouble() ?? 0;
            if (percent > 0) {
              totalSum += percent;
              validDocs++;
            }
          }
          
          if (validDocs > 0) {
            double average = totalSum / validDocs;
            if (average > highestAverage) {
              highestAverage = average;
              topChurch = churchName;
              topData = documents.first['data']; // Use first document data as reference
            }
          }
        }

        _collectionMaxData[collectionName] = {
          'docId': 'Average',
          'percent': highestAverage,
          'church': topChurch,
          'data': topData,
          'churchGroups': churchGroups,
          'hasValidData': highestAverage > 0,
        };
        
        // Debug print to see what data we have
        print('Collection $collectionName: churches=${churchGroups.keys.toList()}, topChurch=$topChurch, average=$highestAverage');
      } else {
        _collectionMaxData[collectionName] = {
          'docId': 'No Data',
          'percent': 0,
          'church': 'لا توجد بيانات',
          'data': {},
          'churchGroups': {},
        };
      }
    } catch (e) {
      print('Error fetching $collectionName: $e');
      _collectionMaxData[collectionName] = {
        'docId': 'Error',
        'percent': 0,
        'church': 'خطأ في التحميل',
        'data': {},
        'churchGroups': {},
      };
    }
  }

  Future<void> _exportToPDF() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load images from assets
      final Uint8List logo1 = await rootBundle.load('assets/images/logo.png').then((data) => data.buffer.asUint8List());
      final Uint8List logo2 = await rootBundle.load('assets/images/logo2.jpg').then((data) => data.buffer.asUint8List());

      // Load Arabic font using Google Fonts
      final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
      final arabicBoldFont = await PdfGoogleFonts.notoSansArabicBold();

      final pdf = pw.Document();

      for (String collection in _collections) {
        final data = _collectionMaxData[collection];
        final displayName = _formatCollectionName(collection);
        print(data); // Debug print to see the data structure
        
        // Debug print to see what data we have for PDF export
        print('PDF Export - Collection: $collection, hasData: ${data != null}, hasValidData: ${data?['hasValidData']}, church: ${data?['church']}, percent: ${data?['percent']}');
        
        // Determine how many churches to show
        List<String> topChurches = [];
        if (collection.contains('1') || collection.contains('2')) {
          // For levels ending in 1 or 2, show only the highest scoring church
          if (data != null && data['hasValidData'] == true && data['church'] != null) {
            topChurches.add(data['church']);
            print('Top church for $collection: ${data['church']} with average ${data['percent']}');
          }
        } else if (collection.contains('G') || collection.contains('F')) {
          // For levels ending in G or F, show top 2 churches
          if (data != null && data['churchGroups'] != null) {
            final churchGroups = data['churchGroups'] as Map<String, List<Map<String, dynamic>>>;
            
            // Calculate averages and sort
            List<MapEntry<String, double>> churchAverages = [];
            for (var entry in churchGroups.entries) {
              final churchName = entry.key;
              final documents = entry.value;
              
              // Only exclude if church name is explicitly error messages, allow 'غير محدد'
              if (churchName != 'لا توجد بيانات' && churchName != 'خطأ في التحميل' && churchName.isNotEmpty) {
                double totalSum = 0;
                int validDocs = 0;
                for (var doc in documents) {
                  final percent = (doc['percent'] as num?)?.toDouble() ?? 0;
                  if (percent > 0) {
                    totalSum += percent;
                    validDocs++;
                  }
                }
                if (validDocs > 0) {
                  double average = totalSum / validDocs;
                  churchAverages.add(MapEntry(churchName, average));
                }
              }
            }
            
            churchAverages.sort((a, b) => b.value.compareTo(a.value));
            topChurches = churchAverages.take(2).map((e) => e.key).toList();
          }
        }
        
        print('PDF Export - Collection: $collection, topChurches: $topChurches');

        // Create PDF page for this level
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Header with logos
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Image(pw.MemoryImage(logo1), width: 100, height: 100),
                          pw.Expanded(
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  "نتائج مسابقة الألحان والتسبحة",
                                  style: pw.TextStyle(
                                    font: arabicBoldFont,
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.SizedBox(height: 10),
                                pw.Text(
                                  'المصعدين',
                                  style: pw.TextStyle(
                                    font: arabicFont,
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.normal,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),                              ],
                            ),
                          ),
                          pw.Image(pw.MemoryImage(logo2), width: 100, height: 100),
                        ],
                      ),
                      
                      pw.SizedBox(height: 40),
                      
                      // Level name
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green100,
                          borderRadius: pw.BorderRadius.circular(10),
                          border: pw.Border.all(color: PdfColors.green300),
                        ),
                        child: pw.Text(
                          displayName,
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      
                      pw.SizedBox(height: 40),
                      
                      // Churches list
                      if (topChurches.isNotEmpty) ...[
                        
                        ...topChurches.asMap().entries.map((entry) {
                          int index = entry.key;
                          String churchName = entry.value;
                          
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 15),
                            padding: const pw.EdgeInsets.all(15),
                            decoration: pw.BoxDecoration(
                              color: index == 0 ? PdfColors.amber100 : PdfColors.grey100,
                              borderRadius: pw.BorderRadius.circular(10),
                              border: pw.Border.all(
                                color: index == 0 ? PdfColors.amber300 : PdfColors.grey300,
                                width: 2,
                              ),
                            ),
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 40,
                                  height: 40,
                                  decoration: pw.BoxDecoration(
                                    color: index == 0 ? PdfColors.amber : PdfColors.grey400,
                                    borderRadius: pw.BorderRadius.circular(20),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(
                                      '${index + 1}',
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.SizedBox(width: 20),
                                pw.Expanded(
                                  child: pw.Text(
                                    churchName,
                                    style: pw.TextStyle(
                                      font: index == 0 ? arabicBoldFont : arabicFont,
                                      fontSize: 16,
                                      fontWeight: index == 0 ? pw.FontWeight.bold : pw.FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ] else ...[
                        pw.Container(
                          padding: const pw.EdgeInsets.all(20),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.red100,
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(color: PdfColors.red300),
                          ),
                          child: pw.Text(
                            'لا توجد بيانات متاحة لهذا المستوى',
                            style: pw.TextStyle(
                              font: arabicFont,
                              fontSize: 16,
                              color: PdfColors.red800,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                      
                      pw.Spacer(),
                      
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }

      // Show PDF preview and save options
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Church_Competition_Results_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تصدير PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "النتائج",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isLoading ? null : _exportToPDF,
            tooltip: 'تصدير النتائج كـ PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _buildOverviewTab(),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 30,
            childAspectRatio: 0.95,
            children: _collections.map((collection) {
              final data = _collectionMaxData[collection];
              final displayName = _formatCollectionName(collection);
              final winnerChurch = data?['church'] ?? 'جاري التحميل...';
              final total = data?['percent'] ?? 0;

              return _buildCollectionStatCard(
                displayName,
                winnerChurch,
                '$total (متوسط)',
                _getCollectionIcon(collection),
                _getCollectionColor(collection),
                collection,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionStatCard(String title, String winnerChurch,
      String total, IconData icon, Color color, String collectionName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetailsScreen(
              collectionName: collectionName,
              displayName: title,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '🏆 $winnerChurch',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCollectionName(String collection) {
    // Remove "Results" and format the name
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

  IconData _getCollectionIcon(String collection) {
    if (collection.contains('kg')) {
      return Icons.child_care;
    } else if (collection.contains('oulaTanya')) {
      return Icons.school;
    } else if (collection.contains('taltaRaba')) {
      return Icons.menu_book;
    } else if (collection.contains('khamsaSadsa')) {
      return Icons.auto_stories;
    }
    return Icons.emoji_events;
  }

  Color _getCollectionColor(String collection) {
    if (collection.contains('kg')) {
      return Colors.green;
    } else if (collection.contains('oulaTanya')) {
      return Colors.blue;
    } else if (collection.contains('taltaRaba')) {
      return Colors.orange;
    } else if (collection.contains('khamsaSadsa')) {
      return Colors.purple;
    }
    return Colors.grey;
  }
}

class CollectionDetailsScreen extends StatefulWidget {
  final String collectionName;
  final String displayName;

  const CollectionDetailsScreen({
    super.key,
    required this.collectionName,
    required this.displayName,
  });

  @override
  State<CollectionDetailsScreen> createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];
  bool _isSelectionMode = false;
  final Set<String> _selectedChurches = {};

  @override
  void initState() {
    super.initState();
    _loadCollectionData();
  }

  Future<void> _loadCollectionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .get();
      Map<String, List<Map<String, dynamic>>> churchGroups = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final churchName = data['churchName'] ?? data['church'] ?? 'غير محدد';

        if (!churchGroups.containsKey(churchName)) {
          churchGroups[churchName] = [];
        }

        churchGroups[churchName]!.add({
          'id': doc.id,
          'percent': data['percent'] ?? 0,
          'data': data,
        });
      }

      // Calculate averages for each church
      _documents = [];
      for (var entry in churchGroups.entries) {
        final churchName = entry.key;
        final documents = entry.value;

        // Calculate average total for this church
        double totalSum = 0;
        for (var doc in documents) {
          totalSum += (doc['percent'] as num).toDouble();
        }
        double average = totalSum / documents.length;

        _documents.add({
          'id': 'average_$churchName',
          'churchName': churchName,
          'percent': average,
          'documentCount': documents.length,
          'data': documents.first['data'],
          'allDocuments': documents,
        });
      }

      // Sort by average total descending
      _documents.sort(
          (a, b) => (b['percent'] as double).compareTo(a['percent'] as double));
    } catch (e) {
      print('Error loading collection data: $e');
      _documents = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _saveSelectedChurches() async {
    if (_selectedChurches.isEmpty) return;

    // Navigate to selected churches display screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode 
              ? '${_selectedChurches.length} كنيسة محددة'
              : widget.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: _isSelectionMode 
            ? [
                IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: _selectedChurches.isNotEmpty ? _saveSelectedChurches : null,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedChurches.clear();
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.check_box),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCollectionData,
                ),
              ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _documents.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد بيانات متاحة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      final churchName = doc['churchName'] ?? 'غير محدد';
                      final total = "%${(100 * (doc['percent'] ?? 5)).toStringAsFixed(2)}";
                      final documentCount = doc['documentCount'] ?? 1;
                      final isWinner = index == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedChurches.contains(churchName) && _isSelectionMode
                              ? Colors.orange.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isWinner
                              ? Border.all(color: Colors.amber, width: 2)
                              : _selectedChurches.contains(churchName) && _isSelectionMode
                                  ? Border.all(color: Colors.orange.shade300, width: 2)
                                  : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: _isSelectionMode 
                              ? () {
                                  setState(() {
                                    if (_selectedChurches.contains(churchName)) {
                                      _selectedChurches.remove(churchName);
                                    } else {
                                      _selectedChurches.add(churchName);
                                    }
                                  });
                                }
                              : null,
                          child: Row(
                            children: [
                              // Selection checkbox (only in selection mode)
                              if (_isSelectionMode) ...[
                                Checkbox(
                                  value: _selectedChurches.contains(churchName),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedChurches.add(churchName);
                                      } else {
                                        _selectedChurches.remove(churchName);
                                      }
                                    });
                                  },
                                  activeColor: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                              ],
                              
                              // Rank Badge
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
                                      ? const Icon(
                                          Icons.emoji_events,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: index <= 2
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Church Name
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isSelectionMode 
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChurchDetailsScreen(
                                                churchName: churchName,
                                                collectionName: widget.collectionName,
                                              ),
                                            ),
                                          );
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
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
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                                color: Colors.grey.shade400,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (isWinner) ...[
                                          Text(
                                            '🏆 الفائز الأول (متوسط من $documentCount استمارة)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ] else ...[
                                          Text(
                                            _isSelectionMode 
                                                ? 'متوسط من $documentCount استمارة'
                                                : 'متوسط من $documentCount استمارة - انقر للتفاصيل',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Total Score
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isWinner
                                      ? Colors.amber.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      total,
                                      style: TextStyle(
                                        color: isWinner
                                            ? Colors.amber.shade700
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'متوسط',
                                      style: TextStyle(
                                        color: isWinner
                                            ? Colors.amber.shade600
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
  State<SelectedChurchesDisplayScreen> createState() => _SelectedChurchesDisplayScreenState();
}

class _SelectedChurchesDisplayScreenState extends State<SelectedChurchesDisplayScreen> {
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
                      key: _globalKey,
                      child: _buildCertificateDesign()
                  ),
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
                        _isLoading ? 'جاري الحفظ...' : 'حفظ في المعرض وإضافة للمجموعات',
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  height: widget.selectedChurches.length * 42.0, // Approximate height per item
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
      case 'kg1': return 'حضانة المستوى الأول';
      case 'kg2': return 'حضانة المستوى الثاني';
      case 'kgG': return 'حضانة موهوبين جماعي';
      case 'kgF': return 'حضانة موهوبين فردي';
      case 'oulaTanya1': return 'أولى وثانية المستوى الأول';
      case 'oulaTanya2': return 'أولى وثانية المستوى الثاني';
      case 'oulaTanyaG': return 'أولى وثانية موهوبين جماعي';
      case 'oulaTanyaF': return 'أولى وثانية موهوبين فردي';
      case 'taltaRaba1': return 'ثالثة ورابعة المستوى الأول';
      case 'taltaRaba2': return 'ثالثة ورابعة المستوى الثاني';
      case 'taltaRabaG': return 'ثالثة ورابعة موهوبين جماعي';
      case 'taltaRabaF': return 'ثالثة ورابعة موهوبين فردي';
      case 'khamsaSadsa1': return 'خامسة وسادسة المستوى الأول';
      case 'khamsaSadsa2': return 'خامسة وسادسة المستوى الثاني';
      case 'khamsaSadsaG': return 'خامسة وسادسة موهوبين جماعي';
      case 'khamsaSadsaF': return 'خامسة وسادسة موهوبين فردي';
      default: return name;
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
      await Future.delayed(const Duration(milliseconds: 100)); // Ensure build is complete
      final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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
      print("Error capturing screenshot: $e");
      rethrow;
    }
  }

}

