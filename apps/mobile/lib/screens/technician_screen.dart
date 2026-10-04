import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class TechnicianPortalScreen extends StatefulWidget {
  final AppState appState;

  const TechnicianPortalScreen({super.key, required this.appState});

  @override
  State<TechnicianPortalScreen> createState() => _TechnicianPortalScreenState();
}

class _TechnicianPortalScreenState extends State<TechnicianPortalScreen> {
  void _recordDiagnosisDialog(ServiceRequestModel job) {
    final findingsCtrl = TextEditingController();
    final diagnosisCtrl = TextEditingController();
    final partsCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Diagnosis: ${job.title.split(':')[0]}', style: const TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: findingsCtrl,
                  decoration: const InputDecoration(labelText: 'Inspection Findings *', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: diagnosisCtrl,
                  decoration: const InputDecoration(labelText: 'Technical Diagnosis *', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: partsCtrl,
                  decoration: const InputDecoration(labelText: 'Parts Required', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (findingsCtrl.text.trim().isEmpty || diagnosisCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please provide inspection findings and diagnosis.')),
                        );
                        return;
                      }

                      setDialogState(() => submitting = true);
                      try {
                        await FirestoreService().db.collection('serviceRequests').doc(job.id).update({
                          'status': 'QUOTE_PENDING',
                          'diagnosisFindings': findingsCtrl.text.trim(),
                          'technicalDiagnosis': diagnosisCtrl.text.trim(),
                          'partsRequired': partsCtrl.text.trim(),
                          'updatedAt': DateTime.now().toIso8601String(),
                        });

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Diagnosis submitted! Status moved to "Quote Pending".')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => submitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: SvcColors.danger, content: Text('Error submitting diagnosis: $e')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: SvcColors.primary, foregroundColor: Colors.white),
              child: submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Submit to Admin'),
            ),
          ],
        ),
      ),
    );
  }

  void _markCompleted(ServiceRequestModel job) async {
    try {
      await FirestoreService().db.collection('serviceRequests').doc(job.id).update({
        'status': 'COMPLETED',
        'completedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job marked as Completed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: SvcColors.danger, content: Text('Error updating job: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;
    final isAuthorized = user != null && (user.role == 'technician' || user.role == 'admin');

    if (!isAuthorized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Technician Portal'),
          backgroundColor: SvcColors.surface,
          elevation: 0.5,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: SvcColors.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.handyman_outlined, size: 30, color: SvcColors.info),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Technician Access Required',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: SvcColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  user != null
                      ? 'You are currently signed in as ${user.name} (${user.role.toUpperCase()}). Please sign in with an authorized Sharma Video Care technician account to access the workbench.'
                      : 'Please sign in with your technician credentials to access diagnostic tools and assigned jobs.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SvcColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LoginScreen(appState: widget.appState)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SvcColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Sign In as Technician', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isExternal = user.technicianType == 'EXTERNAL';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Portal'),
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<ServiceRequestModel>>(
        stream: FirestoreService().streamServiceRequests(
          technicianId: user.role == 'technician' ? user.id : null,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data ?? [];
          final activeDiagnosticsCount = jobs.where((j) => j.status.contains('INSPECTION') || j.status == 'REQUESTED').length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Technician Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SvcColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SvcColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: SvcTypography.cardTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isExternal ? 'External Partner (10% Commission)' : 'In-House Service Technician',
                          style: SvcTypography.caption,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: SvcColors.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Janakpur Hub',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: SvcColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Overview KPI Metrics Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: SvcColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SvcColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ASSIGNED', style: SvcTypography.statLabel),
                          const SizedBox(height: 4),
                          Text('${jobs.length}', style: SvcTypography.statValue.copyWith(fontSize: 22)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: SvcColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SvcColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DIAGNOSTICS', style: SvcTypography.statLabel),
                          const SizedBox(height: 4),
                          Text(
                            '$activeDiagnosticsCount',
                            style: SvcTypography.statValue.copyWith(fontSize: 22, color: SvcColors.warning),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: SvcColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SvcColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PAYOUT', style: SvcTypography.statLabel),
                          const SizedBox(height: 4),
                          Text(
                            isExternal ? '10%' : 'Fixed',
                            style: SvcTypography.statValue.copyWith(fontSize: 22, color: SvcColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                'Assigned Repair Jobs',
                style: SvcTypography.headingTight,
              ),
              const SizedBox(height: 10),

              if (jobs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: SvcColors.canvas,
                            shape: BoxShape.circle,
                            border: Border.all(color: SvcColors.border),
                          ),
                          child: const Icon(Icons.assignment_turned_in_outlined, size: 26, color: SvcColors.muted),
                        ),
                        const SizedBox(height: 14),
                        const Text('No Jobs Currently Assigned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 6),
                        const Text(
                          'New inspection appointments and workshop diagnostic requests will automatically show up here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: SvcColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...jobs.map((job) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    color: SvcColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: SvcColors.border),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ref #${job.id.length > 8 ? job.id.substring(0, 8).toUpperCase() : job.id.toUpperCase()}',
                                style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: SvcColors.muted),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: job.status == 'COMPLETED'
                                      ? SvcColors.success.withValues(alpha: 0.15)
                                      : job.status == 'IN_PROGRESS' || job.status == 'INSPECTION_IN_PROGRESS'
                                          ? SvcColors.info.withValues(alpha: 0.15)
                                          : SvcColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  job.status.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: job.status == 'COMPLETED'
                                        ? SvcColors.success
                                        : job.status == 'IN_PROGRESS' || job.status == 'INSPECTION_IN_PROGRESS'
                                            ? SvcColors.info
                                            : SvcColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Text(job.title, style: SvcTypography.cardTitle),
                          const SizedBox(height: 4),
                          Text(job.description, style: SvcTypography.body.copyWith(color: SvcColors.muted, fontSize: 12.5)),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SvcColors.canvas,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('📍 ${job.streetAddress}, ${job.city}', style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 2),
                                Text('👤 ${job.customerName} (${job.customerPhone})', style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 2),
                                Text('🕒 Slot: ${job.preferredDate} (${job.preferredTimeSlot})', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Actions
                          if (job.status == 'INSPECTION_IN_PROGRESS' || job.status == 'REQUESTED')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _recordDiagnosisDialog(job),
                                icon: const Icon(Icons.edit_note, size: 16),
                                label: const Text('Record Physical Diagnosis'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SvcColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            )
                          else if (job.status == 'IN_PROGRESS' || job.status == 'QUOTE_ACCEPTED')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _markCompleted(job),
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text('Mark Repair Completed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SvcColors.success,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            )
                          else if (job.status == 'QUOTE_PENDING')
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: SvcColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text(
                                  'Diagnosis submitted. Admin formulating quote.',
                                  style: TextStyle(fontSize: 12, color: SvcColors.warning, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
