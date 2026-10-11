import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../data/models/vietqr_bank_model.dart';
import '../../data/services/vietqr_bank_service.dart';

class BankPickerBottomSheet extends StatefulWidget {
  final VietQrBankService bankService;
  final String? currentBankShortName;

  const BankPickerBottomSheet({
    super.key,
    required this.bankService,
    this.currentBankShortName,
  });

  static Future<VietQrBankModel?> show(
    BuildContext context, {
    VietQrBankService? bankService,
    String? currentBankShortName,
  }) {
    final service = bankService ?? VietQrBankService();
    return showModalBottomSheet<VietQrBankModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BankPickerBottomSheet(
        bankService: service,
        currentBankShortName: currentBankShortName,
      ),
    );
  }

  @override
  State<BankPickerBottomSheet> createState() => _BankPickerBottomSheetState();
}

class _BankPickerBottomSheetState extends State<BankPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<VietQrBankModel> _allBanks = [];
  List<VietQrBankModel> _filteredBanks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBanks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final banks = await widget.bankService.getBanks();
      if (!mounted) return;
      setState(() {
        _allBanks = banks;
        _filteredBanks = _filterList(banks, _searchController.text);
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.loadBanksFailed;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredBanks = _filterList(_allBanks, _searchController.text);
    });
  }

  List<VietQrBankModel> _filterList(List<VietQrBankModel> list, String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return list;
    return list.where((b) {
      return b.shortName.toLowerCase().contains(clean) ||
          b.name.toLowerCase().contains(clean) ||
          b.code.toLowerCase().contains(clean) ||
          b.bin.contains(clean);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.dragHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr.selectBankPrompt,
                    style: AppTextStyle.bold(
                      fontSize: 17,
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, size: 20, color: colors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.inputBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _onSearchChanged(),
                  style: AppTextStyle.medium(
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: tr.searchBankHint,
                    hintStyle: AppTextStyle.regular(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: colors.cardBorder),

            // Body
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: colors.brandEmerald,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 12),
            Text(
              tr.loadingBanksMessage,
              style: AppTextStyle.regular(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.wifiOff,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyle.medium(
                  fontSize: 13.5,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadBanks,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: Text(tr.retryAction),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldForest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredBanks.isEmpty) {
      return Center(
        child: Text(
          tr.noBanksFound,
          style: AppTextStyle.regular(
            fontSize: 13.5,
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredBanks.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 68,
        color: colors.cardBorder.withValues(alpha: 0.5),
      ),
      itemBuilder: (context, index) {
        final bank = _filteredBanks[index];
        final isSelected = widget.currentBankShortName != null &&
            (widget.currentBankShortName!.toLowerCase() ==
                    bank.shortName.toLowerCase() ||
                widget.currentBankShortName!.toLowerCase() ==
                    bank.code.toLowerCase());

        return ListTile(
          onTap: () => Navigator.of(context).pop(bank),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 50,
            height: 34,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.emerald : colors.cardBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: bank.logo.isNotEmpty
                ? Image.network(
                    bank.logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        bank.code,
                        style: AppTextStyle.bold(
                          fontSize: 10,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      bank.code,
                      style: AppTextStyle.bold(
                        fontSize: 10,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
          ),
          title: Row(
            children: [
              Text(
                bank.shortName,
                style: AppTextStyle.bold(
                  fontSize: 14,
                  color: isSelected ? colors.brandEmerald : colors.textPrimary,
                ),
              ),
              if (bank.code != bank.shortName) ...[
                const SizedBox(width: 6),
                Text(
                  '(${bank.code})',
                  style: AppTextStyle.regular(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            bank.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.regular(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  LucideIcons.checkCircle2,
                  size: 20,
                  color: colors.brandEmerald,
                )
              : Text(
                  bank.bin,
                  style: AppTextStyle.medium(
                    fontSize: 11,
                    color: colors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
        );
      },
    );
  }
}
