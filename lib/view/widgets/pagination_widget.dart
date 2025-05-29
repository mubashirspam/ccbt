import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) loadPage;
  const PaginationWidget(
      {super.key,
      required this.currentPage,
      required this.totalPages,
      required this.loadPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0 ? () => loadPage(currentPage - 1) : null,
          ),

          // Page numbers
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildPageNumbers(currentPage, totalPages, context),
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1
                ? () => loadPage(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(
      int currentPage, int totalPages, BuildContext context) {
    List<Widget> pageNumbers = [];

    // Determine range of pages to show
    int startPage = math.max(0, currentPage - 2);
    int endPage = math.min(totalPages - 1, currentPage + 2);

    // Always show first page
    if (startPage > 0) {
      pageNumbers.add(_buildPageButton(0, currentPage, context));

      // Add ellipsis if there's a gap
      if (startPage > 1) {
        pageNumbers.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('...'),
        ));
      }
    }

    // Add page numbers in range
    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageButton(i, currentPage, context));
    }

    // Always show last page
    if (endPage < totalPages - 1) {
      // Add ellipsis if there's a gap
      if (endPage < totalPages - 2) {
        pageNumbers.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('...'),
        ));
      }

      pageNumbers.add(_buildPageButton(totalPages - 1, currentPage, context));
    }

    return pageNumbers;
  }

  Widget _buildPageButton(
      int pageNumber, int currentPage, BuildContext context) {
    final isCurrentPage = pageNumber == currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: isCurrentPage ? () {} : () => loadPage(pageNumber),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isCurrentPage
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          foregroundColor: isCurrentPage
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('${pageNumber + 1}'),
      ),
    );
  }
}
