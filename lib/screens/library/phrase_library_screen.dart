import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/models/phrase_model.dart';
import '../../data/repositories/phrase_repository.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/supabase_phrase_image.dart';
import '../../widgets/common/urdu_text.dart';

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
  late Future<List<PhraseModel>> _libraryFuture;
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
    _libraryFuture = ref
        .read(phraseRepositoryProvider)
        .fetchAllPhrases();
  }

  Future<List<PhraseModel>> _reloadPhrases({required bool forceRemote}) {
    final Future<List<PhraseModel>> next = ref
        .read(phraseRepositoryProvider)
        .fetchAllPhrases(forceRemote: forceRemote);
    setState(() {
      _libraryFuture = next;
    });
    return next;
  }

  Future<void> _onPullToRefresh() async {
    await _reloadPhrases(forceRemote: true);
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    final AppLang lang = ref.watch(appLangNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: FutureBuilder<List<PhraseModel>>(
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
          final all = snap.data ?? const <PhraseModel>[];
          final q = _search.text.trim().toLowerCase();
          final filtered =
              all.where((p) {
                final categoryOk = _category == 'سب' || p.category == _category;
                final difficultyOk =
                    _difficulty == 'سب' || p.difficulty == _difficulty;
                final queryOk =
                    q.isEmpty ||
                    p.urduPhrase.toLowerCase().contains(q) ||
                    p.romanised.toLowerCase().contains(q);
                return categoryOk && difficultyOk && queryOk;
              }).toList();

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 4,
                  16,
                  4,
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child:
                    s.isEnglish
                        ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            s.libraryTitle,
                            style: AppTextStyles.enTitle.copyWith(fontSize: 26),
                          ),
                        )
                        : Align(
                          alignment: Alignment.centerRight,
                          child: UrduText(
                            s.libraryTitle,
                            style: AppTextStyles.urduTitle,
                          ),
                        ),
              ),
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(s.libraryPhraseCountInline(filtered.length)),
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
                                      message: s.libraryNoResults,
                                      emoji: '🔎',
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
                              return InkWell(
                                onTap: () => _openDetails(context, p),
                                child: Card(
                                  color: AppColors.bgCard,
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ColoredBox(
                                          color: Colors.grey.shade200,
                                          child: SupabasePhraseImage(
                                            imageUrl: p.imageUrl,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: UrduText(
                                            p.urduPhrase,
                                            style: AppTextStyles.urduBody
                                                .copyWith(fontSize: 16),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  void _openDetails(BuildContext context, PhraseModel p) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInsetGap(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UrduText(p.urduPhrase, style: AppTextStyles.urduTitle),
                const SizedBox(height: 6),
                Text(p.romanised, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                UrduText('معنی: ${p.meaningUrdu}'),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const UrduText('مثال دیکھیں'),
                ),
              ],
            ),
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
