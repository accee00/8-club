import 'package:dio/dio.dart';
import 'package:dio/src/response.dart';
import 'package:eightclub/core/dio/dio_client.dart';
import 'package:eightclub/core/error/failure.dart';
import 'package:eightclub/features/experience_selection/models/experience_model.dart';
import 'package:fpdart/fpdart.dart';

class GetExperienceService {
  final DioClient dio;
  GetExperienceService(this.dio);
  Future<Either<Failure, List<ExperienceModel>>> fetchExperiences() async {
    try {
      final Response response = await dio.get(
        'https://staging.chamberofsecrets.8club.co/v1/experiences?active=true',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']?['experiences'] ?? [];
        final List<ExperienceModel> experiences = data
            .map((json) => ExperienceModel.fromJson(json))
            .toList();
        return Right(experiences);
      } else {
        return Left(
          Failure('Failed to load experiences: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(Failure('Error fetching experiences: $e'));
    }
  }
}
