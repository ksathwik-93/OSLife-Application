import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../providers/note_provider.dart';
import '../../models/note_model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All'; // 'All', 'Pinned', 'Strategy', 'Engineering', 'Reading', 'Personal', 'Work'
  bool _isGridView = true; // Toggle between Grid View and List View

  final List<Map<String, dynamic>> _colorPalette = [
    {'name': 'Purple', 'hex': '#8B5CF6', 'color': const Color(0xFF8B5CF6)},
    {'name': 'Cyan', 'hex': '#22D3EE', 'color': const Color(0xFF22D3EE)},
    {'name': 'Amber', 'hex': '#FFA100', 'color': const Color(0xFFFFA100)},
    {'name': 'Green', 'hex': '#10B981', 'color': const Color(0xFF10B981)},
    {'name': 'Rose', 'hex': '#EC4899', 'color': const Color(0xFFEC4899)},
  ];

  Color _parseColorHex(String hexString) {
    try {
      final cleanHex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return AppColors.primaryContainer;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NoteModel> _getFilteredNotes(List<NoteModel> notes) {
    final query = _searchController.text.trim().toLowerCase();

    return notes.where((note) {
      final matchesQuery = query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tag.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedCategory == 'Pinned') return note.isPinned;
      if (_selectedCategory == 'All') return true;
      return note.tag.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final allNotes = noteProvider.notes;
    final filteredNotes = _getFilteredNotes(allNotes);

    // Compute statistics
    final totalNotes = allNotes.length;
    final pinnedNotes = allNotes.where((n) => n.isPinned).length;
    final categoriesCount = allNotes.map((n) => n.tag).toSet().length;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notes & Brain Dump',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: AppColors.surfaceContainerLow,
        actions: [
          // View Mode Toggle (Grid vs List)
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.primary,
            ),
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Notes',
            onPressed: () => noteProvider.loadNotes(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditNoteModal(context, noteProvider: noteProvider),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.note_add_rounded, size: 20),
        label: const Text('New Note', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? AppConstants.paddingDesktop : AppConstants.paddingMobile,
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Notes Statistics
                _buildStatisticsSection(totalNotes, pinnedNotes, categoriesCount, isDesktop),
                const SizedBox(height: 24),

                // Section 2: Search Bar & Category Filters
                _buildSearchAndFiltersSection(context, allNotes),
                const SizedBox(height: 24),

                // Section 3: Notes Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedCategory Notes (${filteredNotes.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _isGridView ? 'Grid View' : 'List View',
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Section 4: Notes List or Grid
                if (filteredNotes.isEmpty)
                  _buildEmptyState()
                else if (_isGridView)
                  _buildNotesGrid(filteredNotes, noteProvider, isDesktop)
                else
                  _buildNotesList(filteredNotes, noteProvider),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Statistics Cards
  Widget _buildStatisticsSection(int total, int pinned, int categoriesCount, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              width: cardWidth,
              title: 'TOTAL NOTES',
              value: '$total',
              subtitle: 'Saved thoughts & memos',
              icon: Icons.note_alt_rounded,
              color: AppColors.primary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'PINNED NOTES',
              value: '$pinned',
              subtitle: 'High priority notes',
              icon: Icons.push_pin_rounded,
              color: AppColors.tertiary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'CATEGORIES',
              value: '$categoriesCount',
              subtitle: 'Organized topics',
              icon: Icons.category_rounded,
              color: AppColors.secondary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'RECENT SYNC',
              value: 'Just now',
              subtitle: 'Local state synced',
              icon: Icons.sync_rounded,
              color: const Color(0xFF10B981),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Search & Categories Filter Bar
  Widget _buildSearchAndFiltersSection(BuildContext context, List<NoteModel> allNotes) {
    final categories = ['All', 'Pinned', 'Strategy', 'Engineering', 'Reading', 'Personal', 'Work'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Bar
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: 16,
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Search notes by keyword, title, or category tag...',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 3. Grid View
  Widget _buildNotesGrid(List<NoteModel> notes, NoteProvider noteProvider, bool isDesktop) {
    final crossCount = isDesktop ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isDesktop ? 1.2 : 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note, noteProvider);
      },
    );
  }

  // 4. List View
  Widget _buildNotesList(List<NoteModel> notes, NoteProvider noteProvider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildNoteCard(note, noteProvider),
        );
      },
    );
  }

  // Single Note Card Widget
  Widget _buildNoteCard(NoteModel note, NoteProvider noteProvider) {
    final accentColor = _parseColorHex(note.colorHex);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2),
      onTap: () => _showAddOrEditNoteModal(context, noteProvider: noteProvider, existingNote: note),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  note.tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  // Pin Toggle Button
                  IconButton(
                    icon: Icon(
                      note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: 18,
                      color: note.isPinned ? AppColors.tertiary : AppColors.onSurfaceVariant,
                    ),
                    tooltip: note.isPinned ? 'Unpin Note' : 'Pin Note',
                    onPressed: () => noteProvider.togglePin(note.id),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    tooltip: 'Delete Note',
                    onPressed: () => _showDeleteConfirmationDialog(context, noteProvider, note),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              note.content,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return const GlassCard(
      padding: EdgeInsets.all(32),
      borderRadius: 20,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.note_alt_outlined, size: 48, color: AppColors.onSurfaceVariant),
            SizedBox(height: 16),
            Text(
              'No notes found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            SizedBox(height: 6),
            Text(
              'Try adjusting your search query or filter settings, or tap + New Note.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Create or Edit Note Modal
  void _showAddOrEditNoteModal(BuildContext context, {required NoteProvider noteProvider, NoteModel? existingNote}) {
    final isEditing = existingNote != null;
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');
    String selectedTag = existingNote?.tag ?? 'Strategy';
    String selectedColorHex = existingNote?.colorHex ?? '#7C3AED';
    bool isPinned = existingNote?.isPinned ?? false;

    final categories = ['Strategy', 'Engineering', 'Reading', 'Personal', 'Work', 'Idea'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Note' : 'Create New Note',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          const Text('Pin Note', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          Switch(
                            value: isPinned,
                            onChanged: (val) {
                              setModalState(() {
                                isPinned = val;
                              });
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title Input
                  TextField(
                    controller: titleController,
                    autofocus: !isEditing,
                    style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Note Title',
                      hintText: 'e.g. Q4 Growth Strategy & Architecture',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content Multiline Input
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Content / Note Body',
                      hintText: 'Write down key ideas, action items, or research notes...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Selector
                  const Text('Category Tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedTag == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              selectedTag = cat;
                            });
                          }
                        },
                        selectedColor: AppColors.primaryContainer,
                        backgroundColor: AppColors.surfaceContainerLow,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Color Label Selector
                  const Text('Color Label', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: _colorPalette.map((cp) {
                      final hex = cp['hex'] as String;
                      final color = cp['color'] as Color;
                      final isSelected = selectedColorHex == hex;

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedColorHex = hex;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final title = titleController.text.trim();
                            final content = contentController.text.trim();
                            if (title.isNotEmpty) {
                              if (isEditing) {
                                noteProvider.updateNote(existingNote.id, title, content, selectedTag, selectedColorHex);
                              } else {
                                noteProvider.addNote(title, content, selectedTag, colorHex: selectedColorHex, isPinned: isPinned);
                              }
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(isEditing ? 'Save Changes' : 'Create Note', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context, NoteProvider noteProvider, NoteModel note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 10),
              Text('Delete Note', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${note.title}"?\nThis action cannot be undone.',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                noteProvider.deleteNote(note.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted note "${note.title}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorContainer,
                foregroundColor: AppColors.onErrorContainer,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
