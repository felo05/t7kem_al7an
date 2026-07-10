import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/custom_form_field.dart';
import '../../model/add_church_form_data.dart';
import '../../model/church_days.dart';
import '../../view_model/add_churches_cubit.dart';
import '/core/widgets/custom_toggle_widget.dart';
import '/core/widgets/dynamic_input_widget.dart';

class AddChurchScreen extends StatelessWidget {
  const AddChurchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddChurchesCubit(sl<IAdminRepository>()),
      child: const _AddChurchBody(),
    );
  }
}

class _AddChurchBody extends StatefulWidget {
  const _AddChurchBody();

  @override
  State<_AddChurchBody> createState() => _AddChurchBodyState();
}

class _AddChurchBodyState extends State<_AddChurchBody> {
  final _formKey = GlobalKey<FormState>();
  final _churchNameController = TextEditingController();

  String? _selectedDay;
  final List<String> _availableDays = ChurchDays.availableDays;

  final _isKG1 = ValueNotifier<bool>(false);
  final _isKg2 = ValueNotifier<bool>(false);
  final _isKgG = ValueNotifier<bool>(false);
  final _isOulaTanya1 = ValueNotifier<bool>(false);
  final _isOulaTanya2 = ValueNotifier<bool>(false);
  final _isOulaTanyaG = ValueNotifier<bool>(false);
  final _isTaltaRaba1 = ValueNotifier<bool>(false);
  final _isTaltaRaba2 = ValueNotifier<bool>(false);
  final _isTaltaRabaG = ValueNotifier<bool>(false);
  final _isKhamsaSadsa1 = ValueNotifier<bool>(false);
  final _isKhamsaSadsa2 = ValueNotifier<bool>(false);
  final _isKhamsaSadsaG = ValueNotifier<bool>(false);

  List<String> _kg = [];
  List<String> _oulaTanya = [];
  List<String> _taltaRaba = [];
  List<String> _khamsaSadsa = [];

