import 'package:flutter/material.dart';

class DynamicInputWidget extends StatefulWidget {
  final String title;
  final List<String> initialItems;
  final Function(List<String>) onItemsChanged;

  const DynamicInputWidget({
    super.key,
    required this.title,
    this.initialItems = const [],
    required this.onItemsChanged,
  });

  @override
  State<DynamicInputWidget> createState() => _DynamicInputWidgetState();
}

class _DynamicInputWidgetState extends State<DynamicInputWidget> {
  final _controller = TextEditingController();
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _primaryColor => Colors.green.shade700;

  void _addItem(String text) {
    if (text.trim().isNotEmpty && !_items.contains(text.trim())) {
      setState(() {
        _items.add(text.trim());
        _controller.clear();
      });
      widget.onItemsChanged(_items);
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    widget.onItemsChanged(_items);
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'أدخل اسم الطفل...',
                      prefixIcon: Icon(
                        Icons.add_circle_outline,
                        color: _primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onFieldSubmitted: _addItem,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addItem(_controller.text),
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
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
            
            // Display Added Items in the same container
            if (_items.isNotEmpty) ...[

              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
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
                          Icons.label,
                          color: _primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _items[index],
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
