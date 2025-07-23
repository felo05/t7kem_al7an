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
    'kg1result',
    'kg2result', 
    'kgGresult',
    'kgFresult',
    'oulaTanya1result',
    'oulaTanya2result',
    'oulaTanyaGresult',
    'oulaTanyaFresult',
    'taltaRaba1result',
    'taltaRaba2result',
    'taltaRabaGresult',
    'taltaRabaFresult',
    'khamsaSadsa1result',
    'khamsaSadsa2result',
    'khamsaSadsaGresult',
    'khamsaSadsaFresult',
  ];

  // Store the maximum document data for each collection
  Map<String, Map<String, dynamic>> _collectionMaxData = {};

  // Mock data
  final Map<String, dynamic> _systemStats = {
    'totalChurches': 25,
    'totalJudges': 12,
    'activeCompetitions': 3,
    'completedCompetitions': 8,
    'totalParticipants': 150,
    'systemUptime': '99.8%',
  };

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'New Church Registered',
      'subtitle': 'St. Mary\'s Church - Cairo',
      'time': '2 hours ago',
      'icon': Icons.church,
      'color': Colors.green,
    },
    {
      'title': 'Judge Added',
      'subtitle': 'Father John - Hymns Specialist',
      'time': '5 hours ago',
      'icon': Icons.person_add,
      'color': Colors.blue,
    },
    {
      'title': 'Competition Started',
      'subtitle': 'Youth Hymn Competition 2025',
      'time': '1 day ago',
      'icon': Icons.play_arrow,
      'color': Colors.orange,
    },
    {
      'title': 'System Maintenance',
      'subtitle': 'Database optimization completed',
      'time': '2 days ago',
      'icon': Icons.build,
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _competitions = [
    {
      'name': 'Youth Hymn Competition 2025',
      'status': 'Active',
      'participants': 45,
      'judges': 5,
      'progress': 0.6,
      'endDate': '2025-08-15',
    },
    {
      'name': 'Biblical Knowledge Quiz',
      'status': 'Registration Open',
      'participants': 28,
      'judges': 3,
      'progress': 0.2,
      'endDate': '2025-09-01',
    },
    {
      'name': 'Spiritual Songs Festival',
      'status': 'Completed',
      'participants': 32,
      'judges': 4,
      'progress': 1.0,
      'endDate': '2025-06-30',
    },
  ];

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
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

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
            'total': data['total'] ?? 0,
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
            totalSum += (doc['total'] as num).toDouble();
          }
          double average = totalSum / documents.length;
          
          if (average > highestAverage) {
            highestAverage = average;
            topChurch = churchName;
            topData = documents.first['data']; // Use first document data as reference
          }
        }
        
        _collectionMaxData[collectionName] = {
          'docId': 'Average',
          'total': highestAverage.round(),
          'church': topChurch,
          'data': topData,
          'churchGroups': churchGroups, // Store all church data for details screen
        };
      } else {
        _collectionMaxData[collectionName] = {
          'docId': 'No Data',
          'total': 0,
          'church': 'لا توجد بيانات',
          'data': {},
          'churchGroups': {},
        };
      }
    } catch (e) {
      print('Error fetching $collectionName: $e');
      _collectionMaxData[collectionName] = {
        'docId': 'Error',
        'total': 0,
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
          'System Status',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Activity', icon: Icon(Icons.history)),
            Tab(text: 'Competitions', icon: Icon(Icons.emoji_events)),
          ],
        ),
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
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildActivityTab(),
                  _buildCompetitionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // const SizedBox(height: 20),
          // Container(
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(16),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         blurRadius: 10,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     children: [
          //       Icon(
          //         Icons.analytics,
          //         size: 64,
          //         color: Colors.orange.shade700,
          //       ),
          //       const SizedBox(height: 16),
          //       const Text(
          //         'System Overview',
          //         style: TextStyle(
          //           fontSize: 24,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.black87,
          //         ),
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         'Real-time system statistics and metrics',
          //         style: TextStyle(
          //           fontSize: 16,
          //           color: Colors.grey.shade600,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: _collections.map((collection) {
              final data = _collectionMaxData[collection];
              final displayName = _formatCollectionName(collection);
              final winnerChurch = data?['church'] ?? 'جاري التحميل...';
              final total = data?['total'] ?? 0;
              
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
          // const SizedBox(height: 20),
          // Container(
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(16),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         blurRadius: 10,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text(
          //         'System Health',
          //         style: TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.black87,
          //         ),
          //       ),
          //       const SizedBox(height: 16),
          //       Row(
          //         children: [
          //           const Icon(
          //             Icons.check_circle,
          //             color: Colors.green,
          //             size: 24,
          //           ),
          //           const SizedBox(width: 12),
          //           Text(
          //             'System Uptime: ${_systemStats['systemUptime']}',
          //             style: const TextStyle(
          //               fontSize: 16,
          //               color: Colors.black87,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 12),
          //       const Row(
          //         children: [
          //           Icon(
          //             Icons.storage,
          //             color: Colors.blue,
          //             size: 24,
          //           ),
          //           SizedBox(width: 12),
          //           Text(
          //             'Database: Operational',
          //             style: TextStyle(
          //               fontSize: 16,
          //               color: Colors.black87,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 12),
          //       const Row(
          //         children: [
          //           Icon(
          //             Icons.wifi,
          //             color: Colors.green,
          //             size: 24,
          //           ),
          //           SizedBox(width: 12),
          //           Text(
          //             'Network: Connected',
          //             style: TextStyle(
          //               fontSize: 16,
          //               color: Colors.black87,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Latest system activities and updates',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivities.length,
            itemBuilder: (context, index) {
              final activity = _recentActivities[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: activity['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      activity['icon'],
                      color: activity['color'],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    activity['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(activity['subtitle']),
                      const SizedBox(height: 4),
                      Text(
                        activity['time'],
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Competition Status',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track all competitions and their progress',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _competitions.length,
            itemBuilder: (context, index) {
              final competition = _competitions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            competition['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(competition['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            competition['status'],
                            style: TextStyle(
                              color: _getStatusColor(competition['status']),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.group, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${competition['participants']} participants',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${competition['judges']} judges',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: competition['progress'].toDouble(),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(competition['status']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(competition['progress'] * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'End Date: ${competition['endDate']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionStatCard(String title, String winnerChurch, String total, IconData icon, Color color, String collectionName) {
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
        padding: const EdgeInsets.all(12),
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
    String name = collection.replaceAll('Results', '').replaceAll('result', '');
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            size: 36,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Registration Open':
        return Colors.blue;
      case 'Completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

// New screen for collection details
class CollectionDetailsScreen extends StatefulWidget {
  final String collectionName;
  final String displayName;

  const CollectionDetailsScreen({
    super.key,
    required this.collectionName,
    required this.displayName,
  });

  @override
  State<CollectionDetailsScreen> createState() => _CollectionDetailsScreenState();
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
          'total': data['total'] ?? 0,
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
          totalSum += (doc['total'] as num).toDouble();
        }
        double average = totalSum / documents.length;
        
        _documents.add({
          'id': 'average_$churchName',
          'churchName': churchName,
          'total': average.round(),
          'documentCount': documents.length,
          'data': documents.first['data'], // Use first document data as reference
          'allDocuments': documents, // Store all documents for this church
        });
      }
      
      // Sort by average total descending
      _documents.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
      
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
                      final total = doc['total'] ?? 0;
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
                                          color: index <= 2 ? Colors.white : Colors.grey.shade600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Church Name and Info
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
                                                fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
                                                color: isWinner ? Colors.amber.shade700 : Colors.blue.shade700,
                                                decoration: TextDecoration.underline,
                                                decorationColor: isWinner ? Colors.amber.shade700 : Colors.blue.shade700,
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
                                          '🏆 الفائز الأول (متوسط من $documentCount مشاركة)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.amber.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          'متوسط من $documentCount مشاركة - انقر للتفاصيل',
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
                            
                            // Average Score
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
                                    '$total',
                                    style: TextStyle(
                                      color: isWinner ? Colors.amber.shade700 : Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'متوسط',
                                    style: TextStyle(
                                      color: isWinner ? Colors.amber.shade600 : Colors.grey.shade600,
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
