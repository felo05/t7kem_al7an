import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    'kg1Results',
    'kg2Results',
    'kgGResults',
    'kgFResults',
    'oulaTanya1Results',
    'oulaTanya2Results',
    'oulaTanyaGResults',
    'oulaTanyaFResults',
    'taltaRaba1Results',
    'taltaRaba2Results',
    'taltaRabaGResults',
    'taltaRabaFResults',
    'khamsaSadsa1Results',
    'khamsaSadsa2Results',
    'khamsaSadsaGResults',
    'khamsaSadsaFResults',
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
          for (var doc in documents) {
            totalSum += (doc['percent'] as num).toDouble();
          }
          double average = totalSum / documents.length;

          if (average > highestAverage) {
            highestAverage = average;
            topChurch = churchName;
            topData =
                documents.first['data']; // Use first document data as reference
          }
        }

        _collectionMaxData[collectionName] = {
          'docId': 'Average',
          'percent': highestAverage,
          'church': topChurch,
          'data': topData,
          'churchGroups': churchGroups,
        };
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Container(
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
            mainAxisSpacing: 20,
            childAspectRatio: 1.07,
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
              color: Colors.black.withOpacity(0.05),
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
    String name = collection.replaceAll('Results', '');
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
        //print(data['percent'] ?? 10);
        final churchName = data['churchName'] ?? data['church'] ?? 'غير محدد';
        print(churchName);
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
          'data':
              documents.first['data'], // Use first document data as reference
          'allDocuments': documents, // Store all documents for this church
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.displayName,
          style: const TextStyle(
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadCollectionData,
          ),
        ],
      ),
      body: Container(
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
                      final total =
                          "%${(100 * (doc['percent'] ?? 5)).toStringAsFixed(2)}";
                      final documentCount = doc['documentCount'] ?? 1;
                      final isWinner = index == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isWinner
                              ? Border.all(color: Colors.amber, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
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
                                onTap: () {
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: isWinner
                                                    ? Colors.amber.shade700
                                                    : Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
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
                                          'متوسط من $documentCount استمارة - انقر للتفاصيل',
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
                                    ? Colors.amber.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
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
                      );
                    },
                  ),
      ),
    );
  }
}
