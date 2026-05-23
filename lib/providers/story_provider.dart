import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/story_model.dart';
import '../data/repositories/story_repository.dart';

final FutureProvider<List<StoryModel>> activeStoriesProvider =
    FutureProvider<List<StoryModel>>((Ref ref) async {
      return ref.read(storyRepositoryProvider).fetchActiveStories();
    });
