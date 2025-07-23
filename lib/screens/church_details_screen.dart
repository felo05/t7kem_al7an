import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChurchDetailsScreen extends StatefulWidget {
  final String churchName;
  final String collectionName;

  const ChurchDetailsScreen({
    super.key,
    required this.churchName,
    required this.collectionName,
  });

  @override
  State<ChurchDetailsScreen> createState() => _ChurchDetailsScreenState();
}

class _ChurchDetailsScreenState extends State<ChurchDetailsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _churchDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadChurchData();
  }

  Future<void> _loadChurchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First try with 'churchName' field
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .where('churchName', isEqualTo: widget.churchName)
          .get();

      // If no results, try with 'church' field
      if (snapshot.docs.isEmpty) {
        snapshot = await FirebaseFirestore.instance
            .collection(widget.collectionName)
            .where('church', isEqualTo: widget.churchName)
            .get();
      }

      // If still no results, try to find documents that contain the church name
      if (snapshot.docs.isEmpty) {
        // Get all documents and filter manually
        final allDocs = await FirebaseFirestore.instance
            .collection(widget.collectionName)
            .get();
        
        final filteredDocs = allDocs.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final churchName = data['churchName'] ?? data['church'] ?? '';
          return churchName.toString().contains(widget.churchName) || 
                 widget.churchName.contains(churchName.toString());
        }).toList();
        
        // Create a new QuerySnapshot-like structure
        _churchDocuments = filteredDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'total': data['total'] ?? 0,
            'data': data,
          };
        }).toList();
      } else {
        _churchDocuments = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'total': data['total'] ?? 0,
            'data': data,
          };
        }).toList();
      }

      // Sort by total descending
      _churchDocuments.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    } catch (e) {
      print('Error loading church data: $e');
      _churchDocuments = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _formatCollectionName(String collection) {
    String name = collection.replaceAll('Results', '');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.churchName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              _formatCollectionName(widget.collectionName),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChurchData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _churchDocuments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد نتائج لهذه الكنيسة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'في ${_formatCollectionName(widget.collectionName)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Summary Card
                      Container(
                        margin: const EdgeInsets.all(20),
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
                              Icons.church,
                              size: 48,
                              color: Colors.purple.shade700,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.churchName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_churchDocuments.length} نتيجة في ${_formatCollectionName(widget.collectionName)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_churchDocuments.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatChip(
                                    'أعلى نتيجة',
                                    '${_churchDocuments.first['total']}',
                                    Colors.green,
                                  ),
                                  _buildStatChip(
                                    'أقل نتيجة',
                                    '${_churchDocuments.last['total']}',
                                    Colors.orange,
                                  ),
                                  _buildStatChip(
                                    'المتوسط',
                                    '${(_churchDocuments.map((doc) => doc['total'] as int).reduce((a, b) => a + b) / _churchDocuments.length).round()}',
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Results List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _churchDocuments.length,
                          itemBuilder: (context, index) {
                            final doc = _churchDocuments[index];
                            final data = doc['data'] as Map<String, dynamic>;
                            final total = doc['total'] ?? 0;
                            final judge = data['judge'] ?? 'غير محدد';
                            final kidsTotal = data['kidsTotal'] ?? '';
                            final percent = data['percent'] ?? 0.0;
                            final isHighest = index == 0;
                            
                            // Extract hymn categories (exclude metadata fields)
                            final hymnCategories = <String, Map<String, dynamic>>{};
                            data.forEach((key, value) {
                              if (value is Map<String, dynamic> && 
                                  !['churchName', 'church', 'judge', 'kidsTotal', 'percent', 'total'].contains(key)) {
                                hymnCategories[key] = value;
                              }
                            });
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isHighest 
                                    ? Border.all(color: Colors.purple.shade300, width: 2)
                                    : null,
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
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: isHighest 
                                                  ? Colors.purple.shade700
                                                  : Colors.grey.shade400,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'نتيجة رقم ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isHighest 
                                                  ? Colors.purple.shade700 
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isHighest 
                                                  ? Colors.purple.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              'المجموع: $total',
                                              style: TextStyle(
                                                color: isHighest 
                                                    ? Colors.purple.shade700 
                                                    : Colors.grey.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _showEditDialog(context, doc, index),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  // Judge and Kids Info
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'المحكم: $judge',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                              if (kidsTotal.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'عدد الأطفال: $kidsTotal',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                ),
                                              ],
                                              if (percent > 0) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'النسبة: ${(percent * 100).toStringAsFixed(1)}%',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Hymn Categories
                                  if (hymnCategories.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Text(
                                      'تفاصيل الألحان والتراتيل:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...hymnCategories.entries.map((hymnEntry) {
                                      final hymnName = hymnEntry.key;
                                      final hymnScores = hymnEntry.value as Map<String, dynamic>;
                                      
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hymnName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: hymnScores.entries.map((scoreEntry) {
                                                return _buildDetailedScoreChip(
                                                  scoreEntry.key,
                                                  scoreEntry.value.toString(),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  
                                  if (data['notes'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'ملاحظات: ${data['notes']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedScoreChip(String label, String value) {
    Color color = Colors.orange;
    
    // Determine color based on the criteria
    if (label.contains('سلامة التسليم') || label.contains('الحفظ')) {
      color = Colors.green;
    } else if (label.contains('روحانية') || label.contains('جمال')) {
      color = Colors.purple;
    } else if (label.contains('السرعة') || label.contains('الايقاع')) {
      color = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> document, int index) {
    final data = Map<String, dynamic>.from(document['data'] as Map<String, dynamic>);
    final documentId = document['id'] as String;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditResultDialog(
          documentData: data,
          documentId: documentId,
          collectionName: widget.collectionName,
          onSaved: () {
            _loadChurchData(); // Refresh the data
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class EditResultDialog extends StatefulWidget {
  final Map<String, dynamic> documentData;
  final String documentId;
  final String collectionName;
  final VoidCallback onSaved;

  const EditResultDialog({
    super.key,
    required this.documentData,
    required this.documentId,
    required this.collectionName,
    required this.onSaved,
  });

  @override
  State<EditResultDialog> createState() => _EditResultDialogState();
}

class _EditResultDialogState extends State<EditResultDialog> {
  late Map<String, dynamic> _editedData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editedData = Map<String, dynamic>.from(widget.documentData);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          const Text('تعديل النتيجة'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Basic Info Section
              _buildSectionHeader('المعلومات الأساسية'),
              _buildTextField('اسم الكنيسة', 'churchName'),
              _buildTextField('المحكم', 'judge'),
              _buildTextField('عدد الأطفال', 'kidsTotal'),
              _buildTextField('النسبة المئوية', 'percent'),
              _buildTextField('المجموع الكلي', 'total'),
              
              const SizedBox(height: 16),
              
              // Hymn Categories Section
              _buildSectionHeader('الألحان والتراتيل'),
              ..._buildHymnCategoryEditors(),
              
              const SizedBox(height: 16),
              
              // Notes Section
              _buildSectionHeader('ملاحظات'),
              _buildTextField('ملاحظات', 'notes'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key) {
    final currentValue = _editedData[key]?.toString() ?? '';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: currentValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: (key == 'total' || key == 'percent' || key == 'kidsTotal') 
            ? TextInputType.number 
            : TextInputType.text,
        onChanged: (value) {
          setState(() {
            if (key == 'total') {
              _editedData[key] = int.tryParse(value) ?? 0;
            } else if (key == 'percent') {
              _editedData[key] = double.tryParse(value) ?? 0.0;
            } else if (key == 'kidsTotal') {
              // kidsTotal can be either string or number, handle both
              final intValue = int.tryParse(value);
              _editedData[key] = intValue ?? value;
            } else {
              _editedData[key] = value;
            }
          });
        },
      ),
    );
  }

  List<Widget> _buildHymnCategoryEditors() {
    List<Widget> editors = [];
    
    _editedData.forEach((key, value) {
      if (value is Map<String, dynamic> && 
          !['churchName', 'church', 'judge', 'kidsTotal', 'percent', 'total', 'notes'].contains(key)) {
        
        editors.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ...value.entries.map((scoreEntry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            scoreEntry.key,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: scoreEntry.value.toString(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            onChanged: (newValue) {
                              setState(() {
                                final hymnData = _editedData[key] as Map<String, dynamic>;
                                final numValue = double.tryParse(newValue);
                                if (numValue != null) {
                                  hymnData[scoreEntry.key] = numValue;
                                } else {
                                  // If parsing fails, keep the original value
                                  hymnData[scoreEntry.key] = scoreEntry.value;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }
    });
    
    return editors;
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate new total if hymn scores were changed
      double newTotal = 0;
      _editedData.forEach((key, value) {
        if (value is Map<String, dynamic> && 
            !['churchName', 'church', 'judge', 'kidsTotal', 'percent', 'total', 'notes'].contains(key)) {
          value.forEach((scoreKey, scoreValue) {
            // Handle both int and double values
            if (scoreValue is num) {
              newTotal += scoreValue.toDouble();
            } else if (scoreValue is String) {
              final parsedValue = double.tryParse(scoreValue);
              if (parsedValue != null) {
                newTotal += parsedValue;
              }
            }
          });
        }
      });
      
      if (newTotal > 0) {
        _editedData['total'] = newTotal.round();
      }

      // Ensure all numeric fields are properly typed
      if (_editedData['percent'] is String) {
        _editedData['percent'] = double.tryParse(_editedData['percent']) ?? 0.0;
      }
      
      if (_editedData['total'] is String) {
        _editedData['total'] = int.tryParse(_editedData['total']) ?? 0;
      }

      // Update the document in Firestore
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.documentId)
          .update(_editedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التغييرات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحفظ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}
