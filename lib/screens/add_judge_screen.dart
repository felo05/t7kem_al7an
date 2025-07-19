import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/dynamic_dropdown_widget.dart';

class AddJudgeScreen extends StatefulWidget {
  const AddJudgeScreen({super.key});

  @override
  State<AddJudgeScreen> createState() => _AddJudgeScreenState();
}

class _AddJudgeScreenState extends State<AddJudgeScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isLoadingUsers = true;
  List<String> _userNames = [];

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

  // Selected items lists
  List<String> _selectedKg1 = [];
  List<String> _selectedKg2 = [];
  List<String> _selectedKgG = [];
  List<String> _selectedKgF = [];
  List<String> _selectedOulaTanya1 = [];
  List<String> _selectedOulaTanya2 = [];
  List<String> _selectedOulaTanyaG = [];
  List<String> _selectedOulaTanyaF = [];
  List<String> _selectedTaltaRaba1 = [];
  List<String> _selectedTaltaRaba2 = [];
  List<String> _selectedTaltaRabaG = [];
  List<String> _selectedTaltaRabaF = [];
  List<String> _selectedKhamsaSadsa1 = [];
  List<String> _selectedKhamsaSadsa2 = [];
  List<String> _selectedKhamsaSadsaG = [];
  List<String> _selectedKhamsaSadsaF = [];

  @override
  void initState() {
    super.initState();
    _fetchUserNames();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserNames() async {
    try {
      setState(() {
        _isLoadingUsers = true;
      });

      // Fetch users from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final List<String> names = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('name') && data['name'] != null) {
          names.add(data['name'].toString());
        }
      }

      setState(() {
        _userNames = names;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل أسماء المحكمين: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أضف المحكمين',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple.shade700,
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
              Colors.purple.shade700,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoadingUsers
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل أسماء المحكمين...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
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
                                Icons.person,
                                size: 64,
                                color: Colors.purple.shade700,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'تسجيل المحكمين',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Day selection dropdown
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
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDay,
                                    decoration: InputDecoration(
                                      hintText: 'اختر اليوم...',
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Colors.purple.shade700,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.purple.shade700,
                                            width: 2),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                        const SizedBox(height: 20),

                        // Names from Firestore
                        DynamicDropdownWidget(
                          title: 'حضانة المستوى الأول',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKg1,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKg1 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Email addresses
                        DynamicDropdownWidget(
                          title: 'حضانة المستوى الثاني',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKg2,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKg2 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Phone numbers
                        DynamicDropdownWidget(
                          title: 'حضانة موهوبين جماعي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKgG,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKgG = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Categories
                        DynamicDropdownWidget(
                          title: 'حضانة موهوبين فردي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKgF,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKgF = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Experience years
                        DynamicDropdownWidget(
                          title: 'أولى وثانية المستوى الأول',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedOulaTanya1,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedOulaTanya1 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Additional expertise
                        DynamicDropdownWidget(
                          title: 'أولى وثانية المستوى الثاني',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedOulaTanya2,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedOulaTanya2 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 30),

                        // Names from Firestore
                        DynamicDropdownWidget(
                          title: 'أولى وثانية موهوبين جماعي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedOulaTanyaG,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedOulaTanyaG = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Email addresses
                        DynamicDropdownWidget(
                          title: 'أولى وثانية موهوبين فردي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedOulaTanyaF,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedOulaTanyaF = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Phone numbers
                        DynamicDropdownWidget(
                          title: 'ثالثة ورابعة المستوى الأول',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedTaltaRaba1,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedTaltaRaba1 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Categories
                        DynamicDropdownWidget(
                          title: 'ثالثة ورابعة المستوى الثاني',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedTaltaRaba2,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedTaltaRaba2 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Experience years
                        DynamicDropdownWidget(
                          title: 'ثالثة ورابعة موهوبين جماعي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedTaltaRabaG,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedTaltaRabaG = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Additional expertise
                        DynamicDropdownWidget(
                          title: 'ثالثة ورابعة موهوبين فردي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedTaltaRabaF,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedTaltaRabaF = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 30),

                        // Names from Firestore
                        DynamicDropdownWidget(
                          title: 'خامسة وسادسة المستوى الأول',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKhamsaSadsa1,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKhamsaSadsa1 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Email addresses
                        DynamicDropdownWidget(
                          title: 'خامسة وسادسة المستوى الثاني',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKhamsaSadsa2,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKhamsaSadsa2 = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Phone numbers
                        DynamicDropdownWidget(
                          title: 'خامسة وسادسة موهوبين جماعي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKhamsaSadsaG,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKhamsaSadsaG = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 16),

                        // Categories
                        DynamicDropdownWidget(
                          title: 'خامسة وسادسة موهوبين فردي ',
                          dropdownItems: _userNames,
                          initialSelectedItems: _selectedKhamsaSadsaF,
                          onItemsChanged: (items) {
                            setState(() {
                              _selectedKhamsaSadsaF = items;
                            });
                          },
                          primaryColor: Colors.purple.shade700,
                          dropdownIcon: Icons.person,
                          itemIcon: Icons.person,
                          hintText: 'اختر اسم المحكم...',
                        ),
                        const SizedBox(height: 30),

                        // Submit button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
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
                                  'تسجيل المحكمين',
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

    void _submitForm() async {
    // Validate that a day is selected
    if (_selectedDay == null || _selectedDay!.isEmpty) {
      _showErrorMessage('يرجى اختيار اليوم أولاً');
      return;
    }
  
    setState(() {
      _isLoading = true;
    });
  
    try {
      // Convert Arabic day to English for document ID
      String dayId = _convertDayToEnglish(_selectedDay!);
      
      // Map of judge lists to collection names
      Map<String, List<String>> judgeMappings = {
        'kg1': _selectedKg1,
        'kg2': _selectedKg2,
        'kgG': _selectedKgG,
        'kgF': _selectedKgF,
        'oulaTanya1': _selectedOulaTanya1,
        'oulaTanya2': _selectedOulaTanya2,
        'oulaTanyaG': _selectedOulaTanyaG,
        'oulaTanyaF': _selectedOulaTanyaF,
        'taltaRaba1': _selectedTaltaRaba1,
        'taltaRaba2': _selectedTaltaRaba2,
        'taltaRabaG': _selectedTaltaRabaG,
        'taltaRabaF': _selectedTaltaRabaF,
        'khamsaSadsa1': _selectedKhamsaSadsa1,
        'khamsaSadsa2': _selectedKhamsaSadsa2,
        'khamsaSadsaG': _selectedKhamsaSadsaG,
        'khamsaSadsaF': _selectedKhamsaSadsaF,
      };
  
      // Update Firestore collections for each list that has judges
      for (String collectionName in judgeMappings.keys) {
        List<String> judges = judgeMappings[collectionName]!;
        if (judges.isNotEmpty) {
          await _addJudgesToCollection(collectionName, dayId, judges);
        }
      }
  
      // Also save to main judges collection for backup/reference
      final judgeData = {
        'day': _selectedDay,
        'dayId': dayId,
        'kg1': _selectedKg1,
        'kg2': _selectedKg2,
        'kgG': _selectedKgG,
        'kgF': _selectedKgF,
        'oulaTanya1': _selectedOulaTanya1,
        'oulaTanya2': _selectedOulaTanya2,
        'oulaTanyaG': _selectedOulaTanyaG,
        'oulaTanyaF': _selectedOulaTanyaF,
        'taltaRaba1': _selectedTaltaRaba1,
        'taltaRaba2': _selectedTaltaRaba2,
        'taltaRabaG': _selectedTaltaRabaG,
        'taltaRabaF': _selectedTaltaRabaF,
        'khamsaSadsa1': _selectedKhamsaSadsa1,
        'khamsaSadsa2': _selectedKhamsaSadsa2,
        'khamsaSadsaG': _selectedKhamsaSadsaG,
        'khamsaSadsaF': _selectedKhamsaSadsaF,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
  
      await FirebaseFirestore.instance.collection('judges').add(judgeData);
  
      setState(() {
        _isLoading = false;
      });
  
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تسجيل المحكمين ليوم $_selectedDay بنجاح!'),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 3),
          ),
        );
  
        // Clear form
        _clearForm();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
  
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل المحكمين: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Future<void> _addJudgesToCollection(String collectionName, String dayId, List<String> judges) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(dayId);
  
      // Add judges to the judges array using arrayUnion to prevent duplicates
      await docRef.update({
        'judges': FieldValue.arrayUnion(judges),
        'updatedAt': FieldValue.serverTimestamp(),
      });
  
      print('Added ${judges.length} judges to $collectionName collection for $dayId');
    } catch (e) {
      print('Error adding judges to $collectionName: $e');
      // If document doesn't exist, create it
      try {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(dayId)
            .set({
          'day': dayId,
          'judges': judges,
          'churches': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Created new document and added ${judges.length} judges to $collectionName for $dayId');
      } catch (createError) {
        print('Error creating document: $createError');
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
      'السبت (النهائي)': 'saturday',
    };
    return dayMapping[arabicDay] ?? 'saturday';
  }
  
  void _clearForm() {
    setState(() {
      _selectedDay = null;
      _selectedKg1.clear();
      _selectedKg2.clear();
      _selectedKgG.clear();
      _selectedKgF.clear();
      _selectedOulaTanya1.clear();
      _selectedOulaTanya2.clear();
      _selectedOulaTanyaG.clear();
      _selectedOulaTanyaF.clear();
      _selectedTaltaRaba1.clear();
      _selectedTaltaRaba2.clear();
      _selectedTaltaRabaG.clear();
      _selectedTaltaRabaF.clear();
      _selectedKhamsaSadsa1.clear();
      _selectedKhamsaSadsa2.clear();
      _selectedKhamsaSadsaG.clear();
      _selectedKhamsaSadsaF.clear();
    });
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
