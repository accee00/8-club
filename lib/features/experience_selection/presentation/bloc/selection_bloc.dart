import 'package:bloc/bloc.dart';
import 'package:eightclub/core/error/failure.dart';
import 'package:eightclub/features/experience_selection/models/experience_model.dart';
import 'package:eightclub/service/get_experience_service.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

part 'selection_event.dart';
part 'selection_state.dart';

class SelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  final GetExperienceService getExperienceService;
  SelectionBloc(this.getExperienceService) : super(SelectionInitial()) {
    on<GetExperiencesEvent>(_fetchExperiences);
    on<SelectExperience>((event, emit) {
      emit(
        ExperienceSelectedState(
          event.selectedExperiences,
          event.descriptionText,
          experiences: state.experiences,
        ),
      );
    });
  }
  Future<void> _fetchExperiences(
    GetExperiencesEvent event,
    Emitter<SelectionState> emit,
  ) async {
    emit(SelectionInitial(experiences: state.experiences));
    final Either<Failure, List<ExperienceModel>> result =
        await getExperienceService.fetchExperiences();
    result.fold(
      (Failure failure) {
        emit(
          ExperienceLoadingFailure(
            failure.message,
            experiences: state.experiences,
          ),
        );
      },
      (List<ExperienceModel> experiences) {
        emit(ExperienceLoadedState(experiences: experiences));
      },
    );
  }
}
