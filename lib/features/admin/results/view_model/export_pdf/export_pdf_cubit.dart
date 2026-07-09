import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../model/church_average_calculator.dart';
import '../../model/church_result_doc.dart';

part 'export_pdf_state.dart';

class ExportPdfCubit extends Cubit<ExportPdfState> {
  ExportPdfCubit() : super(ExportPdfInitial());

  Future<void> exportCollection({
    required String collectionName,
    required String displayName,
    required List<ChurchResultDoc> allDocs,
  }) async {
    emit(ExportPdfLoading());
    try {
      final logo1 = await rootBundle.load('assets/images/logo.png').then((d) => d.buffer.asUint8List());
      final logo2 = await rootBundle.load('assets/images/logo2.jpg').then((d) => d.buffer.asUint8List());
      final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
      final arabicBoldFont = await PdfGoogleFonts.notoSansArabicBold();

      final valid = ChurchAverageCalculator.computeValidOnly(allDocs);
      List<String> topChurches = [];
      if (collectionName.contains('1') || collectionName.contains('2')) {
        if (valid.isNotEmpty) topChurches.add(valid.first.churchName);
      } else if (collectionName.contains('G') || collectionName.contains('F')) {
        topChurches = valid.take(2).map((e) => e.churchName).toList();
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Image(pw.MemoryImage(logo1), width: 100, height: 100),
                        pw.Expanded(
                          child: pw.Column(
                            children: [
                              pw.Text(
                                "نتائج مسابقة الألحان والتسبحة",
                                style: pw.TextStyle(font: arabicBoldFont, fontSize: 24, fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'المصعدين',
                                style: pw.TextStyle(font: arabicFont, fontSize: 18, fontWeight: pw.FontWeight.normal),
                                textAlign: pw.TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        pw.Image(pw.MemoryImage(logo2), width: 100, height: 100),
                      ],
                    ),
                    pw.SizedBox(height: 40),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green100,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: PdfColors.green300),
                      ),
                      child: pw.Text(
                        displayName,
                        style: pw.TextStyle(font: arabicBoldFont, fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(height: 40),
                    if (topChurches.isNotEmpty) ...[
                      ...topChurches.asMap().entries.map((entry) {
                        final index = entry.key;
                        final churchName = entry.value;
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 15),
                          padding: const pw.EdgeInsets.all(15),
                          decoration: pw.BoxDecoration(
                            color: index == 0 ? PdfColors.amber100 : PdfColors.grey100,
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(color: index == 0 ? PdfColors.amber300 : PdfColors.grey300, width: 2),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 40,
                                height: 40,
                                decoration: pw.BoxDecoration(
                                  color: index == 0 ? PdfColors.amber : PdfColors.grey400,
                                  borderRadius: pw.BorderRadius.circular(20),
                                ),
                                child: pw.Center(
                                  child: pw.Text('${index + 1}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                                ),
                              ),
                              pw.SizedBox(width: 20),
                              pw.Expanded(
                                child: pw.Text(
                                  churchName,
                                  style: pw.TextStyle(
                                    font: index == 0 ? arabicBoldFont : arabicFont,
                                    fontSize: 16,
                                    fontWeight: index == 0 ? pw.FontWeight.bold : pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red100,
                          borderRadius: pw.BorderRadius.circular(10),
                          border: pw.Border.all(color: PdfColors.red300),
                        ),
                        child: pw.Text(
                          'لا توجد بيانات متاحة لهذا المستوى',
                          style: pw.TextStyle(font: arabicFont, fontSize: 16, color: PdfColors.red800),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                    pw.Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Church_Competition_Results_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      emit(ExportPdfSuccess());
    } catch (e) {
      emit(ExportPdfError(e.toString()));
    }
  }
}