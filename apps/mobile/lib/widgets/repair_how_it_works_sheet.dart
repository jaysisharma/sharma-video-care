import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../data/repair_services_data.dart';

void showSymptomDetailSheet(
  BuildContext context,
  RepairSymptomQuickFix symptom,
  VoidCallback onBookThisFix,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: SvcColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: SvcColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SvcColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(symptom.icon, color: SvcColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${symptom.category.toUpperCase()} DIAGNOSTIC',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: SvcColors.muted),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      symptom.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SvcColors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Root cause
          const Text('Root Cause:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SvcColors.muted)),
          const SizedBox(height: 4),
          Text(
            symptom.commonCause,
            style: const TextStyle(fontSize: 13, color: SvcColors.ink, height: 1.35),
          ),
          const SizedBox(height: 14),

          // Lab solution
          const Text('Bench-Tested Solution:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SvcColors.muted)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SvcColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.precision_manufacturing_outlined, size: 18, color: SvcColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    symptom.labSolution,
                    style: const TextStyle(fontSize: 12.5, color: SvcColors.ink, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Specs Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricPill(
                  'Estimated Cost',
                  'Rs. ${symptom.priceMin} - ${symptom.priceMax}',
                  Icons.payments_outlined,
                  const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricPill(
                  'Turnaround',
                  symptom.turnaround,
                  Icons.timelapse_rounded,
                  SvcColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricPill(
                  'Warranty',
                  '${symptom.warrantyDays} Days',
                  Icons.shield_outlined,
                  const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onBookThisFix();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SvcColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Book This Repair (Rs. 0 Visit)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMetricPill(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: SvcColors.canvas,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: SvcColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: SvcColors.muted)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

void showHowItWorksFullSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: SvcColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: SvcColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.verified, color: SvcColors.primary, size: 22),
                SizedBox(width: 8),
                Text(
                  'How Repair Works at Video Care',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SvcColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'A completely transparent 4-stage process designed to eliminate surprise charges, protect your equipment, and ensure OEM-standard performance.',
              style: TextStyle(fontSize: 12.5, color: SvcColors.muted, height: 1.35),
            ),
            const SizedBox(height: 20),

            _buildDetailedStep(
              stepNumber: '1',
              title: 'Book Online or Walk In',
              badge: 'FREE JANAKPUR PICKUP',
              description:
                  'Book your repair in under 60 seconds. Choose between free doorstep technician pickup anywhere across Janakpur Wards 1-14, or walk into our Station Road lab directly.',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFFE86F1C),
            ),
            _buildDetailedStep(
              stepNumber: '2',
              title: 'Cleanroom 45-Point Diagnosis',
              badge: 'RS. 0 BENCH ASSESSMENT',
              description:
                  'Your equipment is placed in our dedicated ISO cleanroom bench. Our certified engineers inspect sensor alignment, circuit resistances, and optics with zero obligation to proceed.',
              icon: Icons.biotech_rounded,
              color: const Color(0xFF2563EB),
            ),
            _buildDetailedStep(
              stepNumber: '3',
              title: 'Transparent Photo & WhatsApp Quote',
              badge: 'NO HIDDEN SURPRISES',
              description:
                  'Before a single screw is turned, you receive high-resolution microscopic photos of the defect, an itemized genuine spare parts breakdown, and exact labor cost. You stay in 100% control.',
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF059669),
            ),
            _buildDetailedStep(
              stepNumber: '4',
              title: 'Ultrasonic Clean & 90-Day Warranty Return',
              badge: '90-DAY GUARANTEE',
              description:
                  'Once repaired, gear undergoes a 4-hour rigorous stress test, ultrasonic exterior sanitization, and is returned with an official 90-Day QuickySewa serialized warranty card.',
              icon: Icons.verified_rounded,
              color: const Color(0xFF7C3AED),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SvcColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: SvcColors.primary),
                      SizedBox(width: 6),
                      Text('Janakpur Service Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Station Road, Opposite Railway Station, Janakpur Dham, Nepal\nOpen Sunday – Friday: 9:30 AM – 7:30 PM | Helpline: +977-9812334455',
                    style: TextStyle(fontSize: 11.5, color: SvcColors.muted, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDetailedStep({
  required String stepNumber,
  required String title,
  required String badge,
  required String description,
  required IconData icon,
  required Color color,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SvcColors.ink),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: SvcColors.inkSecondary, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void showLabStandardsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: SvcColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: SvcColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.military_tech_rounded, color: SvcColors.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  'Video Care Engineering Standards',
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: SvcColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Our Janakpur repair center adheres to industrial micro-electronics and optical benchmarks. We never compromise on tooling, ESD protection, or parts integrity.',
              style: TextStyle(fontSize: 12.5, color: SvcColors.muted, height: 1.35),
            ),
            const SizedBox(height: 20),
            ...kLabStandards.map((std) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SvcColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SvcColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(std.icon, color: SvcColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          std.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SvcColors.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          std.description,
                          style: const TextStyle(fontSize: 12, color: SvcColors.inkSecondary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Every repair is documented with high-resolution microscope photos and before/after test reports.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showMarketplaceServiceDetailSheet(
  BuildContext context,
  MarketplaceRepairService service,
  VoidCallback onBookThisService,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: SvcColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: SvcColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: service.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(service.icon, color: service.accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: service.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              service.badge,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: service.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            service.category.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SvcColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SvcColors.ink, height: 1.25),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price & Rating Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SvcColors.border),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Fixed Price', style: TextStyle(fontSize: 10.5, color: SvcColors.muted)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Rs. ${service.price}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: service.accentColor),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rs. ${service.originalPrice}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SvcColors.muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${service.discountPercent}% OFF',
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            '${service.rating}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SvcColors.ink),
                          ),
                          Text(
                            ' (${service.reviewCount})',
                            style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.turnaround,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SvcColors.inkSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text('Service Description:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: SvcColors.ink)),
            const SizedBox(height: 4),
            Text(
              service.shortDescription,
              style: const TextStyle(fontSize: 13, color: SvcColors.inkSecondary, height: 1.35),
            ),
            const SizedBox(height: 16),

            // Inclusions Checklist
            const Text('What\'s Included in this Service:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: SvcColors.ink)),
            const SizedBox(height: 8),
            ...service.features.map(
              (feat) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: SvcColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feat,
                        style: const TextStyle(fontSize: 12.5, color: SvcColors.ink, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guarantee note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SvcColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: SvcColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rs. 0 Upfront: Physical inspection and technician visit in Janakpur are free. You only pay after work is done and verified.',
                      style: TextStyle(fontSize: 11.5, color: SvcColors.primaryDark, fontWeight: FontWeight.w600, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  onBookThisService();
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text(
                  'Book Service for Rs. ${service.price} (Free Visit)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: service.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


