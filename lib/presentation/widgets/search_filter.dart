import 'package:flutter/material.dart';
import '../../data/models/device_filter.dart';

class SearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final DeviceFilter currentFilter;
  final int totalDevices;
  final int audioDeviceCount;
  final int smartwatchCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DeviceFilter?> onFilterChanged;

  const SearchFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.currentFilter,
    required this.totalDevices,
    required this.audioDeviceCount,
    required this.smartwatchCount,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        _buildFilterChips()      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, type (audio, watch), or brand...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          if (searchQuery.isEmpty) _buildSearchTips(context),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownMenu<DeviceFilter>(
        initialSelection: currentFilter,
        onSelected: onFilterChanged,
        dropdownMenuEntries: [
          DropdownMenuEntry(value: DeviceFilter.all, label: 'All Devices ($totalDevices)'),
          DropdownMenuEntry(value: DeviceFilter.audio, label: 'Audio Devices ($audioDeviceCount)'),
          DropdownMenuEntry(value: DeviceFilter.smartwatch, label: 'Smartwatches ($smartwatchCount)'),
        ],
      ),
    );
  }
Widget _buildFilterChips() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All ($totalDevices)',
            isSelected: currentFilter == DeviceFilter.all,
            onTap: () => onFilterChanged(DeviceFilter.all),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Audio ($audioDeviceCount)',
            isSelected: currentFilter == DeviceFilter.audio,
            onTap: () => onFilterChanged(DeviceFilter.audio),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Smart ($smartwatchCount)',
            isSelected: currentFilter == DeviceFilter.smartwatch,
            onTap: () => onFilterChanged(DeviceFilter.smartwatch),
          ),
          if (currentFilter != DeviceFilter.all) ...[
            const SizedBox(width: 0),
            // _buildClearFilterChip(),
          ],
        ],
      ),
    ),
  );
}

Widget _buildFilterChip({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return FilterChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (_) => onTap(),
    backgroundColor: Colors.grey[200],
    selectedColor: Colors.blue.withOpacity(0.2),
    checkmarkColor: Colors.blue,
    labelStyle: TextStyle(
      color: isSelected ? Colors.blue : Colors.grey[700],
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
    ),
  );
}

Widget _buildClearFilterChip() {
  return ActionChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Clear'),
        const SizedBox(width: 4),
        Icon(Icons.close, size: 16),
      ],
    ),
    onPressed: () => onFilterChanged(DeviceFilter.all),
    backgroundColor: Colors.grey[100],
    labelStyle: TextStyle(color: Colors.grey[600]),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.grey[300]!),
    ),
  );
}


Widget _buildFilterButton({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      foregroundColor: isSelected ? Colors.blue : Colors.grey[700],
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}

Widget _buildClearButton() {
  return TextButton(
    onPressed: () => onFilterChanged(DeviceFilter.all),
    style: TextButton.styleFrom(
      foregroundColor: Colors.grey[600],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.clear, size: 16),
        const SizedBox(width: 4),
        Text('Clear Filter'),
      ],
    ),
  );
}
  Widget _buildSearchTips(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          // Your search tips implementation
        ],
      ),
    );
  }
}