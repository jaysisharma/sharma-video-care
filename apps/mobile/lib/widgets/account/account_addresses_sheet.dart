import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../svc_snackbar.dart';

class AccountAddressesSheet {
  static void openAddressesModal({
    required BuildContext context,
    required UserModel? user,
    required AppState appState,
    required void Function(BuildContext, String) showAuthRequiredPrompt,
  }) {
    if (user == null) {
      showAuthRequiredPrompt(context, 'view and manage your delivery addresses');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final addresses = appState.savedAddresses;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFF97316)),
                        const SizedBox(width: 8),
                        const Text(
                          'Saved Delivery Addresses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (addresses.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF7ED),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_off_outlined,
                                size: 28,
                                color: Color(0xFFF97316),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No Saved Delivery Addresses',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Add your studio, home or equipment receiving address for faster nationwide checkout.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.45,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: addresses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final addr = addresses[index];
                            return _buildAddressCard(
                              address: addr,
                              onSelectDefault: () async {
                                await appState.setDefaultAddress(addr.id);
                                setModalState(() {});
                              },
                              onDelete: () async {
                                await appState.removeAddress(addr.id);
                                setModalState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          openAddAddressSheet(
                            context: context,
                            user: user,
                            appState: appState,
                            onSaved: () => setModalState(() {}),
                          );
                        },
                        icon: const Icon(Icons.add, color: Color(0xFFF97316)),
                        label: const Text(
                          'Add New Delivery Address',
                          style: TextStyle(
                            color: Color(0xFFF97316),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: Color(0xFFF97316)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void openAddAddressSheet({
    required BuildContext context,
    required UserModel user,
    required AppState appState,
    required VoidCallback onSaved,
  }) {
    final labelCtrl = TextEditingController(text: 'Main Studio');
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Janakpurdham');
    final phoneCtrl = TextEditingController(text: user.phone);
    bool isDefault = appState.savedAddresses.isEmpty;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (subCtx, setSubState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.add_location_alt_outlined, color: Color(0xFFF97316)),
                        const SizedBox(width: 8),
                        const Text(
                          'Add Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    if (errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Address Label *',
                        hintText: 'e.g. Studio, Home, Office',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Street Address *',
                        hintText: 'e.g. Station Road, Bhanu Chowk',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'City / District *',
                        hintText: 'e.g. Janakpurdham, Kathmandu, Biratnagar',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone Number',
                        hintText: '+977 98XXXXXXXX',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: const Color(0xFFF97316),
                      title: const Text(
                        'Set as Default Delivery Address',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      value: isDefault,
                      onChanged: (val) => setSubState(() => isDefault = val),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final label = labelCtrl.text.trim();
                          final address = addressCtrl.text.trim();
                          final city = cityCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();

                          if (label.isEmpty || address.isEmpty || city.isEmpty) {
                            setSubState(() => errorMsg = 'Please fill in all required address fields.');
                            return;
                          }

                          final newAddress = UserAddress(
                            id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
                            label: label,
                            fullAddress: address,
                            city: city,
                            phone: phone,
                            isDefault: isDefault,
                          );

                          await appState.addAddress(newAddress);
                          onSaved();
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          if (context.mounted) {
                            SvcSnackbar.show(context, 'Delivery address saved successfully.', type: SnackType.success);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildAddressCard({
    required UserAddress address,
    required VoidCallback onSelectDefault,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
          width: address.isDefault ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onSelectDefault,
            child: Icon(
              address.isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
              color: address.isDefault ? const Color(0xFFF97316) : const Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEEAD9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: Color(0xFFC2570D),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${address.fullAddress}${address.city.isNotEmpty ? ', ${address.city}' : ''}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                if (address.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(address.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF94A3B8), size: 18),
            onPressed: onDelete,
            tooltip: 'Remove address',
          ),
        ],
      ),
    );
  }
}
