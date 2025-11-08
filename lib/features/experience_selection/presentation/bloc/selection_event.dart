part of 'selection_bloc.dart';

@immutable
sealed class SelectionEvent {}

class GetExperiencesEvent extends SelectionEvent {}

class SelectExperience extends SelectionEvent {
  final List<ExperienceModel> selectedExperiences;
  final String descriptionText;
  SelectExperience(this.selectedExperiences, this.descriptionText);
}
