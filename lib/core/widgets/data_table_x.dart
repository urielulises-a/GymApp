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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      child: Column(
        children: [
          if (searchHint != null || actions != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (searchHint != null)
                    TextField(
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
                  if (actions != null && isMobile) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ] else if (actions != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ],
                ],
              ),
            ),
          if (isMobile && rows.isNotEmpty)
            // Vista de lista para móviles
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final row = rows[index];
                return ExpansionTile(
                  title: Text(
                    row.isNotEmpty ? row[0] : 'Item ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          columns.length,
                          (colIndex) {
                            if (colIndex >= row.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    columns[colIndex],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    row[colIndex],
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            // Vista de tabla para pantallas grandes
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
                          cells: row.map((cell) => DataCell(
                                Text(
                                  cell,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )).toList(),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
