import 'package:flutter/material.dart';
import '../../data/models/device_filter.dart';

class FilterStatus extends StatelessWidget {
  final String searchQuery;
  final DeviceFilter currentFilter;
  final VoidCallback onClearFilters;

  const FilterStatus({
    super.key,
    required this.searchQuery,
    required this.currentFilter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveSearch = searchQuery.isNotEmpty;
    final hasActiveFilter = currentFilter != DeviceFilter.all;

    if (!hasActiveSearch && !hasActiveFilter) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (hasActiveFilter) _buildFilterChip(),
          if (hasActiveSearch) _buildSearchChip(),
          const Spacer(),
          if (hasActiveSearch || hasActiveFilter) _buildClearButton(),
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_alt, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            currentFilter.name,
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search, size: 14, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            '"$searchQuery"',
            style: const TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return TextButton(
      onPressed: onClearFilters,
      child: const Text(
        'Clear',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}