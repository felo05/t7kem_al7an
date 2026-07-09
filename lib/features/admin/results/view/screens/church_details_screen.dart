import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/user/marks_forms/base_marks_form.dart';
import 'package:t7kem_al7an/features/user/marks_forms/form_screen.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../repository/i_admin_repository.dart';
import '../../model/church_result_doc.dart';
import '../../model/result_collections.dart';
import '../../view_model/church_results/church_results_cubit.dart';
import '../../view_model/delete_result/delete_result_cubit.dart';

class ChurchDetailsScreen extends StatelessWidget {
  final String churchName;
  final String collectionName;

  const ChurchDetailsScreen({super.key, required this.churchName, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChurchResultsCubit(sl<IAdminRepository>())..watch(collectionName, churchName)),
        BlocProvider(create: (_) => DeleteResultCubit(sl<IAdminRepository>())),
      ],
      child: _ChurchDetailsBody(churchName: churchName, collectionName: collectionName),
    );
  }
}

class _ChurchDetailsBody extends StatefulWidget {
  const _ChurchDetailsBody({required this.churchName, required this.collectionName});
  final String churchName;
  final String collectionName;

  @override
  State<_ChurchDetailsBody> createState() => _ChurchDetailsBodyState();
}

class _ChurchDetailsBodyState extends State<_ChurchDetailsBody> {
  BaseMarksFormModel? _buildEditFormModel(Map<String, dynamic> data) {
    final levelInArabic = ResultCollections.displayName(widget.collectionName);
    final builders = <String, BaseMarksFormModel Function()>{
      'kg1ResultsFinal': () => Kg1FormModel.fromJson(data, isKg: true, levelInArabic: levelInArabic),
      'oulaTanya1ResultsFinal': () => Kg1FormModel.fromJson(data, isKg: false, levelInArabic: levelInArabic),
      'kg2ResultsFinal': () => Kg2FormModel.fromJson(data, isKg: true, levelInArabic: levelInArabic),
      'oulaTanya2ResultsFinal': () => Kg2FormModel.fromJson(data, isKg: false, levelInArabic: levelInArabic),
      'taltaRaba1ResultsFinal': () => Talta1FormModel.fromJson(data, isTalta: true, levelInArabic: levelInArabic),
      'khamsaSadsa1ResultsFinal': () => Talta1FormModel.fromJson(data, isTalta: false, levelInArabic: levelInArabic),
      'taltaRaba2ResultsFinal': () => Talta2FormModel.fromJson(data, isTalta: true, levelInArabic: levelInArabic),
      'khamsaSadsa2ResultsFinal': () => Talta2FormModel.fromJson(data, isTalta: false, levelInArabic: levelInArabic),
      'kgFResultsFinal': () => MohobenIndividualFormModel.fromJson(data, level: 0, levelInArabic: levelInArabic),
      'oulaTanyaFResultsFinal': () => MohobenIndividualFormModel.fromJson(data, level: 1, levelInArabic: levelInArabic),
      'taltaRabaFResultsFinal': () => MohobenIndividualFormModel.fromJson(data, level: 2, levelInArabic: levelInArabic),
      'khamsaSadsaFResultsFinal': () => MohobenIndividualFormModel.fromJson(data, level: 3, levelInArabic: levelInArabic),
      'kgGResultsFinal': () => MohobenGroupFormModel.fromJson(data, level: 0, levelInArabic: levelInArabic),
      'oulaTanyaGResultsFinal': () => MohobenGroupFormModel.fromJson(data, level: 1, levelInArabic: levelInArabic),
      'taltaRabaGResultsFinal': () => MohobenGroupFormModel.fromJson(data, level: 2, levelInArabic: levelInArabic),
      'khamsaSadsaGResultsFinal': () => MohobenGroupFormModel.fromJson(data, level: 3, levelInArabic: levelInArabic),
    };
    return builders[widget.collectionName]?.call();
  }

