import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme_tokens.dart';
import 'svc_snackbar.dart';

/// Opens a modal bottom sheet allowing the customer to switch their delivery hub.
void showDeliveryHubSheet(BuildContext context, AppState appState) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: SvcColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SvcColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 14, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SvcColors.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: SvcColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Delivery Hub',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: SvcColors.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Orders & equipment ship from your selected regional center',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: SvcColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: SvcColors.inkSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: SvcColors.border),

              // Hubs List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: kNepalDeliveryHubs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final hub = kNepalDeliveryHubs[index];
                    final isSelected = appState.selectedDeliveryHub.toLowerCase().contains(hub.name.toLowerCase()) ||
                        appState.selectedDeliveryHub.toLowerCase().contains(hub.city.toLowerCase());

                    return InkWell(
                      onTap: () {
                        appState.setDeliveryHub(hub.name);
                        Navigator.pop(ctx);
                        SvcSnackbar.show(context, 'Delivering to ${hub.name}', type: SnackType.success);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? SvcColors.primarySoft.withValues(alpha: 0.35) : SvcColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? SvcColors.primary : SvcColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? SvcColors.primary : SvcColors.muted,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        hub.name,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                          color: SvcColors.ink,
                                        ),
                                      ),
                                      if (hub.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'MAIN HQ',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF166534),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${hub.address}, ${hub.city}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: SvcColors.inkSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.local_shipping_outlined, size: 14, color: SvcColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        hub.estimatedDelivery,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: SvcColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom footer note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: SvcColors.canvas,
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 16, color: SvcColors.muted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Express courier available to all 77 districts of Nepal.',
                        style: TextStyle(fontSize: 11, color: SvcColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
