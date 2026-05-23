import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/story_model.dart';

class StoryRepository {
  StoryRepository();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<StoryModel>> fetchActiveStories() async {
    try {
      final List<dynamic> rows = await _client
          .from('stories')
          .select()
          .eq('is_active', true)
          .order('display_order');

      return rows
          .map(
            (dynamic row) =>
                StoryModel.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .where(
            (StoryModel s) =>
                s.id.isNotEmpty &&
                s.titleUrdu.isNotEmpty &&
                s.phraseIds.isNotEmpty,
          )
          .toList();
    } catch (_) {
      return <StoryModel>[];
    }
  }

  Future<StoryModel?> fetchStoryById(String id) async {
    try {
      final Map<String, dynamic>? row = await _client
          .from('stories')
          .select()
          .eq('id', id)
          .eq('is_active', true)
          .maybeSingle();

      if (row == null) return null;
      return StoryModel.fromJson(row);
    } catch (_) {
      return null;
    }
  }
}

final Provider<StoryRepository> storyRepositoryProvider =
    Provider<StoryRepository>((Ref ref) => StoryRepository());
