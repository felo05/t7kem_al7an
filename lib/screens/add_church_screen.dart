import 'package:flutter/material.dart';
import '../widgets/custom_toggle_widget.dart';
import '../widgets/dynamic_input_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddChurchScreen extends StatefulWidget {
  const AddChurchScreen({super.key});

  @override
  State<AddChurchScreen> createState() => _AddChurchScreenState();
}

class _AddChurchScreenState extends State<AddChurchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _churchNameController = TextEditingController();
  // Day selection
  String? _selectedDay;
  final List<String> _availableDays = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الخميس',
    'السبت (النهائي)'
  ];
  bool _isLoading = false;
  bool _isKG1 = false; // Toggle button state
  bool _isKg2 = false; // Toggle button state
  bool _isKgG = false; // Toggle button state
  bool _isOulaTanya1 = false; // Toggle button state
  bool _isOulaTanya2 = false; // Toggle button state
  bool _isOulaTanyaG = false; // Toggle button state
  bool _isTaltaRaba1 = false; // Toggle button state
  bool _isTaltaRaba2 = false; // Toggle button state
  bool _isTaltaRabaG = false; // Toggle button state
  bool _isKhamsaSadsa1 = false; // Toggle button state
  bool _isKhamsaSadsa2 = false; // Toggle button state
  bool _isKhamsaSadsaG = false; // Toggle button state

  // For dynamic entries
  List<String> _kg = [];
  List<String> _oulaTanya = [];
  List<String> _taltaRaba = [];
  List<String> _khamsaSadsa = [];
  @override
  void dispose() {
    _churchNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أضف اللجان',
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
      body: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
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
                          Icons.church,
                          size: 64,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'تسجيل لجان الكنيسة',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30), // Day selection dropdown
                  Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'اختر اليوم',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedDay,
                              decoration: InputDecoration(
                                hintText: 'اختر اليوم...',
                                prefixIcon: Icon(
                                  Icons.calendar_month,
                                  color: Colors.green.shade700,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.green.shade700, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                fillColor: Colors.grey.shade50,
                                filled: true,
                              ),
                              items: _availableDays.map((String day) {
                                return DropdownMenuItem<String>(
                                  value: day,
                                  child: Text(
                                    day,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDay = newValue;
                                });
                              },
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _churchNameController,
                    label: 'اسم الكنيسة',
                    icon: Icons.church,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'برجاء ادخال اسم الكنيسة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Toggle Button for Church Status
                  CustomToggleWidget(
                    text: 'حضانة المستوى الأول',
                    value: _isKG1,
                    onChanged: (value) {
                      setState(() {
                        _isKG1 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'حضانة المستوى الثاني',
                    value: _isKg2,
                    onChanged: (value) {
                      setState(() {
                        _isKg2 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'حضانة موهوبين جماعي ',
                    value: _isKgG,
                    onChanged: (value) {
                      setState(() {
                        _isKgG = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Dynamic Input Widget for Custom Entries
                  DynamicInputWidget(
                    title: 'حضانة موهوبين فردي ',
                    initialItems: _kg,
                    onItemsChanged: (items) {
                      setState(() {
                        _kg = items;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'أولى وثانية المستوى الأول',
                    value: _isOulaTanya1,
                    onChanged: (value) {
                      setState(() {
                        _isOulaTanya1 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'أولى وثانية المستوى الثاني',
                    value: _isOulaTanya2,
                    onChanged: (value) {
                      setState(() {
                        _isOulaTanya2 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'أولى وثانية موهوبين جماعي ',
                    value: _isOulaTanyaG,
                    onChanged: (value) {
                      setState(() {
                        _isOulaTanyaG = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Dynamic Input Widget for Custom Entries
                  DynamicInputWidget(
                    title: 'أولى وثانية موهوبين فردي ',
                    initialItems: _oulaTanya,
                    onItemsChanged: (items) {
                      setState(() {
                        _oulaTanya = items;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'ثالثة ورابعة المستوى الأول',
                    value: _isTaltaRaba1,
                    onChanged: (value) {
                      setState(() {
                        _isTaltaRaba1 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'ثالثة ورابعة المستوى الثاني',
                    value: _isTaltaRaba2,
                    onChanged: (value) {
                      setState(() {
                        _isTaltaRaba2 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'ثالثة ورابعة موهوبين جماعي ',
                    value: _isTaltaRabaG,
                    onChanged: (value) {
                      setState(() {
                        _isTaltaRabaG = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  DynamicInputWidget(
                    title: 'ثالثة ورابعة موهوبين فردي ',
                    initialItems: _taltaRaba,
                    onItemsChanged: (items) {
                      setState(() {
                        _taltaRaba = items;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'خامسة وسادسة المستوى الأول',
                    value: _isKhamsaSadsa1,
                    onChanged: (value) {
                      setState(() {
                        _isKhamsaSadsa1 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'خامسة وسادسة المستوى الثاني',
                    value: _isKhamsaSadsa2,
                    onChanged: (value) {
                      setState(() {
                        _isKhamsaSadsa2 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomToggleWidget(
                    text: 'خامسة وسادسة موهوبين جماعي ',
                    value: _isKhamsaSadsaG,
                    onChanged: (value) {
                      setState(() {
                        _isKhamsaSadsaG = value;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  // Dynamic Input Widget for Custom Entries
                  DynamicInputWidget(
                    title: 'خامسة وسادسة موهوبين فردي ',
                    initialItems: _khamsaSadsa,
                    onItemsChanged: (items) {
                      setState(() {
                        _khamsaSadsa = items;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'أضف الكنيسة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

    void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار اليوم أولاً'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
  
      setState(() {
        _isLoading = true;
      });
  
      try {
        final String churchName = _churchNameController.text.trim();
        
        // Convert Arabic day to English for document ID
        String dayId = _convertDayToEnglish(_selectedDay!);
        
        // Map of booleans to collection names
        Map<String, bool> categoryMappings = {
          'kg1': _isKG1,
          'kg2': _isKg2,
          'kgG': _isKgG,
          'oulaTanya1': _isOulaTanya1,
          'oulaTanya2': _isOulaTanya2,
          'oulaTanyaG': _isOulaTanyaG,
          'taltaRaba1': _isTaltaRaba1,
          'taltaRaba2': _isTaltaRaba2,
          'taltaRabaG': _isTaltaRabaG,
          'khamsaSadsa1': _isKhamsaSadsa1,
          'khamsaSadsa2': _isKhamsaSadsa2,
          'khamsaSadsaG': _isKhamsaSadsaG,
        };
  
        // Update Firestore collections for each true boolean
        for (String collectionName in categoryMappings.keys) {
          if (categoryMappings[collectionName] == true) {
            await _addChurchToCollection(collectionName, dayId, churchName);
          }
        }
  
        // Also handle dynamic input arrays
        await _handleDynamicInputs(dayId, churchName);
  
        // Prepare church data for main churches collection
        Map<String, dynamic> churchData = {
          'day': _selectedDay,
          'churchName': churchName,
          'categories': {
            'nursery': {
              'level1': _isKG1,
              'level2': _isKg2,
              'giftedGroup': _isKgG,
              'giftedIndividual': _kg.where((item) => item.isNotEmpty).toList(),
            },
            'firstSecond': {
              'level1': _isOulaTanya1,
              'level2': _isOulaTanya2,
              'giftedGroup': _isOulaTanyaG,
              'giftedIndividual': _oulaTanya.where((item) => item.isNotEmpty).toList(),
            },
            'thirdFourth': {
              'level1': _isTaltaRaba1,
              'level2': _isTaltaRaba2,
              'giftedGroup': _isTaltaRabaG,
              'giftedIndividual': _taltaRaba.where((item) => item.isNotEmpty).toList(),
            },
            'fifthSixth': {
              'level1': _isKhamsaSadsa1,
              'level2': _isKhamsaSadsa2,
              'giftedGroup': _isKhamsaSadsaG,
              'giftedIndividual': _khamsaSadsa.where((item) => item.isNotEmpty).toList(),
            },
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
  
        // Add church to main churches collection
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('churches')
            .add(churchData);
  
        setState(() {
          _isLoading = false;
        });
  
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Church "$churchName" registered successfully for $_selectedDay!\nDocument ID: ${docRef.id}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
  
          // Clear form
          _clearForm();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
  
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving church: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
  
  Future<void> _addChurchToCollection(String collectionName, String dayId, String churchName) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(dayId);
  
      await docRef.update({
        'churches': FieldValue.arrayUnion([churchName]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
  
      print('Added $churchName to $collectionName collection for $dayId');
    } catch (e) {
      print('Error adding church to $collectionName: $e');
      // If document doesn't exist, create it
      try {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(dayId)
            .set({
          'day': dayId,
          'judges': [],
          'churches': [churchName],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Created new document and added $churchName to $collectionName for $dayId');
      } catch (createError) {
        print('Error creating document: $createError');
      }
    }
  }
  
  Future<void> _handleDynamicInputs(String dayId, String churchName) async {
    // Handle dynamic input arrays for individual gifted categories
    if (_kg.isNotEmpty) {
      for (String childName in _kg) {
        await _addChurchToCollection('kgF', dayId, '$churchName - $childName');
      }
    }
    
    if (_oulaTanya.isNotEmpty) {
      for (String childName in _oulaTanya) {
        await _addChurchToCollection('oulaTanyaF', dayId, '$churchName - $childName');
      }
    }
    
    if (_taltaRaba.isNotEmpty) {
      for (String childName in _taltaRaba) {
        await _addChurchToCollection('taltaRabaF', dayId, '$churchName - $childName');
      }
    }
    
    if (_khamsaSadsa.isNotEmpty) {
      for (String childName in _khamsaSadsa) {
        await _addChurchToCollection('khamsaSadsaF', dayId, '$churchName - $childName');
      }
    }
  }
  
  String _convertDayToEnglish(String arabicDay) {
    Map<String, String> dayMapping = {
      'السبت': 'saturday',
      'الأحد': 'sunday',
      'الإثنين': 'monday',
      'الثلاثاء': 'tuesday',
      'الأربعاء': 'wednesday',
      'الخميس': 'thursday',
      'الجمعة': 'friday',
      'السبت (النهائي)': 'final',
    };
    return dayMapping[arabicDay] ?? 'saturday';
  }
  
  void _clearForm() {
    _churchNameController.clear();
    setState(() {
      _selectedDay = null;
      _isKG1 = false;
      _isKg2 = false;
      _isKgG = false;
      _isOulaTanya1 = false;
      _isOulaTanya2 = false;
      _isOulaTanyaG = false;
      _isTaltaRaba1 = false;
      _isTaltaRaba2 = false;
      _isTaltaRabaG = false;
      _isKhamsaSadsa1 = false;
      _isKhamsaSadsa2 = false;
      _isKhamsaSadsaG = false;
      _kg.clear();
      _oulaTanya.clear();
      _taltaRaba.clear();
      _khamsaSadsa.clear();
    });
  }
}
