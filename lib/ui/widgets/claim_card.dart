import 'package:flutter/material.dart';

import 'package:rex_assignment/models/claim.dart';
import 'package:rex_assignment/theme/app_colors.dart';
import 'package:rex_assignment/ui/widgets/status_chip.dart';

class ClaimCard extends StatelessWidget {
  final Claim claim;

  final VoidCallback onTap;

  const ClaimCard({
    super.key,
    required this.claim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        18,
      ),
      child: Card(
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
                      claim.claimNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusChip(
                    status: claim.status,
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                claim.employeeName,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                claim.purpose,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: Text(
                      claim.expenseDate
                          .toString()
                          .split(
                            ' ',
                          )
                          .first,
                    ),
                  ),
                  Text(
                    '₹${claim.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