  void _showEditDialog(BuildContext context, ChurchResultDoc doc) {
    final data = Map<String, dynamic>.from(doc.data);
    final formModel = _buildEditFormModel(data);

    if (formModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح نموذج التعديل لهذا المستوى'), backgroundColor: Colors.red));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FormScreen(
          form: formModel,
          judgeName: data['judge']?.toString(),
          captureOnSubmit: false,
          editCollectionName: widget.collectionName,
          editDocumentId: doc.id,
        ),
      ),
    );
    // no manual reload — the results stream reflects the edit automatically
  }

  void _showDeleteDialog(BuildContext context, ChurchResultDoc doc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه النتيجة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<DeleteResultCubit>().delete(widget.collectionName, doc.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteResultCubit, DeleteResultState>(
      listener: (context, state) {
        if (state is DeleteResultSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف النتيجة بنجاح'), backgroundColor: Colors.green));
        } else if (state is DeleteResultError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف: ${state.message}'), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(widget.churchName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              Text(ResultCollections.displayName(widget.collectionName), style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.purple.shade700, Colors.purple.shade50])),
          child: BlocBuilder<ChurchResultsCubit, ChurchResultsState>(
            builder: (context, state) {
              if (state is ChurchResultsLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              final documents = (state as ChurchResultsSuccess).documents;

              if (documents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.white.withValues(alpha: 0.7)),
                      const SizedBox(height: 16),
                      Text('لا توجد نتائج لهذه الكنيسة', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('في ${ResultCollections.displayName(widget.collectionName)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                    ],
                  ),
                );
              }

              final highest = documents.first.percent;
              final lowest = documents.last.percent;
              final average = documents.map((d) => 100 * d.percent).reduce((a, b) => a + b) / documents.length;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Column(
                      children: [
                        Icon(Icons.church, size: 48, color: Colors.purple.shade700),
                        const SizedBox(height: 12),
                        Text(widget.churchName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple.shade700), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text('${documents.length} نتيجة في ${ResultCollections.displayName(widget.collectionName)}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatChip('أعلى نتيجة', '%${(100 * highest).toStringAsFixed(2)}', Colors.green),
                            _buildStatChip('أقل نتيجة', '%${(100 * lowest).toStringAsFixed(2)}', Colors.orange),
                            _buildStatChip('المتوسط', '%${average.toStringAsFixed(2)}', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        final data = doc.data;
                        final total = data['total'] ?? 0;
                        final judge = data['judge'] ?? 'غير محدد';
                        final kidsTotal = data['kidsTotal'] ?? '';
                        final slok = data['slok'];
                        final taks = data['taks'];
                        final copticReading = data['copticReading'];
                        final percent = doc.percent;
                        final isHighest = index == 0;

                        final hymnCategories = <String, Map<String, dynamic>>{};
                        data.forEach((key, value) {
                          if (value is Map<String, dynamic> && !['churchName', 'church', 'judge', 'kidsTotal', 'percent', 'total'].contains(key)) {
                            hymnCategories[key] = value;
                          }
                        });

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isHighest ? Border.all(color: Colors.purple.shade300, width: 2) : null,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
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
                                        decoration: BoxDecoration(color: isHighest ? Colors.purple.shade700 : Colors.grey.shade400, borderRadius: BorderRadius.circular(12)),
                                        child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('نتيجة رقم ${index + 1}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isHighest ? Colors.purple.shade700 : Colors.black87)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: isHighest ? Colors.purple.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                                        child: Text('المجموع: $total', style: TextStyle(color: isHighest ? Colors.purple.shade700 : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showEditDialog(context, doc),
                                        child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit, size: 20, color: Colors.blue.shade700)),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showDeleteDialog(context, doc),
                                        child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete, size: 20, color: Colors.red.shade700)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('المحكم: $judge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue.shade700)),
                                          const SizedBox(height: 4),
                                          Text('عدد الأطفال: $kidsTotal', style: TextStyle(fontSize: 12, color: Colors.blue.shade600)),
                                          if (slok != null) ...[const SizedBox(height: 4), Text('السلوك: $slok', style: TextStyle(fontSize: 12, color: Colors.blue.shade600))],
                                          if (copticReading != null) ...[const SizedBox(height: 4), Text('قراءة القبطى: $copticReading', style: TextStyle(fontSize: 12, color: Colors.blue.shade600))],
                                          if (taks != null) ...[const SizedBox(height: 4), Text('الطقس: $taks', style: TextStyle(fontSize: 12, color: Colors.blue.shade600))],
                                          if (percent > 0) ...[const SizedBox(height: 4), Text('النسبة: ${(percent * 100).toStringAsFixed(2)}%', style: TextStyle(fontSize: 12, color: Colors.blue.shade600))],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (hymnCategories.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text('تفاصيل الألحان والتراتيل:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                                const SizedBox(height: 8),
                                ...hymnCategories.entries.map((hymnEntry) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(hymnEntry.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                        const SizedBox(height: 6),
                                        Wrap(spacing: 8, runSpacing: 4, children: hymnEntry.value.entries.map((e) => _buildDetailedScoreChip(e.key, e.value.toString())).toList()),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              if (data['notes'] != null) ...[
                                const SizedBox(height: 8),
                                Text('ملاحظات: ${data['notes']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    ]);
  }

  Widget _buildDetailedScoreChip(String label, String value) {
    var color = Colors.orange;
    if (label.contains('سلامة التسليم') || label.contains('الحفظ')) {
      color = Colors.green;
    } else if (label.contains('روحانية') || label.contains('جمال')) {
      color = Colors.purple;
    } else if (label.contains('السرعة') || label.contains('الايقاع')) {
      color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}