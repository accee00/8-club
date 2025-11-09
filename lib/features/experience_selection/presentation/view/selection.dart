import 'dart:ui';
import 'package:eightclub/core/extensions/build_extension.dart';
import 'package:eightclub/core/logger/app_logger.dart';
import 'package:eightclub/core/widgets/custom_text_feild.dart';
import 'package:eightclub/core/widgets/elevatedNextButton.dart';
import 'package:eightclub/core/widgets/wave_background.dart';
import 'package:eightclub/core/widgets/wave_progress_indicator.dart';
import 'package:eightclub/features/experience_selection/models/experience_model.dart';
import 'package:eightclub/features/experience_selection/presentation/bloc/selection_bloc.dart';
import 'package:eightclub/features/onboard/presentation/view/onboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen> {
  final TextEditingController _textController = TextEditingController();
  final Set<int> _selectedIndices = {};
  List<dynamic> _orderedExperiences = [];
  final ScrollController _scrollController = ScrollController();
  double _progress = 0.3; // Initial progress

  @override
  void initState() {
    super.initState();
    context.read<SelectionBloc>().add(GetExperiencesEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onExperienceTap(int originalIndex, SelectionState state) {
    setState(() {
      if (_selectedIndices.contains(originalIndex)) {
        _selectedIndices.remove(originalIndex);
      } else {
        _selectedIndices.add(originalIndex);
      }
      _reorderExperiences(state);
      _updateProgress(state);
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateProgress(SelectionState state) {
    if (state is ExperienceLoadedState) {
      final totalExperiences = state.experiences.length;
      final selectedCount = _selectedIndices.length;

      // Calculate progress: 0.3 base + up to 0.7 based on selections
      // You can adjust this formula based on your needs
      if (totalExperiences > 0) {
        final selectionProgress = (selectedCount / totalExperiences) * 0.7;
        _progress = 0.3 + selectionProgress;

        // Ensure progress doesn't exceed 1.0
        _progress = _progress.clamp(0.3, 1.0);
      }
    }
  }

  void _reorderExperiences(SelectionState state) {
    if (state is ExperienceLoadedState) {
      final List<ExperienceModel> experiences = state.experiences;
      final List<ExperienceModel> selected = <ExperienceModel>[];
      final List<ExperienceModel> unselected = <ExperienceModel>[];

      for (int i = 0; i < experiences.length; i++) {
        if (_selectedIndices.contains(i)) {
          selected.add(experiences[i]);
        } else {
          unselected.add(experiences[i]);
        }
      }

      _orderedExperiences = [...selected, ...unselected];
    }
  }

  int _getOriginalIndex(int currentIndex, SelectionState state) {
    if (state is ExperienceLoadedState) {
      final currentExperience = _orderedExperiences[currentIndex];
      return state.experiences.indexOf(currentExperience);
    }
    return currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final adaptiveMaxLines = isKeyboardOpen ? 3 : 5;
    return BlocConsumer<SelectionBloc, SelectionState>(
      listener: (BuildContext context, SelectionState state) {
        if (state is ExperienceSelectedState) {
          logInfo(
            'Selected Experiences: ${state.selectedExperiences.toString()}\nDescription: ${state.descriptionText}',
          );
        }
      },
      builder: (BuildContext context, SelectionState state) {
        if (_orderedExperiences.isEmpty) {
          _orderedExperiences = List.from(state.experiences);
        }

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: context.colorScheme.surface.withAlpha(190),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: SizedBox(
              width: context.width * 0.6,
              child: WaveProgressIndicator(
                progress: _progress, // Use the dynamic progress value
                activeColor: context.colorScheme.secondary,
                inactiveColor: const Color(0xFF404040),
                height: 40,
                waveWidth: 20,
                waveHeight: 5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: WaveBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: isKeyboardOpen
                          ? context.height * 0.06
                          : context.height * 0.30,
                    ),
                    Text('01', style: context.textTheme.labelMedium),
                    const SizedBox(height: 10),
                    Text(
                      'What kind of hotspots do you want to host?',
                      style: isKeyboardOpen
                          ? context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface,
                            )
                          : context.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 140,
                      child: AnimatedList(
                        key: ValueKey(_orderedExperiences.length),
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        initialItemCount: _orderedExperiences.length,
                        itemBuilder: (context, index, animation) {
                          final experience = _orderedExperiences[index];
                          final originalIndex = _getOriginalIndex(index, state);
                          final isSelected = _selectedIndices.contains(
                            originalIndex,
                          );
                          final tiltAngle = index.isEven ? -0.05 : 0.05;

                          return SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: const Offset(0.3, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOut)),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index < _orderedExperiences.length - 1
                                      ? 22
                                      : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () =>
                                      _onExperienceTap(originalIndex, state),
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.0 : 0.95,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: Transform.rotate(
                                      angle: tiltAngle,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        width: 140,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: context
                                                        .colorScheme
                                                        .secondary
                                                        .withAlpha(100),
                                                    blurRadius: 12,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: ColorFiltered(
                                            colorFilter: isSelected
                                                ? const ColorFilter.mode(
                                                    Colors.transparent,
                                                    BlendMode.saturation,
                                                  )
                                                : const ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                            child: Image.network(
                                              experience.imageUrl,
                                              height: 180,
                                              width: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, _, __) =>
                                                  Container(
                                                    color: Colors.grey.shade800,
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.white54,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (state is ExperienceLoadingFailure)
                      Center(
                        child: Text(
                          state.errorMessage,
                          style: context.textTheme.bodyLarge,
                        ),
                      )
                    else
                      SizedBox.shrink(),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _textController,
                      maxLines: adaptiveMaxLines,
                      hintText: '/ Describe your perfect hotspot',
                      maxLength: 250,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is empty.';
                        }
                        if (value.length > 250) {
                          return 'Description is greater than 250.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Elevatednextbutton(
                      onTap: () {
                        context.read<SelectionBloc>().add(
                          SelectExperience(
                            _selectedIndices
                                .map((index) => state.experiences[index])
                                .toList(),
                            _textController.text,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OnboardScreen()),
                        );
                      },
                      isEnabled: _selectedIndices.isNotEmpty,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
