part of 'export_pdf_cubit.dart';

abstract class ExportPdfState {}

class ExportPdfInitial extends ExportPdfState {}

class ExportPdfLoading extends ExportPdfState {}

class ExportPdfSuccess extends ExportPdfState {}

class ExportPdfError extends ExportPdfState {
  ExportPdfError(this.message);
  final String message;
}
