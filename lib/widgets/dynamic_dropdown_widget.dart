import 'package:flutter/material.dart';

class DynamicDropdownWidget extends StatefulWidget {
  final String title;
  final List<String> dropdownItems;
  final List<String> initialSelectedItems;
  final Function(List<String>) onItemsChanged;
  final Color? primaryColor;
  final IconData? dropdownIcon;
  final IconData? itemIcon;
  final String? hintText;

  const DynamicDropdownWidget({
    super.key,
    required this.title,
    required this.dropdownItems,
    this.initialSelectedItems = const [],
    required this.onItemsChanged,
    this.primaryColor,
    this.dropdownIcon,
    this.itemIcon,
    this.hintText,
  });

  @override
  State<DynamicDropdownWidget> createState() => _DynamicDropdownWidgetState();
}

class _DynamicDropdownWidgetState extends State<DynamicDropdownWidget> {
  late List<String> _selectedItems;
  String? _currentSelection;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  void didUpdateWidget(DynamicDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update _selectedItems when initialSelectedItems changes
    if (widget.initialSelectedItems != oldWidget.initialSelectedItems) {
      setState(() {
        _selectedItems = List.from(widget.initialSelectedItems);
        _currentSelection = null; // Reset current selection as well
      });
    }
  }

  Color get _primaryColor => widget.primaryColor ?? Colors.purple.shade700;

  List<String> get _availableItems {
    return widget.dropdownItems
        .where((item) => !_selectedItems.contains(item))
        .toList();
  }

  void _addItem(String? item) {
    if (item != null && !_selectedItems.contains(item)) {
      setState(() {
        _selectedItems.add(item);
        _currentSelection = null;
      });
      widget.onItemsChanged(_selectedItems);
    }
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
    widget.onItemsChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _currentSelection,
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? 'اختر من القائمة...',
                        prefixIcon: Icon(
                          widget.dropdownIcon ?? Icons.arrow_drop_down_circle_outlined,
                          color: _primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        fillColor: Colors.grey.shade50,
                        filled: true,
                      ),
                      items: _availableItems.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _currentSelection = newValue;
                        });
                      },
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _currentSelection != null 
                      ? () => _addItem(_currentSelection) 
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
            
            // Display Selected Items in the same container
            if (_selectedItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: _primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedItems[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: _primaryColor.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeItem(index),
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
