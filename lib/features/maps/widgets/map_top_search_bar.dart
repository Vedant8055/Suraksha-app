import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/maps/map_route_models.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Top-right expandable search bar for the safety map: a closed search FAB
/// that expands into a text field with place autocomplete suggestions.
class MapTopSearchBar extends StatelessWidget {
  const MapTopSearchBar({
    super.key,
    required this.isSearchOpen,
    required this.controller,
    required this.focusNode,
    required this.isLoadingSuggestions,
    required this.suggestions,
    required this.onChanged,
    required this.onSearch,
    required this.onOpen,
    required this.onClose,
    required this.onSuggestionTap,
  });

  final bool isSearchOpen;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoadingSuggestions;
  final List<MapPlaceSuggestion> suggestions;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final ValueChanged<MapPlaceSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Positioned(
      top: 16,
      right: 16,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              alignment: Alignment.centerRight,
              child: child,
            ),
          );
        },
        child: isSearchOpen
            ? Container(
                key: const ValueKey('search_open'),
                width: MediaQuery.of(context).size.width * 0.72,
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFFFFFFF).withValues(alpha: 0.96)
                      : AppTheme.cardColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isLight ? 0.12 : 0.22,
                      ),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isLight
                        ? const Color(0xFFD6E4FB)
                        : Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Icon(
                          Icons.search,
                          color: isLight
                              ? const Color(0xFF5F6F8A)
                              : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: false,
                            textInputAction: TextInputAction.search,
                            onChanged: onChanged,
                            onSubmitted: (_) => onSearch(),
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF172235)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              ).t('searchLocation'),
                              hintStyle: TextStyle(
                                color: isLight
                                    ? const Color(0xFF7E8DA6)
                                    : Colors.white54,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onSearch,
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: Icon(
                            Icons.close,
                            color: isLight
                                ? const Color(0xFF5F6F8A)
                                : Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    if (isLoadingSuggestions)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (suggestions.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: suggestions.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: isLight
                                ? const Color(0xFFE3EBF7)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: isLight
                                    ? const Color(0xFF5F6F8A)
                                    : Colors.white70,
                              ),
                              title: Text(
                                suggestion.title,
                                style: TextStyle(
                                  color: isLight
                                      ? const Color(0xFF172235)
                                      : Colors.white,
                                ),
                              ),
                              subtitle: suggestion.subtitle.isNotEmpty
                                  ? Text(
                                      suggestion.subtitle,
                                      style: TextStyle(
                                        color: isLight
                                            ? const Color(0xFF7E8DA6)
                                            : Colors.white60,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              onTap: () => onSuggestionTap(suggestion),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              )
            : Material(
                key: const ValueKey('search_closed'),
                color: AppTheme.cardColor,
                shape: const CircleBorder(),
                elevation: isLight ? 3 : 5,
                shadowColor: Colors.black.withValues(
                  alpha: isLight ? 0.14 : 0.3,
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onOpen,
                  child: const Padding(
                    padding: EdgeInsets.all(13),
                    child: Icon(Icons.search, color: Colors.white, size: 21),
                  ),
                ),
              ),
      ),
    );
  }
}
