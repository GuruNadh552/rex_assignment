import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rex_assignment/theme/app_colors.dart';
import 'package:rex_assignment/models/claim.dart';
import 'package:rex_assignment/services/claims_provider.dart';
import 'package:rex_assignment/utils/currency_formatter.dart';
import 'package:rex_assignment/utils/date_formatter.dart';
import 'package:rex_assignment/utils/snackbar_helper.dart';
import 'package:rex_assignment/ui/widgets/expense_card.dart';
import 'package:rex_assignment/ui/widgets/loading_overlay.dart';
import 'package:rex_assignment/ui/widgets/primary_button.dart';
import 'package:rex_assignment/ui/widgets/status_chip.dart';
import 'package:rex_assignment/ui/employee/claim_form_screen.dart';

class ClaimDetailScreen extends StatefulWidget {
  final Claim claim;
  final bool isManager;

  const ClaimDetailScreen({
    super.key,
    required this.claim,
    required this.isManager,
  });

  @override
  State<ClaimDetailScreen> createState() => _ClaimDetailScreenState();
}

class _ClaimDetailScreenState extends State<ClaimDetailScreen> {
  bool loading = false;

  Claim get claim => widget.claim;

  Future<bool> _confirm(
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> submitClaim() async {
    final confirmed = await _confirm(
      'Submit Claim',
      'Are you sure you want to submit this claim?',
    );

    if (!confirmed) return;

    setState(() {
      loading = true;
    });

    await context.read<ClaimsProvider>().submitClaim(
          claim.id,
        );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    SnackbarHelper.showSuccess(
      context,
      'Claim submitted successfully',
    );

    Navigator.pop(context);
  }

  Future<void> approveClaim() async {
    final confirmed = await _confirm(
      'Approve Claim',
      'Approve this expense claim?',
    );

    if (!confirmed) return;

    setState(() {
      loading = true;
    });

    await context.read<ClaimsProvider>().approveClaim(
          claim.id,
        );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    SnackbarHelper.showSuccess(
      context,
      'Claim approved',
    );

    Navigator.pop(context);
  }

  Future<void> rejectClaim() async {
    final controller = TextEditingController();

    final comments = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Reject Claim',
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter rejection comments',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text,
                );
              },
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (comments == null || comments.trim().isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    await context.read<ClaimsProvider>().rejectClaim(
          claim.id,
          comments,
        );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    SnackbarHelper.showSuccess(
      context,
      'Claim rejected',
    );

    Navigator.pop(context);
  }

  Future<void> moveToDraft() async {
    await context.read<ClaimsProvider>().moveToDraft(
          claim.id,
        );

    if (!mounted) return;

    SnackbarHelper.showSuccess(
      context,
      'Moved back to draft',
    );

    Navigator.pop(context);
  }

  void editClaim() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClaimFormScreen(
          claim: claim,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
      ),
      bottomNavigationBar: _bottomActions(),
      body: LoadingOverlay(
        isLoading: loading,
        child: ListView(
          // padding: const EdgeInsets.all(12),
          children: [
            _buildClaimInfoCard(),
            const SizedBox(height: 24),
            _buildExpenseItems(),
            if (claim.rejectionComments != null) ...[
              const SizedBox(height: 20),
              _buildRejectionComments(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClaimInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusChip(
                status: claim.status,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(
            'Employee',
            claim.employeeName,
          ),
          _infoRow(
            'Purpose',
            claim.purpose,
          ),
          _infoRow(
            'Date',
            DateFormatter.format(
              claim.expenseDate,
            ),
          ),
          const Divider(),
          Row(
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                CurrencyFormatter.format(
                  claim.totalAmount,
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItems() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...claim.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: ExpenseCard(
                item: item,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionComments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(31),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rejection Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            claim.rejectionComments!,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActions() {
    if (!widget.isManager && claim.status == ClaimStatus.draft) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: editClaim,
                    child: const Text(
                      'Edit',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: PrimaryButton(
                  title: 'Submit',
                  onPressed: submitClaim,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!widget.isManager && claim.status == ClaimStatus.rejected) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: moveToDraft,
                  child: const Text(
                    'Move To Draft',
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: PrimaryButton(
                  title: 'Edit',
                  onPressed: editClaim,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.isManager && claim.status == ClaimStatus.submitted) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: rejectClaim,
                    child: const Text(
                      'Reject',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: PrimaryButton(
                  title: 'Approve',
                  onPressed: approveClaim,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
