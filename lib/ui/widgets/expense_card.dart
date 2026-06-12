import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rex_assignment/models/expense_type.dart';

import 'package:rex_assignment/ui/receipt_view_screen.dart';
import 'package:rex_assignment/utils/currency_formatter.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseItem item;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  bool get hasReceipt {
    if (item.receiptPath == null) {
      return false;
    }

    if (item.receiptPath!.trim().isEmpty) {
      return false;
    }

    return File(
      item.receiptPath!,
    ).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.type.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    item.amount,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              item.description,
            ),
            if (hasReceipt)
              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptViewScreen(
                          imagePath: item.receiptPath!,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    child: Image.file(
                      File(
                        item.receiptPath!,
                      ),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          height: 140,
                          alignment: Alignment.center,
                          child: const Text(
                            'Unable to load receipt',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
