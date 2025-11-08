part of 'selection_bloc.dart';

@immutable
sealed class SelectionState {
  final List<ExperienceModel> experiences;
  const SelectionState({this.experiences = const []});
}

class SelectionInitial extends SelectionState {
  const SelectionInitial({super.experiences});
}

class ExperienceLoadedState extends SelectionState {
  const ExperienceLoadedState({super.experiences});
}

class ExperienceLoadingFailure extends SelectionState {
  final String errorMessage;
  const ExperienceLoadingFailure(this.errorMessage, {super.experiences});
}

class ExperienceSelectedState extends SelectionState {
  final List<ExperienceModel> selectedExperiences;
  final String descriptionText;
  const ExperienceSelectedState(
    this.selectedExperiences,
    this.descriptionText, {
    super.experiences,
  });
}
