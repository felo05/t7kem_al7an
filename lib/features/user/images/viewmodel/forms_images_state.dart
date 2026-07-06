part of 'forms_images_cubit.dart';

abstract class FormsImagesState {}

class FormsImagesLoading extends FormsImagesState {}

class FormsImagesSuccess extends FormsImagesState {
  FormsImagesSuccess(this.images);
  final List<FormImageModel> images;
}

class FormsImagesError extends FormsImagesState {
  FormsImagesError(this.message);
  final String message;
}