import 'package:flutter/material.dart';

import '../models/claim.dart';
import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final ClaimStatus status;

  const StatusChip({
    super.key,
    required this.status,
  });

  Color get color {
    switch (status) {
      case ClaimStatus.draft:
        return AppColors.draft;

      case ClaimStatus.submitted:
        return AppColors.submitted;

      case ClaimStatus.approved:
        return AppColors.approved;

      case ClaimStatus.rejected:
        return AppColors.rejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight:
              FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}