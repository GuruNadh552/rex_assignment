import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rex_assignment/ui/widgets/dashboard_cart.dart';

import 'package:rex_assignment/models/claim.dart';
import 'package:rex_assignment/services/claims_provider.dart';
import 'package:rex_assignment/theme/app_colors.dart';
import 'package:rex_assignment/utils/currency_formatter.dart';
import 'package:rex_assignment/ui/widgets/claim_card.dart';
import 'package:rex_assignment/ui/widgets/empty_state.dart';
import 'package:rex_assignment/ui/widgets/loading_overlay.dart';
import 'package:rex_assignment/ui/widgets/search_bar_widget.dart';
import 'package:rex_assignment/ui/manager/claim_detail_screen.dart';
import 'package:rex_assignment/ui/employee/claim_form_screen.dart';

class ClaimListScreen extends StatefulWidget {
  final bool isManager;

  const ClaimListScreen({
    super.key,
    required this.isManager,
  });

  @override
  State<ClaimListScreen> createState() => _ClaimListScreenState();
}

class _ClaimListScreenState extends State<ClaimListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimsProvider>().loadClaims();
    });
  }

  Future<void> _refresh() async {
    await context.read<ClaimsProvider>().loadClaims();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClaimsProvider>();

    final claims =
        widget.isManager ? provider.managerClaims : provider.filteredClaims;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isManager ? 'Manager Review' : 'My Claims',
        ),
      ),
      floatingActionButton: widget.isManager
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClaimFormScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
      body: LoadingOverlay(
        isLoading: provider.isLoading,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBarWidget(
                  onChanged: provider.updateSearch,
                ),
              ),
              _buildSortSection(provider),
              const SizedBox(height: 10),
              _buildStatusFilters(provider),
              const SizedBox(height: 12),
              if (!widget.isManager) _buildDashboard(provider),
              const SizedBox(height: 16),
              if (claims.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyState(
                    title: 'No Claims Found',
                    subtitle: 'Create your first expense claim',
                  ),
                )
              else
                ...claims.map(
                  (claim) => Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: ClaimCard(
                      claim: claim,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClaimDetailScreen(
                              claim: claim,
                              isManager: widget.isManager,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    ClaimsProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Draft',
                  value: provider.draftCount.toString(),
                  color: AppColors.draft,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: DashboardCard(
                  title: 'Submitted',
                  value: provider.submittedCount.toString(),
                  color: AppColors.submitted,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Approved',
                  value: provider.approvedCount.toString(),
                  color: AppColors.approved,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: DashboardCard(
                  title: 'Rejected',
                  value: provider.rejectedCount.toString(),
                  color: AppColors.rejected,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Draft Amount',
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  CurrencyFormatter.format(
                    provider.claims
                        .where(
                          (e) => e.status == ClaimStatus.draft,
                        )
                        .fold(
                          0,
                          (sum, claim) => sum + claim.totalAmount,
                        ),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection(
    ClaimsProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: DropdownButtonFormField<SortOption>(
        value: provider.selectedSort,
        decoration: const InputDecoration(
          labelText: 'Sort By',
        ),
        items: SortOption.values.map(
          (option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option.name,
              ),
            );
          },
        ).toList(),
        onChanged: (value) {
          if (value != null) {
            provider.updateSort(
              value,
            );
          }
        },
      ),
    );
  }

  Widget _buildStatusFilters(
    ClaimsProvider provider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          _chip(
            provider,
            null,
            'All',
          ),
          _chip(
            provider,
            ClaimStatus.draft,
            'Draft',
          ),
          _chip(
            provider,
            ClaimStatus.submitted,
            'Submitted',
          ),
          _chip(
            provider,
            ClaimStatus.approved,
            'Approved',
          ),
          _chip(
            provider,
            ClaimStatus.rejected,
            'Rejected',
          ),
        ],
      ),
    );
  }

  Widget _chip(
    ClaimsProvider provider,
    ClaimStatus? status,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: FilterChip(
        label: Text(label),
        selected: provider.selectedStatus == status,
        onSelected: (_) {
          provider.updateStatus(
            status,
          );
        },
      ),
    );
  }
}
