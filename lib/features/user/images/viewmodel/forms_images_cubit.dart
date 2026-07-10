import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/user/repository/i_user_repository.dart';

import '../model/form_image_model.dart';

part 'forms_images_state.dart';

class FormsImagesCubit extends Cubit<FormsImagesState> {
  FormsImagesCubit(this._repository) : super(FormsImagesLoading());

  final IUserRepository _repository;

  Future<void> load({String? churchName, String? userName}) async {
    emit(FormsImagesLoading());
    try {
      final rawPaths = await _repository.getFormImagePaths();
      final images = rawPaths
          .map(FormImageModel.fromPath)
          .where(
              (img) => img.matches(churchName: churchName, userName: userName))
          .toList()
          .reversed
          .toList();
      emit(FormsImagesSuccess(images));
    } catch (e) {
      emit(FormsImagesError(e.toString()));
    }
  }
}