  @override
  void dispose() {
    _churchNameController.dispose();
    for (final n in [
      _isKG1,
      _isKg2,
      _isKgG,
      _isOulaTanya1,
      _isOulaTanya2,
      _isOulaTanyaG,
      _isTaltaRaba1,
      _isTaltaRaba2,
      _isTaltaRabaG,
      _isKhamsaSadsa1,
      _isKhamsaSadsa2,
      _isKhamsaSadsaG,
    ]) {
      n.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار اليوم أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = AddChurchFormData(
      churchName: _churchNameController.text.trim(),
      selectedDayArabic: _selectedDay!,
      categoryToggles: {
        'kg1': _isKG1.value,
        'kg2': _isKg2.value,
        'kgG': _isKgG.value,
        'oulaTanya1': _isOulaTanya1.value,
        'oulaTanya2': _isOulaTanya2.value,
        'oulaTanyaG': _isOulaTanyaG.value,
        'taltaRaba1': _isTaltaRaba1.value,
        'taltaRaba2': _isTaltaRaba2.value,
        'taltaRabaG': _isTaltaRabaG.value,
        'khamsaSadsa1': _isKhamsaSadsa1.value,
        'khamsaSadsa2': _isKhamsaSadsa2.value,
        'khamsaSadsaG': _isKhamsaSadsaG.value,
      },
      giftedIndividualLists: {
        'kg': _kg,
        'oulaTanya': _oulaTanya,
        'taltaRaba': _taltaRaba,
        'khamsaSadsa': _khamsaSadsa,
      },
    );

    context.read<AddChurchesCubit>().submit(data);
  }

  void _clearForm() {
    _churchNameController.clear();
    setState(() {
      _selectedDay = null;
      _isKG1.value = false;
      _isKg2.value = false;
      _isKgG.value = false;
      _isOulaTanya1.value = false;
      _isOulaTanya2.value = false;
      _isOulaTanyaG.value = false;
      _isTaltaRaba1.value = false;
      _isTaltaRaba2.value = false;
      _isTaltaRabaG.value = false;
      _isKhamsaSadsa1.value = false;
      _isKhamsaSadsa2.value = false;
      _isKhamsaSadsaG.value = false;
      _kg.clear();
      _oulaTanya.clear();
      _taltaRaba.clear();
      _khamsaSadsa.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddChurchesCubit, AddChurchesState>(
      listener: (context, state) {
        if (state is AddChurchesSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Church registered successfully!',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          _clearForm();
        } else if (state is AddChurchesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving church: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'أضف اللجان',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              colors: [Colors.green.shade700, Colors.green.shade50],
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.church,
                              size: 64, color: Colors.green.shade700),
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
                    const SizedBox(height: 30),
                    Container(
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
                                initialValue: _selectedDay,
                                decoration: InputDecoration(
                                  hintText: 'اختر اليوم...',
                                  prefixIcon: Icon(Icons.calendar_month,
                                      color: Colors.green.shade700),
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
                                      horizontal: 12, vertical: 12),
                                  fillColor: Colors.grey.shade50,
                                  filled: true,
                                ),
                                items: _availableDays.map((String day) {
                                  return DropdownMenuItem<String>(
                                    value: day,
                                    child: Text(day,
                                        style: const TextStyle(fontSize: 14)),
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
                                    color: Colors.black87, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      text: 'اسم الكنيسة',
                      controller: _churchNameController,
                      prefixIcon: Icons.church,
                      floatingLabel: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'برجاء ادخال اسم الكنيسة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomToggleWidget(
                      text: 'حضانة المستوى الأول',
                      valueListenable: _isKG1,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'حضانة المستوى الثاني',
                      valueListenable: _isKg2,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'حضانة موهوبين جماعي ',
                      valueListenable: _isKgG,
                    ),
                    const SizedBox(height: 8),
                    DynamicInputWidget(
                      title: 'حضانة موهوبين فردي ',
                      initialItems: _kg,
                      onItemsChanged: (items) => setState(() => _kg = items),
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'أولى وثانية المستوى الأول',
                      valueListenable: _isOulaTanya1,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'أولى وثانية المستوى الثاني',
                      valueListenable: _isOulaTanya2,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'أولى وثانية موهوبين جماعي ',
                      valueListenable: _isOulaTanyaG,
                    ),
                    const SizedBox(height: 8),
                    DynamicInputWidget(
                      title: 'أولى وثانية موهوبين فردي ',
                      initialItems: _oulaTanya,
                      onItemsChanged: (items) =>
                          setState(() => _oulaTanya = items),
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'ثالثة ورابعة المستوى الأول',
                      valueListenable: _isTaltaRaba1,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'ثالثة ورابعة المستوى الثاني',
                      valueListenable: _isTaltaRaba2,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'ثالثة ورابعة موهوبين جماعي ',
                      valueListenable: _isTaltaRabaG,
                    ),
                    const SizedBox(height: 8),
                    DynamicInputWidget(
                      title: 'ثالثة ورابعة موهوبين فردي ',
                      initialItems: _taltaRaba,
                      onItemsChanged: (items) =>
                          setState(() => _taltaRaba = items),
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'خامسة وسادسة المستوى الأول',
                      valueListenable: _isKhamsaSadsa1,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'خامسة وسادسة المستوى الثاني',
                      valueListenable: _isKhamsaSadsa2,
                    ),
                    const SizedBox(height: 8),
                    CustomToggleWidget(
                      text: 'خامسة وسادسة موهوبين جماعي ',
                      valueListenable: _isKhamsaSadsaG,
                    ),
                    const SizedBox(height: 8),
                    DynamicInputWidget(
                      title: 'خامسة وسادسة موهوبين فردي ',
                      initialItems: _khamsaSadsa,
                      onItemsChanged: (items) =>
                          setState(() => _khamsaSadsa = items),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AddChurchesCubit, AddChurchesState>(
                      builder: (context, state) {
                        final isLoading = state is AddChurchesLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'أضف الكنيسة',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
