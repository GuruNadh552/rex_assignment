import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rex_assignment/models/expense_type.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rex_assignment/models/claim.dart';
import 'package:rex_assignment/services/claims_provider.dart';
import 'package:rex_assignment/theme/app_colors.dart';
import 'package:rex_assignment/utils/claim_utils.dart';
import 'package:rex_assignment/utils/currency_formatter.dart';
import 'package:rex_assignment/utils/snackbar_helper.dart';
import 'package:rex_assignment/ui/widgets/app_text_field.dart';
import 'package:rex_assignment/ui/widgets/expense_card.dart';
import 'package:rex_assignment/ui/widgets/primary_button.dart';

class ClaimFormScreen extends StatefulWidget {
  final Claim? claim;

  const ClaimFormScreen({
    super.key,
    this.claim,
  });

  @override
  State<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends State<ClaimFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final employeeController = TextEditingController();

  final purposeController = TextEditingController();

  final uuid = const Uuid();

  DateTime expenseDate = DateTime.now();

  List<ExpenseItem> items = [];

  bool get isEdit => widget.claim != null;

  @override
  void initState() {
    super.initState();

    if (widget.claim != null) {
      employeeController.text = widget.claim!.employeeName;

      purposeController.text = widget.claim!.purpose;

      expenseDate = widget.claim!.expenseDate;

      items = List.from(
        widget.claim!.items,
      );
    }
  }

  double get totalAmount {
    return items.fold(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        expenseDate = date;
      });
    }
  }

  Future<void> saveDraft() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ClaimsProvider>();

    final claim = Claim(
      id: widget.claim?.id ?? uuid.v4(),
      claimNumber: widget.claim?.claimNumber ??
          ClaimUtils.generateClaimNumber(
            provider.claims.length,
          ),
      employeeName: employeeController.text.trim(),
      expenseDate: expenseDate,
      purpose: purposeController.text.trim(),
      items: items,
      status: widget.claim?.status ?? ClaimStatus.draft,
    );

    final validation = claim.validate();

    if (validation != null) {
      SnackbarHelper.showError(
        context,
        validation,
      );
      return;
    }

    await provider.saveClaim(
      claim,
    );

    if (!mounted) return;

    SnackbarHelper.showSuccess(
      context,
      'Draft saved successfully',
    );

    Navigator.pop(context);
  }

  Future<void> submitClaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ClaimsProvider>();

    final claim = Claim(
      id: widget.claim?.id ?? uuid.v4(),
      claimNumber: widget.claim?.claimNumber ??
          ClaimUtils.generateClaimNumber(
            provider.claims.length,
          ),
      employeeName: employeeController.text.trim(),
      expenseDate: expenseDate,
      purpose: purposeController.text.trim(),
      items: items,
      status: ClaimStatus.draft,
    );

    final validation = claim.validate();

    if (validation != null) {
      SnackbarHelper.showError(
        context,
        validation,
      );
      return;
    }

    await provider.saveClaim(
      claim,
    );

    await provider.submitClaim(
      claim.id,
    );

    if (!mounted) return;

    SnackbarHelper.showSuccess(
      context,
      'Claim submitted',
    );

    Navigator.pop(context);
  }

  Future<bool> showSubmitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Submit Claim',
            ),
            content: const Text(
              'Are you sure you want to submit this claim?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
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
                    true,
                  );
                },
                child: const Text(
                  'Submit',
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> deleteExpense(
    int index,
  ) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Delete Expense',
            ),
            content: const Text(
              'Delete this expense item?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
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
                    true,
                  );
                },
                child: const Text(
                  'Delete',
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Claim' : 'Create Claim',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: addExpenseItem,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                    onPressed: saveDraft,
                    child: const Text(
                      'Save Draft',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  title: 'Submit',
                  onPressed: () async {
                    final confirmed = await showSubmitDialog();

                    if (!confirmed) {
                      return;
                    }

                    await submitClaim();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            16,
          ),
          children: [
            AppTextField(
              controller: employeeController,
              hint: 'Employee Name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            AppTextField(
              controller: purposeController,
              hint: 'Purpose of Expense',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Expense Date',
              ),
              subtitle: Text(
                expenseDate.toString().split(' ').first,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.calendar_month,
                ),
                onPressed: pickDate,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Expense Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            if (items.isEmpty)
              const Text(
                'No expense items added',
              ),
            ...items.asMap().entries.map(
              (entry) {
                final index = entry.key;

                final item = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ExpenseCard(
                    item: item,
                    onEdit: () {
                      editExpenseItem(
                        index,
                      );
                    },
                    onDelete: () {
                      deleteExpense(
                        index,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(
                  16,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.format(
                      totalAmount,
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addExpenseItem() async {
    final item = await showModalBottomSheet<ExpenseItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExpenseItemSheet(),
    );

    if (item != null) {
      setState(() {
        items.add(item);
      });
    }
  }

  Future<void> editExpenseItem(
    int index,
  ) async {
    final item = await showModalBottomSheet<ExpenseItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseItemSheet(
        existingItem: items[index],
      ),
    );

    if (item != null) {
      setState(() {
        items[index] = item;
      });
    }
  }
}

class ExpenseItemSheet extends StatefulWidget {
  final ExpenseItem? existingItem;

  const ExpenseItemSheet({
    super.key,
    this.existingItem,
  });

  @override
  State<ExpenseItemSheet> createState() => _ExpenseItemSheetState();
}

class _ExpenseItemSheetState extends State<ExpenseItemSheet> {
  final descriptionController = TextEditingController();

  final amountController = TextEditingController();

  ExpenseType selectedType = ExpenseType.travel;

  String? receiptPath;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.existingItem != null) {
      selectedType = widget.existingItem!.type;

      descriptionController.text = widget.existingItem!.description;

      amountController.text = widget.existingItem!.amount.toString();

      receiptPath = widget.existingItem!.receiptPath;
    }
  }

  Future<void> pickReceipt() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                ),
                title: const Text(
                  'Camera',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.image,
                ),
                title: const Text(
                  'Gallery',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    final file = await picker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (file != null) {
      setState(() {
        receiptPath = file.path;
      });
    }
  }

  void saveExpense() {
    final amount = double.tryParse(
          amountController.text,
        ) ??
        0;

    final expense = ExpenseItem(
      id: widget.existingItem?.id ?? const Uuid().v4(),
      type: selectedType,
      description: descriptionController.text.trim(),
      amount: amount,
      receiptPath: receiptPath,
    );

    Navigator.pop(
      context,
      expense,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingItem == null ? 'Add Expense' : 'Edit Expense',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<ExpenseType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Expense Type',
              ),
              items: ExpenseType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: 'Amount',
              ),
            ),
            const SizedBox(height: 12),
            if (receiptPath != null)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  receiptPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    _,
                    __,
                    ___,
                  ) {
                    return Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Text(
                          'Receipt Selected',
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickReceipt,
              icon: const Icon(
                Icons.receipt,
              ),
              label: Text(
                receiptPath == null ? 'Attach Receipt' : 'Change Receipt',
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              title: widget.existingItem == null
                  ? 'Add Expense'
                  : 'Update Expense',
              onPressed: saveExpense,
            ),
          ],
        ),
      ),
    );
  }
}
