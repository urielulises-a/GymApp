import 'package:flutter/material.dart';

class DataTableX extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final String? searchHint;
  final Function(String)? onSearchChanged;
  final List<Widget>? actions;

  const DataTableX({
    super.key,
    required this.columns,
    required this.rows,
    this.searchHint,
    this.onSearchChanged,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          if (searchHint != null || actions != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (searchHint != null)
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: searchHint,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: onSearchChanged,
                      ),
                    ),
                  if (actions != null) ...[
                    const SizedBox(width: 16),
                    ...actions!,
                  ],
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns
                  .map((column) => DataColumn(
                        label: Text(
                          column,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  .toList(),
              rows: rows
                  .map((row) => DataRow(
                        cells: row.map((cell) => DataCell(Text(cell))).toList(),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
