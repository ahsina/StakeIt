import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../data/providers/payment_provider.dart';
import '../data/repositories/payment_repository.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portefeuille'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to transactions history
              _showTransactionsHistory(context, ref);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(paymentMethodsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Wallet Balance Card
            walletAsync.when(
              data: (wallet) => _buildBalanceCard(context, ref, wallet),
              loading: () => const LoadingIndicator(message: 'Chargement du portefeuille...'),
              error: (error, _) => ErrorDisplay(
                message: ErrorMapper.mapPaymentError(error),
                onRetry: () => ref.refresh(walletProvider),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Méthodes de paiement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    _showAddPaymentMethodDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment Methods List
            paymentMethodsAsync.when(
              data: (methods) {
                if (methods.isEmpty) {
                  return const EmptyState(
                    icon: Icons.credit_card_off,
                    title: 'Aucune méthode de paiement',
                    subtitle: 'Ajoutez une carte pour participer aux stakes',
                  );
                }

                return Column(
                  children: methods.map((method) {
                    return _buildPaymentMethodCard(context, ref, method);
                  }).toList(),
                );
              },
              loading: () => const LoadingIndicator(message: 'Chargement des cartes...'),
              error: (error, _) => ErrorDisplay(
                message: ErrorMapper.mapPaymentError(error),
                onRetry: () => ref.refresh(paymentMethodsProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref, WalletModel wallet) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Solde disponible',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(wallet.availableBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (wallet.pendingBalance > 0) ...[
              Text(
                'En attente: ${CurrencyFormatter.format(wallet.pendingBalance)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Gains totaux',
                    CurrencyFormatter.format(wallet.lifetimeEarnings),
                    Colors.green[300]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Dépenses totales',
                    CurrencyFormatter.format(wallet.lifetimeSpent),
                    Colors.orange[300]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Retirer des fonds',
              icon: Icons.send,
              onPressed: wallet.availableBalance >= 10
                  ? () => _showPayoutDialog(context, ref, wallet)
                  : null,
              type: ButtonType.secondary,
              size: ButtonSize.large,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    WidgetRef ref,
    PaymentMethodModel method,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: method.isDefault
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.credit_card,
            color: method.isDefault
                ? Theme.of(context).primaryColor
                : Colors.grey[600],
          ),
        ),
        title: Row(
          children: [
            Text('${method.brand} ${method.cardDisplay}'),
            if (method.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Par défaut',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          'Expire ${method.expiryDisplay}',
          style: TextStyle(
            color: method.isExpired ? Colors.red : null,
          ),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!method.isDefault)
              PopupMenuItem(
                value: 'default',
                child: const Row(
                  children: [
                    Icon(Icons.star_outline),
                    SizedBox(width: 8),
                    Text('Définir par défaut'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'default') {
              _handleSetDefault(context, ref, method);
            } else if (value == 'delete') {
              _handleDelete(context, ref, method);
            }
          },
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context, WidgetRef ref) {
    InfoDialog.show(
      context: context,
      title: 'Ajouter une carte',
      message: 'L\'ajout de carte nécessite Stripe SDK.\nImplémentation complète disponible avec l\'intégration Stripe.',
    );
  }

  void _showPayoutDialog(BuildContext context, WidgetRef ref, WalletModel wallet) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer des fonds'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Solde disponible: ${CurrencyFormatter.format(wallet.availableBalance)}',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingM),
            CurrencyTextField(
              label: 'Montant',
              hint: 'Minimum 10€',
              controller: amountController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final amount = CurrencyFormatter.parse(amountController.text);
              if (amount < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Validators.validateAmount(amountController.text, min: 10.0) ?? ''),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (amount > wallet.availableBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solde insuffisant'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                await ref.read(paymentProvider.notifier).requestPayout(amount);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demande de retrait envoyée'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  ref.invalidate(walletProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ErrorMapper.mapPaymentError(e)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _handleSetDefault(
    BuildContext context,
    WidgetRef ref,
    PaymentMethodModel method,
  ) async {
    try {
      await ref.read(paymentProvider.notifier).setDefaultPaymentMethod(method.id);
      ref.invalidate(paymentMethodsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carte définie par défaut'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMapper.mapPaymentError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleDelete(
    BuildContext context,
    WidgetRef ref,
    PaymentMethodModel method,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Supprimer la carte',
      message: 'Voulez-vous supprimer la carte ${method.cardDisplay} ? Cette action est irréversible.',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(paymentProvider.notifier).removePaymentMethod(method.id);
        ref.invalidate(paymentMethodsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Carte supprimée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMapper.mapPaymentError(e)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showTransactionsHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Historique des transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ref.watch(transactionsProvider(1)).when(
                      data: (transactions) {
                        if (transactions.isEmpty) {
                          return const EmptyState(
                            icon: Icons.receipt_long,
                            title: 'Aucune transaction',
                            subtitle: 'Vos transactions apparaîtront ici',
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return _buildTransactionItem(context, transaction);
                          },
                        );
                      },
                      loading: () => const LoadingIndicator(message: 'Chargement des transactions...'),
                      error: (error, _) => ErrorDisplay(
                        message: ErrorMapper.mapPaymentError(error),
                        onRetry: () => ref.refresh(transactionsProvider(1)),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isCredit
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            transaction.isCredit ? Icons.add : Icons.remove,
            color: transaction.isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.description),
        subtitle: Text(
          DateFormatter.formatContextualDate(transaction.createdAt),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.formatWithSign(transaction.isCredit ? transaction.amount : -transaction.amount),
              style: AppTextStyles.titleMedium.copyWith(
                color: transaction.isCredit ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction.status,
                style: TextStyle(
                  color: _getStatusColor(transaction.status),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
