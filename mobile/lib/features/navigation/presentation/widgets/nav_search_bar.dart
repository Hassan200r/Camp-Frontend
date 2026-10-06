import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../controllers/navigation_controller.dart';
import '../../domain/geocoding_service.dart';

/// Top search bar with mic icon, profile monogram avatar, and search suggestions overlay
/// displaying Recent and Saved places. Search only executes on submit.
class NavSearchBar extends StatefulWidget {
  const NavSearchBar({
    required this.controller,
    required this.onOpenProfile,
    this.onSelectPlace,
    super.key,
  });

  final NavigationController controller;
  final VoidCallback onOpenProfile;
  final ValueChanged<PlaceSearchResult>? onSelectPlace;

  @override
  State<NavSearchBar> createState() => _NavSearchBarState();
}

class _NavSearchBarState extends State<NavSearchBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isSearching = false;
  List<PlaceSearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitted(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    final results = await widget.controller.searchPlaces(trimmed);

    if (mounted) {
      setState(() {
        _isSearching = false;
        _searchResults = results;
      });

      if (results.isNotEmpty) {
        if (results.length == 1) {
          _selectPlace(results.first);
        }
      }
    }
  }

  void _selectPlace(PlaceSearchResult place) {
    _textController.text = place.name;
    _focusNode.unfocus();
    setState(() {
      _isFocused = false;
      _searchResults = [];
    });

    if (widget.onSelectPlace != null) {
      widget.onSelectPlace!(place);
    } else {
      widget.controller.openRoutePreview(place);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Main Search Bar Pill ─────────────────────────────────────────────
        Container(
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.search_rounded,
                color: AppColors.mutedText,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _handleSubmitted,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.darkCharcoal,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search here',
                    hintStyle: TextStyle(
                      color: AppColors.mutedLight,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_textController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.mutedLight,
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                ),
              // Mic Icon (Voice Copilot placeholder)
              IconButton(
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.mutedText,
                  size: 22,
                ),
                onPressed: () {
                  // TODO: Connect speech-to-text package when configured
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice input coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              // Profile Avatar
              GestureDetector(
                onTap: widget.onOpenProfile,
                child: Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF141416),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'C',
                    style: TextStyle(
                      color: AppColors.tacticalOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Dropdown Overlay for Suggestions, Recents & Saved Places ─────────
        if (_isFocused) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                children: [
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (_searchResults.isNotEmpty) ...[
                    _buildSectionHeader('SEARCH RESULTS'),
                    ..._searchResults.map(_buildPlaceTile),
                  ] else ...[
                    if (widget.controller.savedPlaces.isNotEmpty) ...[
                      _buildSectionHeader('SAVED PLACES'),
                      ...widget.controller.savedPlaces.map(_buildPlaceTile),
                    ],
                    if (widget.controller.recentPlaces.isNotEmpty) ...[
                      _buildSectionHeader('RECENT SEARCHES'),
                      ...widget.controller.recentPlaces.map(_buildPlaceTile),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.mutedLight,
        ),
      ),
    );
  }

  Widget _buildPlaceTile(PlaceSearchResult place) {
    return ListTile(
      dense: true,
      leading: const Icon(
        Icons.place_outlined,
        color: AppColors.tacticalOrange,
        size: 20,
      ),
      title: Text(
        place.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.darkCharcoal,
        ),
      ),
      subtitle: Text(
        place.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.mutedText,
        ),
      ),
      onTap: () => _selectPlace(place),
    );
  }
}
