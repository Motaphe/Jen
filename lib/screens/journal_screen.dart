import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/journal_entry.dart';
import '../services/database_helper.dart';

class JournalScreen extends StatefulWidget {
  final List<JournalEntry> entries;
  final Function(List<JournalEntry>) setEntries;

  const JournalScreen({
    super.key,
    required this.entries,
    required this.setEntries,
  });

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  void _navigateToEditor({JournalEntry? entry, int? index}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditorScreen(
          entry: entry,
          onSave: (updatedEntry) async {
            final db = DatabaseHelper.instance;

            if (index != null) {
              // Update existing entry
              await db.updateJournalEntry(updatedEntry);
              setState(() {
                widget.entries[index] = updatedEntry;
                widget.setEntries(widget.entries);
              });
            } else {
              // Create new entry
              final id = await db.createJournalEntry(updatedEntry);
              final newEntry = JournalEntry(
                id: id,
                title: updatedEntry.title,
                content: updatedEntry.content,
                date: updatedEntry.date,
              );
              setState(() {
                widget.entries.insert(0, newEntry);
                widget.setEntries(widget.entries);
              });
            }
          },
        ),
      ),
    );
  }

  void _deleteEntry(int index) async {
    final entry = widget.entries[index];
    if (entry.id != null) {
      await DatabaseHelper.instance.deleteJournalEntry(entry.id!);
    }

    setState(() {
      widget.entries.removeAt(index);
      widget.setEntries(widget.entries);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        elevation: 0,
        title: Text(
          'Journal',
          style: AppTextStyles.heading3,
        ),
      ),
      body: widget.entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: AppColors.overlay0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No journal entries yet',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first entry',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.entries.length,
              itemBuilder: (context, index) {
                final entry = widget.entries[index];
                return _buildEntryCard(entry, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(),
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: AppColors.base),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry, int index) {
    return Dismissible(
      key: Key(entry.id?.toString() ?? entry.date.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteEntry(index),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: AppColors.text,
        ),
      ),
      child: GestureDetector(
        onTap: () => _navigateToEditor(entry: entry, index: index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(entry.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: AppTextStyles.bodySecondary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JournalEditorScreen extends StatefulWidget {
  final JournalEntry? entry;
  final Function(JournalEntry) onSave;

  const JournalEditorScreen({
    super.key,
    this.entry,
    required this.onSave,
  });

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');
    _selectedDate = widget.entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    final entry = JournalEntry(
      id: widget.entry?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: _selectedDate,
    );

    widget.onSave(entry);
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.blue,
              surface: AppColors.surface0,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.entry == null ? 'New Entry' : 'Edit Entry',
          style: AppTextStyles.heading3,
        ),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: Text(
              'Save',
              style: AppTextStyles.body.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface0,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              style: AppTextStyles.heading2,
              decoration: InputDecoration(
                hintText: 'Entry title',
                hintStyle: AppTextStyles.heading2.copyWith(
                  color: AppColors.overlay0,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              style: AppTextStyles.body,
              maxLines: null,
              minLines: 10,
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.overlay0,
                ),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
