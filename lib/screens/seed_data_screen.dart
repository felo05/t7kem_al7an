import 'package:flutter/material.dart';
import '../utils/results_seeder.dart';

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  bool _isSeeding = false;
  String _status = 'جاهز لبدء إضافة البيانات التجريبية';

  Future<void> _seedData() async {
    setState(() {
      _isSeeding = true;
      _status = 'جاري إضافة البيانات التجريبية...';
    });

    try {
      await ResultsSeeder.seedAllCollections();
      setState(() {
        _status = '✅ تم إضافة البيانات التجريبية بنجاح!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في إضافة البيانات: $e';
      });
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  Future<void> _clearData() async {
    setState(() {
      _isSeeding = true;
      _status = 'جاري مسح البيانات...';
    });

    try {
      await ResultsSeeder.clearAllResultsCollections();
      setState(() {
        _status = '🧹 تم مسح جميع البيانات التجريبية!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في مسح البيانات: $e';
      });
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة البيانات التجريبية'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                        Icons.storage,
                        size: 48,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'إدارة البيانات التجريبية',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'إضافة بيانات تجريبية لاختبار شاشة حالة المسابقات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Status Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Seed Data Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding ? null : _seedData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    icon: _isSeeding 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add_circle_outline, size: 24),
                    label: Text(
                      _isSeeding ? 'جاري الإضافة...' : 'إضافة البيانات التجريبية',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Clear Data Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding ? null : _clearData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    icon: _isSeeding 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.delete_sweep, size: 24),
                    label: Text(
                      _isSeeding ? 'جاري المسح...' : 'مسح جميع البيانات التجريبية',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Information Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'معلومات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• سيتم إضافة 3-8 مستندات عشوائية لكل مجموعة\n'
                        '• المجموعات الـ16: kg1Results, kg2Results, etc.\n'
                        '• كل مستند يحتوي على: اسم المتسابق، الكنيسة، النقاط\n'
                        '• يمكنك اختبار شاشة "فحص الحالة" بعد إضافة البيانات',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text(
                      'العودة',
                      style: TextStyle(
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
    );
  }
}
