class PhraseModel {
  const PhraseModel({
    required this.id,
    required this.urduPhrase,
    required this.romanised,
    required this.meaningUrdu,
    required this.exampleSentence,
    required this.category,
    required this.difficulty,
    required this.imageUrl,
    required this.revealImageUrl,
    required this.isActive,
    required this.createdAt,
    this.wrongOptions = const <String>[],
    this.photoWrongOptions = const <String>[],
  });

  final String id;
  final String urduPhrase;
  final String romanised;
  final String meaningUrdu;
  final String exampleSentence;
  final String category;
  final String difficulty;
  final String imageUrl;
  final String revealImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final List<String> wrongOptions;
  final List<String> photoWrongOptions;

  PhraseModel copyWith({
    String? id,
    String? urduPhrase,
    String? romanised,
    String? meaningUrdu,
    String? exampleSentence,
    String? category,
    String? difficulty,
    String? imageUrl,
    String? revealImageUrl,
    bool? isActive,
    DateTime? createdAt,
    List<String>? wrongOptions,
    List<String>? photoWrongOptions,
  }) {
    return PhraseModel(
      id: id ?? this.id,
      urduPhrase: urduPhrase ?? this.urduPhrase,
      romanised: romanised ?? this.romanised,
      meaningUrdu: meaningUrdu ?? this.meaningUrdu,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      revealImageUrl: revealImageUrl ?? this.revealImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      wrongOptions: wrongOptions ?? this.wrongOptions,
      photoWrongOptions: photoWrongOptions ?? this.photoWrongOptions,
    );
  }

  factory PhraseModel.fromJson(Map<String, dynamic> json) {
    return PhraseModel(
      id: json['id'] as String,
      urduPhrase: json['urdu_phrase'] as String,
      romanised: json['romanised'] as String,
      meaningUrdu: json['meaning_urdu'] as String,
      exampleSentence: json['example_sentence'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      revealImageUrl: json['reveal_image_url'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      wrongOptions: (json['wrong_options'] as List<dynamic>?)
              ?.map((dynamic option) => option as String)
              .toList() ??
          const <String>[],
      photoWrongOptions: (json['photo_wrong_options'] as List<dynamic>?)
              ?.map((dynamic option) => option as String)
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'urdu_phrase': urduPhrase,
      'romanised': romanised,
      'meaning_urdu': meaningUrdu,
      'example_sentence': exampleSentence,
      'category': category,
      'difficulty': difficulty,
      'image_url': imageUrl,
      'reveal_image_url': revealImageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'wrong_options': wrongOptions,
      'photo_wrong_options': photoWrongOptions,
    };
  }
}
