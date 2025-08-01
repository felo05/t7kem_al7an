import 'package:flutter/material.dart';
import 'package:t7kem_al7an/utils/final_collections_initializer.dart';

/// Debug screen for managing final collections
/// This screen allows administrators to check status and manage final collections
class FinalCollectionsDebugScreen extends StatefulWidget {
  const FinalCollectionsDebugScreen({super.key});

  @override
  State<FinalCollectionsDebugScreen> createState() => _FinalCollectionsDebugScreenState();
}

class _FinalCollectionsDebugScreenState extends State<FinalCollectionsDebugScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _status;
  String? _lastAction;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _lastAction = 'جاري فحص الحالة...';
    });

    try {
      final status = await FinalCollectionsInitializer.getInitializationStatus();
      setState(() {
        _status = status;
        _lastAction = 'تم فحص الحالة بنجاح';
      });
    } catch (e) {
      setState(() {
        _lastAction = 'خطأ في فحص الحالة: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeCollections() async {
    setState(() {
      _isLoading = true;
      _lastAction = 'جاري إنشاء المجموعات...';
    });

    try {
      final success = await FinalCollectionsInitializer.initializeFinalCollections();
      setState(() {
        _lastAction = success ? 'تم إنشاء المجموعات بنجاح' : 'فشل في إنشاء بعض المجموعات';
      });
      await _checkStatus();
    } catch (e) {
      setState(() {
        _lastAction = 'خطأ في إنشاء المجموعات: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forceReinitialize() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إعادة التهيئة'),
        content: const Text(
          'هل أنت متأكد من إعادة تهيئة جميع مجموعات النتائج النهائية؟\n'
          'هذا سيؤثر على البيانات الموجودة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _lastAction = 'جاري إعادة التهيئة...';
    });

    try {
      final success = await FinalCollectionsInitializer.forceReinitialize();
      setState(() {
        _lastAction = success ? 'تم إعادة التهيئة بنجاح' : 'فشل في إعادة التهيئة';
      });
      await _checkStatus();
    } catch (e) {
      setState(() {
        _lastAction = 'خطأ في إعادة التهيئة: $e';
      });
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
        title: const Text('إدارة مجموعات النتائج النهائية'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حالة المجموعات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_status != null) ...[
                      _buildStatusRow(
                        'مُهيّأة', 
                        _status!['isInitialized'] == true,
                      ),
                      _buildStatusRow(
                        'مُتحقق منها', 
                        _status!['isVerified'] == true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'العدد الإجمالي: ${_status!['totalCollections']} مجموعة',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (_status!['error'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'خطأ: ${_status!['error']}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ] else ...[
                      const Text('جاري التحميل...'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الإجراءات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _checkStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text('فحص الحالة'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _initializeCollections,
                        icon: const Icon(Icons.add_circle),
                        label: const Text('إنشاء المجموعات'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _forceReinitialize,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('إعادة التهيئة (إجباري)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Last Action
            if (_lastAction != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'آخر إجراء',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_lastAction!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Collection Names
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أسماء المجموعات (16 مجموعة)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: FinalCollectionsInitializer.getFinalCollectionNames().length,
                          itemBuilder: (context, index) {
                            final collectionName = FinalCollectionsInitializer.getFinalCollectionNames()[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                '${index + 1}. $collectionName',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading Indicator
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
