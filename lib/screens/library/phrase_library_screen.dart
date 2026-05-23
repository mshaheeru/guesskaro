import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/mastery_constants.dart';
import '../../data/models/phrase_model.dart';
import '../../data/repositories/phrase_repository.dart';
import '../../providers/locale_provider.dart';
import '../../providers/session_user_provider.dart';
import '../../widgets/library/library_phrase_card.dart';
import 'library_load_result.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/library/library_phrase_detail_sheet.dart';
import '../../core/navigation/main_bottom_tab_nav.dart';
import '../../providers/library_mastery_provider.dart';

class PhraseLibraryScreen extends ConsumerStatefulWidget {
  const PhraseLibraryScreen({super.key});

  @override
  ConsumerState<PhraseLibraryScreen> createState() =>
      _PhraseLibraryScreenState();
}

class _PhraseLibraryScreenState extends ConsumerState<PhraseLibraryScreen> {
  final TextEditingController _search = TextEditingController();
  String _category = 'سب';
  String _difficulty = 'سب';
  late Future<LibraryLoadResult> _libraryFuture;
  bool _futureReady = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_futureReady) return;
    _futureReady = true;
    _libraryFuture = _loadLibrary(forceRemote: false);
  }

  Future<LibraryLoadResult> _loadLibrary({required bool forceRemote}) async {
    final PhraseRepository repo = ref.read(phraseRepositoryProvider);
    final List<PhraseModel> phrases =
        await repo.fetchAllPhrases(forceRemote: forceRemote);
    final String userId =
        ref.read(activeUserIdProvider) ?? kLocalGuestUserId;
    final Map<String, int> mastery = await repo.getMasteryMap(userId);
    return LibraryLoadResult(phrases: phrases, masteryByPhraseId: mastery);
  }

  Future<LibraryLoadResult> _reloadPhrases({required bool forceRemote}) {
    final Future<LibraryLoadResult> next = _loadLibrary(forceRemote: forceRemote);
    setState(() {
      _libraryFuture = next;
    });
    return next;
  }

  Future<void> _onPullToRefresh() async {
    await _reloadPhrases(forceRemote: true);
    ref.invalidate(libraryMasterySummaryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    final AppLang lang = ref.watch(appLangNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        labelHome: s.navHome,
        labelProfile: s.navProfile,
        labelSettings: s.navSettings,
        onTap: (int i) => navigateMainBottomTab(context, i),
      ),
      body: FutureBuilder<LibraryLoadResult>(
        future: _libraryFuture,
        builder: (context, snap) {
          if (snap.hasError) {
            final String err =
                s.isEnglish
                    ? 'Unable to load library.'
                    : 'فہرست لوڈ نہیں ہو سکی';
            return ErrorState(
              message: err,
              onRetry: () {
                _reloadPhrases(forceRemote: true);
              },
            );
          }
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LibraryGridShimmer(),
            );
          }
          final LibraryLoadResult data = snap.data ??
              const LibraryLoadResult(
                phrases: <PhraseModel>[],
                masteryByPhraseId: <String, int>{},
              );
          final int mastered = data.masteredCount;
          final int totalActive = data.phrases.length;
          final List<PhraseModel> masteredPhrases = data.masteredPhrases;
          final q = _search.text.trim().toLowerCase();
          final filtered =
              masteredPhrases.where((PhraseModel p) {
                final categoryOk = _category == 'سب' || p.category == _category;
                final difficultyOk =
                    _difficulty == 'سب' || p.difficulty == _difficulty;
                final queryOk =
                    q.isEmpty ||
                    p.urduPhrase.toLowerCase().contains(q) ||
                    p.romanised.toLowerCase().contains(q);
                return categoryOk && difficultyOk && queryOk;
              }).toList();
          final bool hasNoMasteredYet = masteredPhrases.isEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  8,
                  MediaQuery.of(context).padding.top + 4,
                  16,
                  0,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    s.isEnglish
                        ? Text(
                          s.libraryTitle,
                          style: AppTextStyles.enTitle.copyWith(fontSize: 26),
                          textAlign: TextAlign.start,
                        )
                        : UrduText(
                          s.libraryTitle,
                          style: AppTextStyles.urduTitle,
                          textAlign: TextAlign.start,
                        ),
                    const SizedBox(height: 6),
                    s.isEnglish
                        ? Text(
                          s.librarySubtitle,
                          style: AppTextStyles.enCaption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.start,
                        )
                        : UrduText(
                          s.librarySubtitle,
                          style: AppTextStyles.urduCaption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.start,
                        ),
                    const SizedBox(height: 10),
                    s.isEnglish
                        ? Text(
                          s.libraryMasteryProgress(mastered, totalActive),
                          style: AppTextStyles.enCaption,
                          textAlign: TextAlign.start,
                        )
                        : UrduText(
                          s.libraryMasteryProgress(mastered, totalActive),
                          style: AppTextStyles.urduBody,
                          textAlign: TextAlign.start,
                        ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        value: totalActive == 0
                            ? 0
                            : mastered / totalActive,
                        backgroundColor: AppColors.borderSubtle,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasNoMasteredYet) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    textAlign:
                        lang == AppLang.en ? TextAlign.start : TextAlign.end,
                    textDirection:
                        lang == AppLang.en
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: s.librarySearchHint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...['سب', 'محاورہ', 'کہاوت'].map(
                        (e) => _filterChip(
                          label: e,
                          selected: _category == e,
                          selectedColor: AppColors.orange,
                          onTap: () => setState(() => _category = e),
                        ),
                      ),
                      ...['سب', 'آسان', 'درمیانہ', 'مشکل'].map(
                        (e) => _filterChip(
                          label: e,
                          selected: _difficulty == e,
                          selectedColor: AppColors.purple,
                          onTap: () => setState(() => _difficulty = e),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!hasNoMasteredYet)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(s.libraryMasteredCountInline(filtered.length)),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onPullToRefresh,
                  child:
                      filtered.isEmpty
                          ? LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: EmptyState(
                                      message:
                                          hasNoMasteredYet
                                              ? s.libraryEmptyMastered
                                              : s.libraryNoResults,
                                      emoji: hasNoMasteredYet ? '👑' : '🔎',
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                          : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              12,
                              12,
                              12,
                              bottomInsetGap(context),
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p = filtered[i];
                              return LibraryPhraseCard(
                                phrase: p,
                                masteryLevel: MasteryConstants.masteredLevel,
                                onTap:
                                    () => _openDetails(
                                      context,
                                      p,
                                      masteryLevel: MasteryConstants.masteredLevel,
                                    ),
                              );
                            },
                          ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openDetails(
    BuildContext context,
    PhraseModel p, {
    required int masteryLevel,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (BuildContext sheetContext) => LibraryPhraseDetailSheet(
            phrase: p,
            masteryLevel: masteryLevel,
          ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
              selected
                  ? selectedColor.withValues(alpha: 0.22)
                  : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? selectedColor : AppColors.borderSubtle,
          ),
        ),
        child: UrduText(
          label,
          style: AppTextStyles.urduBody.copyWith(
            color: selected ? selectedColor : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
