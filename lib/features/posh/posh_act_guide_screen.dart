import 'dart:async';

import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_common_widgets.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_guide_reading_prefs.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_ui.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class POSHActGuideScreen extends StatefulWidget {
  const POSHActGuideScreen({super.key});

  @override
  State<POSHActGuideScreen> createState() => _POSHActGuideScreenState();
}

class _POSHActGuideScreenState extends State<POSHActGuideScreen> {
  final _prefs = PoshGuideReadingPrefs();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _sectionKeys = List.generate(17, (_) => GlobalKey());

  double _fontScale = PoshGuideReadingPrefs.defaultFontScale;
  Set<int> _bookmarks = {};
  String _searchQuery = '';
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    unawaited(_loadPrefs());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final scale = await _prefs.loadFontScale();
    final bookmarks = await _prefs.loadBookmarks();
    if (!mounted) return;
    setState(() {
      _fontScale = scale;
      _bookmarks = bookmarks;
      _loadingPrefs = false;
    });
  }

  Future<void> _setFontScale(double scale) async {
    setState(() => _fontScale = scale);
    await _prefs.saveFontScale(scale);
  }

  Future<void> _toggleBookmark(int index) async {
    final updated = Set<int>.from(_bookmarks);
    if (updated.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }
    setState(() => _bookmarks = updated);
    await _prefs.saveBookmarks(updated);
  }

  Future<void> _jumpToSection(int index) async {
    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _sectionKeys[index].currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
    });
  }

  List<_GuideSectionData> _sections(AppLocalizations l10n) {
    return [
      _GuideSectionData(l10n.t('guide1Title'), l10n.t('guide1Body')),
      _GuideSectionData(l10n.t('guide2Title'), l10n.t('guide2Body')),
      _GuideSectionData(l10n.t('guide3Title'), l10n.t('guide3Body')),
      _GuideSectionData(l10n.t('guide4Title'), l10n.t('guide4Body')),
      _GuideSectionData(l10n.t('guide5Title'), l10n.t('guide5Body')),
      _GuideSectionData(l10n.t('guide6Title'), l10n.t('guide6Body')),
      _GuideSectionData(l10n.t('guide7Title'), l10n.t('guide7Body')),
      _GuideSectionData(l10n.t('guide8Title'), l10n.t('guide8Body')),
      _GuideSectionData(l10n.t('guide9Title'), l10n.t('guide9Body')),
      _GuideSectionData(l10n.t('guide10Title'), l10n.t('guide10Body')),
      _GuideSectionData(l10n.t('guide11Title'), l10n.t('guide11Body')),
      _GuideSectionData(l10n.t('guide12Title'), l10n.t('guide12Body')),
      _GuideSectionData(l10n.t('guide13Title'), l10n.t('guide13Body')),
      _GuideSectionData(l10n.t('guide14Title'), l10n.t('guide14Body')),
      _GuideSectionData(l10n.t('guide15Title'), l10n.t('guide15Body')),
      _GuideSectionData(l10n.t('guide16Title'), l10n.t('guide16Body')),
      _GuideSectionData(l10n.t('guide17Title'), l10n.t('guide17Body')),
    ];
  }

  List<int> _visibleSectionIndexes(List<_GuideSectionData> sections) {
    if (_searchQuery.isEmpty) {
      return List.generate(sections.length, (index) => index);
    }
    return [
      for (var i = 0; i < sections.length; i++)
        if (sections[i].title.toLowerCase().contains(_searchQuery) ||
            sections[i].body.toLowerCase().contains(_searchQuery))
          i,
    ];
  }

  void _openContents(List<_GuideSectionData> sections, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                l10n.t('poshGuideContents'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(sections.length, (index) {
                final section = sections[index];
                final bookmarked = _bookmarks.contains(index);
                return ListTile(
                  leading: Icon(
                    bookmarked ? Icons.bookmark : Icons.article_outlined,
                    color: bookmarked ? AppTheme.primaryColor : null,
                  ),
                  title: Text(section.title),
                  onTap: () => unawaited(_jumpToSection(index)),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    final sections = _sections(l10n);
    final visibleIndexes = _visibleSectionIndexes(sections);
    final bodyStyle = TextStyle(
      color: colors.mutedText,
      height: 1.35,
      fontSize: 14 * _fontScale,
    );
    final titleStyle = TextStyle(
      color: colors.text,
      fontWeight: FontWeight.w700,
      fontSize: 15 * _fontScale,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('detailedPoshActGuide')),
        actions: [
          IconButton(
            tooltip: l10n.t('poshGuideContents'),
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () => _openContents(sections, l10n),
          ),
        ],
      ),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.t('poshGuideSearchHint'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        l10n.t('poshGuideFontSize'),
                        style: TextStyle(
                          color: colors.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'A-',
                        onPressed: _fontScale <= PoshGuideReadingPrefs.minFontScale
                            ? null
                            : () => unawaited(
                                _setFontScale(_fontScale - 0.1),
                              ),
                        icon: const Icon(Icons.text_decrease_rounded),
                      ),
                      Text('${(_fontScale * 100).round()}%'),
                      IconButton(
                        tooltip: 'A+',
                        onPressed: _fontScale >= PoshGuideReadingPrefs.maxFontScale
                            ? null
                            : () => unawaited(
                                _setFontScale(_fontScale + 0.1),
                              ),
                        icon: const Icon(Icons.text_increase_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      const PoshLegalDisclaimerBanner(compact: true),
                      const SizedBox(height: 12),
                      const PoshLegalSourceCard(),
                      const SizedBox(height: 12),
                      _GuideIntro(colors: colors, text: l10n.t('guideIntro')),
                      const SizedBox(height: 12),
                      if (visibleIndexes.isEmpty)
                        Text(
                          l10n.t('poshGuideNoSearchResults'),
                          style: bodyStyle,
                        )
                      else
                        ...visibleIndexes.map((index) {
                          final section = sections[index];
                          final bookmarked = _bookmarks.contains(index);
                          return KeyedSubtree(
                            key: _sectionKeys[index],
                            child: _GuideSectionTile(
                              title: section.title,
                              body: section.body,
                              titleStyle: titleStyle,
                              bodyStyle: bodyStyle,
                              bookmarked: bookmarked,
                              bookmarkLabel: bookmarked
                                  ? l10n.t('poshGuideBookmarked')
                                  : l10n.t('poshGuideBookmark'),
                              onToggleBookmark: () => unawaited(
                                _toggleBookmark(index),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      _GuideDisclaimer(text: l10n.t('legalDisclaimer')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _GuideSectionData {
  const _GuideSectionData(this.title, this.body);

  final String title;
  final String body;
}

class _GuideIntro extends StatelessWidget {
  const _GuideIntro({required this.colors, required this.text});

  final PoshColors colors;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        text,
        style: TextStyle(color: colors.mutedText, height: 1.35),
      ),
    );
  }
}

class _GuideSectionTile extends StatelessWidget {
  const _GuideSectionTile({
    required this.title,
    required this.body,
    required this.titleStyle,
    required this.bodyStyle,
    required this.bookmarked,
    required this.bookmarkLabel,
    required this.onToggleBookmark,
  });

  final String title;
  final String body;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final bool bookmarked;
  final String bookmarkLabel;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        collapsedBackgroundColor: colors.card,
        backgroundColor: colors.card,
        iconColor: AppTheme.primaryColor,
        collapsedIconColor: colors.mutedText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
        title: Text(title, style: titleStyle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: bookmarkLabel,
              onPressed: onToggleBookmark,
              icon: Icon(
                bookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: bookmarked ? AppTheme.primaryColor : colors.mutedText,
              ),
            ),
            Icon(Icons.expand_more, color: colors.mutedText),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [Text(body, style: bodyStyle)],
      ),
    );
  }
}

class _GuideDisclaimer extends StatelessWidget {
  const _GuideDisclaimer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4E2B18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFFFE6D5), height: 1.35),
      ),
    );
  }
}
