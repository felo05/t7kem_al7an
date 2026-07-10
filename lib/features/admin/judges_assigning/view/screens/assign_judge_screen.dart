import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/judges_assigning/view_model/get_judges/get_judges_cubit.dart';
import 'package:t7kem_al7an/features/admin/judges_assigning/view_model/judges_assigning/judges_assigning_cubit.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';
import '../../../../../core/di/service_locator.dart';
import '../../model/assign_judge_days.dart';
import '/core/widgets/dynamic_dropdown_widget.dart';

class AssignJudgeScreen extends StatelessWidget {
  const AssignJudgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => GetJudgesCubit(sl<IAdminRepository>())..fetch()),
        BlocProvider(
            create: (_) => JudgesAssigningCubit(sl<IAdminRepository>())),
      ],
      child: const _AssignJudgeBody(),
    );
  }
}

class _AssignJudgeBody extends StatefulWidget {
  const _AssignJudgeBody();

  @override
  State<_AssignJudgeBody> createState() => _AssignJudgeBodyState();
}

class _AssignJudgeBodyState extends State<_AssignJudgeBody> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDay;
  final List<String> _availableDays = AssignJudgeDays.availableDays;

  final _selectedKg1 = ValueNotifier<List<String>>([]);
  final _selectedKg2 = ValueNotifier<List<String>>([]);
  final _selectedKgG = ValueNotifier<List<String>>([]);
  final _selectedKgF = ValueNotifier<List<String>>([]);
  final _selectedOulaTanya1 = ValueNotifier<List<String>>([]);
  final _selectedOulaTanya2 = ValueNotifier<List<String>>([]);
  final _selectedOulaTanyaG = ValueNotifier<List<String>>([]);
  final _selectedOulaTanyaF = ValueNotifier<List<String>>([]);
  final _selectedTaltaRaba1 = ValueNotifier<List<String>>([]);
  final _selectedTaltaRaba2 = ValueNotifier<List<String>>([]);
  final _selectedTaltaRabaG = ValueNotifier<List<String>>([]);
  final _selectedTaltaRabaF = ValueNotifier<List<String>>([]);
  final _selectedKhamsaSadsa1 = ValueNotifier<List<String>>([]);
  final _selectedKhamsaSadsa2 = ValueNotifier<List<String>>([]);
  final _selectedKhamsaSadsaG = ValueNotifier<List<String>>([]);
  final _selectedKhamsaSadsaF = ValueNotifier<List<String>>([]);

  List<ValueNotifier<List<String>>> get _allNotifiers => [
        _selectedKg1,
        _selectedKg2,
        _selectedKgG,
        _selectedKgF,
        _selectedOulaTanya1,
        _selectedOulaTanya2,
        _selectedOulaTanyaG,
        _selectedOulaTanyaF,
        _selectedTaltaRaba1,
        _selectedTaltaRaba2,
        _selectedTaltaRabaG,
        _selectedTaltaRabaF,
        _selectedKhamsaSadsa1,
        _selectedKhamsaSadsa2,
        _selectedKhamsaSadsaG,
        _selectedKhamsaSadsaF,
      ];

  @override
  void dispose() {
    for (final n in _allNotifiers) {
      n.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    if (_selectedDay == null || _selectedDay!.isEmpty) {
      _showErrorMessage('يرجى اختيار اليوم أولاً');
      return;
    }

    final judgeMappings = {
      'kg1': _selectedKg1.value,
      'kg2': _selectedKg2.value,
      'kgG': _selectedKgG.value,
      'kgF': _selectedKgF.value,
      'oulaTanya1': _selectedOulaTanya1.value,
      'oulaTanya2': _selectedOulaTanya2.value,
      'oulaTanyaG': _selectedOulaTanyaG.value,
      'oulaTanyaF': _selectedOulaTanyaF.value,
      'taltaRaba1': _selectedTaltaRaba1.value,
      'taltaRaba2': _selectedTaltaRaba2.value,
      'taltaRabaG': _selectedTaltaRabaG.value,
      'taltaRabaF': _selectedTaltaRabaF.value,
      'khamsaSadsa1': _selectedKhamsaSadsa1.value,
      'khamsaSadsa2': _selectedKhamsaSadsa2.value,
      'khamsaSadsaG': _selectedKhamsaSadsaG.value,
      'khamsaSadsaF': _selectedKhamsaSadsaF.value,
    };

    context.read<JudgesAssigningCubit>().submit(
          selectedDayArabic: _selectedDay!,
          judgeMappings: judgeMappings,
        );
  }

  void _clearForm() {
    for (final n in _allNotifiers) {
      n.value = [];
    }
    setState(() {
      _selectedDay = null;
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildJudgeDropdown({
    required String title,
    required List<String> userNames,
    required ValueNotifier<List<String>> notifier,
  }) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier,
      builder: (context, selected, _) {
        return DynamicDropdownWidget(
          title: title,
          dropdownItems: userNames,
          initialSelectedItems: selected,
          onItemsChanged: (items) => notifier.value = items,
          primaryColor: Colors.purple.shade700,
          dropdownIcon: Icons.person,
          itemIcon: Icons.person,
          hintText: 'اختر اسم المحكم...',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GetJudgesCubit, GetJudgesState>(
          listener: (context, state) {
            if (state is GetJudgesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('خطأ في تحميل أسماء المحكمين: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
        BlocListener<JudgesAssigningCubit, JudgesAssigningState>(
          listener: (context, state) {
            if (state is JudgesAssigningSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل المحكمين بنجاح!'),
                  backgroundColor: Colors.purple,
                  duration: Duration(seconds: 3),
                ),
              );
              _clearForm();
            } else if (state is JudgesAssigningError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('حدث خطأ أثناء تسجيل المحكمين: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تسكين المحكمين',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              colors: [Colors.purple.shade700, Colors.purple.shade50],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<GetJudgesCubit, GetJudgesState>(
              builder: (context, namesState) {
                if (namesState is GetJudgesLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل أسماء المحكمين...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final userNames = namesState is GetJudgesSuccess
                    ? namesState.judges
                    : <String>[];

                return SingleChildScrollView(
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
                              Icon(Icons.person,
                                  size: 64, color: Colors.purple.shade700),
                              const SizedBox(height: 16),
                              const Text(
                                'تسكين المحكمين',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
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
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedDay,
                                    decoration: InputDecoration(
                                      hintText: 'اختر اليوم...',
                                      prefixIcon: Icon(Icons.person,
                                          color: Colors.purple.shade700),
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
                                              horizontal: 12, vertical: 12),
                                      fillColor: Colors.grey.shade50,
                                      filled: true,
                                    ),
                                    items: _availableDays.map((String day) {
                                      return DropdownMenuItem<String>(
                                        value: day,
                                        child: Text(day,
                                            style:
                                                const TextStyle(fontSize: 14)),
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
                        const SizedBox(height: 20),
                        _buildJudgeDropdown(
                            title: 'حضانة المستوى الأول',
                            userNames: userNames,
                            notifier: _selectedKg1),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'حضانة المستوى الثاني',
                            userNames: userNames,
                            notifier: _selectedKg2),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'حضانة موهوبين جماعي ',
                            userNames: userNames,
                            notifier: _selectedKgG),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'حضانة موهوبين فردي ',
                            userNames: userNames,
                            notifier: _selectedKgF),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'أولى وثانية المستوى الأول',
                            userNames: userNames,
                            notifier: _selectedOulaTanya1),
                        const SizedBox(height: 30),
                        _buildJudgeDropdown(
                            title: 'أولى وثانية المستوى الثاني',
                            userNames: userNames,
                            notifier: _selectedOulaTanya2),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'أولى وثانية موهوبين جماعي ',
                            userNames: userNames,
                            notifier: _selectedOulaTanyaG),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'أولى وثانية موهوبين فردي ',
                            userNames: userNames,
                            notifier: _selectedOulaTanyaF),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'ثالثة ورابعة المستوى الأول',
                            userNames: userNames,
                            notifier: _selectedTaltaRaba1),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'ثالثة ورابعة المستوى الثاني',
                            userNames: userNames,
                            notifier: _selectedTaltaRaba2),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'ثالثة ورابعة موهوبين جماعي ',
                            userNames: userNames,
                            notifier: _selectedTaltaRabaG),
                        const SizedBox(height: 30),
                        _buildJudgeDropdown(
                            title: 'ثالثة ورابعة موهوبين فردي ',
                            userNames: userNames,
                            notifier: _selectedTaltaRabaF),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'خامسة وسادسة المستوى الأول',
                            userNames: userNames,
                            notifier: _selectedKhamsaSadsa1),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'خامسة وسادسة المستوى الثاني',
                            userNames: userNames,
                            notifier: _selectedKhamsaSadsa2),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'خامسة وسادسة موهوبين جماعي ',
                            userNames: userNames,
                            notifier: _selectedKhamsaSadsaG),
                        const SizedBox(height: 16),
                        _buildJudgeDropdown(
                            title: 'خامسة وسادسة موهوبين فردي ',
                            userNames: userNames,
                            notifier: _selectedKhamsaSadsaF),
                        const SizedBox(height: 30),
                        BlocBuilder<JudgesAssigningCubit, JudgesAssigningState>(
                          builder: (context, submitState) {
                            final isLoading =
                                submitState is JudgesAssigningLoading;
                            return ElevatedButton(
                              onPressed: isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                      'تسجيل المحكمين',
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
